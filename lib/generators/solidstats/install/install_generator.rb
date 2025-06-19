require "rails/generators/base"

module Solidstats
  module Generators
    # This generator installs Solidstats in the host application
    #
    # @example
    #   $ rails generate solidstats:install
    #
    # This will:
    # 1. Add the Solidstats routes to the host application's config/routes.rb
    # 2. Create a solidstats directory for data storage
    # 3. Add the solidstats directory to .gitignore
    # 4. Show a helpful README with next steps
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Installs Solidstats in your Rails application"

      def add_routes
        route_string = %Q(mount Solidstats::Engine => "/solidstats")
        route_code = %Q(
  # Solidstats Routes (development only)
  #{route_string} if Rails.env.development?
        )

        # Check if the route already exists
        if File.read(File.join(destination_root, "config", "routes.rb")).include?(route_string)
          say_status :skip, "Solidstats route already exists", :yellow
        else
          route route_code.strip
          say_status :routes, "Mounting Solidstats engine at /solidstats (development only)", :green
        end
      end

      def create_solidstats_directory
        empty_directory "solidstats"
        create_file "solidstats/.keep", ""
        say_status :create, "solidstats directory for data storage", :green
      end

      def add_to_gitignore
        gitignore_path = File.join(destination_root, ".gitignore")
        gitignore_content = "\n# Solidstats data directory\nsolidstats/\n"
        
        if File.exist?(gitignore_path)
          append_to_file ".gitignore", gitignore_content unless File.read(gitignore_path).include?("solidstats/")
        else
          create_file ".gitignore", gitignore_content.strip
        end
        say_status :update, ".gitignore to exclude solidstats directory", :green
      end

      def show_next_steps
        say ""
        say "✅ Solidstats has been installed successfully!", :green
        say ""
        say "To get started, you need to prime the data for the dashboard."
        say "You can prime data for all services at once by running:", :yellow
        say "  rake solidstats:prime:all", :cyan
        say ""
        say "Or, you can run them individually:", :yellow
        say "  rake solidstats:prime:log_size"
        say "  rake solidstats:prime:bundler_audit"
        say "  rake solidstats:prime:todos"
        say "  rake solidstats:prime:style_patrol"
        say "  rake solidstats:prime:coverage"
        say "  rake solidstats:prime:load_lens"
        say ""
        say "After the tasks complete, start your server and visit http://localhost:3000/solidstats to see the dashboard."
      end
    end
  end
end
