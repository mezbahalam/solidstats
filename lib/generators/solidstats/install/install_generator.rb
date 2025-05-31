require "rails/generators/base"

module Solidstats
  module Generators
    # This generator installs Solidstats routes in the host application
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
        route_code = <<-RUBY
  # Solidstats Routes (development only)
  mount Solidstats::Engine => "/solidstats" if Rails.env.development?
        RUBY

        route route_code
        say_status :routes, "Mounting Solidstats engine at /solidstats (development environment only)", :green
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
          existing_content = File.read(gitignore_path)
          unless existing_content.include?("solidstats/")
            append_to_file ".gitignore", gitignore_content
            say_status :update, ".gitignore to exclude solidstats directory", :green
          else
            say_status :skip, ".gitignore already contains solidstats exclusion", :yellow
          end
        else
          create_file ".gitignore", gitignore_content.strip
          say_status :create, ".gitignore with solidstats exclusion", :green
        end
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
