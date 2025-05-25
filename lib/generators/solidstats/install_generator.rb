# frozen_string_literal: true

require "rails/generators/base"

module Solidstats
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Install Solidstats in your Rails application"

      source_root File.expand_path("templates", __dir__)

      class_option :css_framework, type: :string, default: "none",
                   desc: "CSS framework integration (none, bootstrap, tailwind)"
      class_option :skip_assets, type: :boolean, default: false,
                   desc: "Skip asset configuration"
      class_option :skip_routes, type: :boolean, default: false,
                   desc: "Skip route mounting"

      def check_environment
        unless Rails.env.development?
          say "⚠️  Warning: Solidstats is designed for development environments only.", :yellow
          say "Current environment: #{Rails.env}", :yellow

          unless yes? "Continue installation anyway? (y/n)"
            say "Installation cancelled.", :red
            exit 1
          end
        end
      end

      def check_dependencies
        say "🔍 Checking dependencies...", :green

        # Check Rails version
        rails_version = Rails::VERSION::STRING
        if Gem::Version.new(rails_version) < Gem::Version.new("6.1.0")
          say "❌ Rails #{rails_version} is not supported. Minimum version: 6.1.0", :red
          exit 1
        end
        say "✅ Rails #{rails_version} supported", :green

        # Check ViewComponent
        begin
          require "view_component"
          say "✅ ViewComponent #{ViewComponent::VERSION} detected", :green
        rescue LoadError
          say "❌ ViewComponent not found. Please add it to your Gemfile:", :red
          say "gem 'view_component'", :yellow
          exit 1
        end
      end

      def mount_engine
        return if options[:skip_routes]

        say "🛤️  Mounting Solidstats engine...", :green

        route_content = "  mount Solidstats::Engine => '/solidstats' if Rails.env.development?"

        if File.read("config/routes.rb").include?("Solidstats::Engine")
          say "⚠️  Solidstats engine already mounted in routes.rb", :yellow
        else
          route route_content
          say "✅ Engine mounted at /solidstats (development only)", :green
        end
      end

      def configure_assets
        say "📦 Configuring assets...", :green

        say "  ✅ Using inline asset delivery (no configuration needed)", :blue
        say "  📝 Assets are automatically included via helper methods", :blue

        say "✅ Asset configuration complete", :green
      end

      def create_initializer
        say "⚙️  Creating initializer...", :green

        template "initializer.rb", "config/initializers/solidstats.rb"
        say "✅ Created config/initializers/solidstats.rb", :green
      end

      def show_installation_complete
        say "\n🎉 Solidstats installation complete!", :green
        say "━" * 50, :green

        say "\n📍 Next steps:", :cyan
        say "1. Start your Rails server: rails server", :white
        say "2. Visit: http://localhost:3000/solidstats", :white
        say "3. Customize settings in config/initializers/solidstats.rb", :white

        say "\n💡 Asset Delivery:", :cyan
        say "  • CSS and JavaScript are automatically inlined", :white
        say "  • No asset pipeline configuration needed", :white
        say "  • Works with any Rails asset setup", :white

        say "\n📚 Documentation: https://github.com/your-org/solidstats", :cyan
        say "━" * 50, :green
      end

      private

      def css_framework_integration_available?
        %w[bootstrap tailwind].include?(options[:css_framework])
      end
    end
  end
end
