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
        return if options[:skip_assets]
        
        say "📦 Configuring assets...", :green
        
        configure_sprockets if sprockets_available?
        configure_importmap if importmap_available?
        configure_webpacker if webpacker_available?
        
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
        
        if css_framework_integration_available?
          say "\n🎨 CSS Framework Integration:", :cyan
          show_css_framework_instructions
        end
        
        say "\n📚 Documentation: https://github.com/your-org/solidstats", :cyan
        say "━" * 50, :green
      end

      private

      def sprockets_available?
        defined?(Sprockets)
      end

      def importmap_available?
        defined?(Importmap) && File.exist?("config/importmap.rb")
      end

      def webpacker_available?
        defined?(Webpacker) && File.exist?("config/webpacker.yml")
      end

      def css_framework_integration_available?
        %w[bootstrap tailwind].include?(options[:css_framework])
      end

      def configure_sprockets
        say "  📄 Configuring Sprockets...", :blue
        
        # Add to application.css if it exists
        app_css_path = "app/assets/stylesheets/application.css"
        if File.exist?(app_css_path)
          css_content = File.read(app_css_path)
          unless css_content.include?("solidstats/application")
            append_to_file app_css_path, "\n/*\n *= require solidstats/application\n */"
            say "    ✅ Added to #{app_css_path}", :green
          end
        end
        
        # Add to application.js if it exists
        app_js_path = "app/assets/javascripts/application.js"
        if File.exist?(app_js_path)
          js_content = File.read(app_js_path)
          unless js_content.include?("solidstats/application")
            append_to_file app_js_path, "\n//= require solidstats/application\n"
            say "    ✅ Added to #{app_js_path}", :green
          end
        end
      end

      def configure_importmap
        say "  🗺️  Configuring Importmap...", :blue
        
        importmap_content = <<~RUBY
          # Solidstats assets
          pin "solidstats", to: "solidstats/application.js"
        RUBY
        
        append_to_file "config/importmap.rb", importmap_content
        say "    ✅ Added to config/importmap.rb", :green
      end

      def configure_webpacker
        say "  📦 Configuring Webpacker...", :blue
        say "    ℹ️  Manual configuration required for Webpacker", :yellow
        say "    Add this to your pack file:", :yellow
        say "    import 'solidstats/application'", :white
      end

      def show_css_framework_instructions
        case options[:css_framework]
        when "bootstrap"
          say "  • Bootstrap classes are automatically supported", :white
          say "  • Ensure Bootstrap is loaded before Solidstats", :white
        when "tailwind"
          say "  • Add Solidstats paths to tailwind.config.js:", :white
          say "    content: [..., './gems/solidstats/**/*.{erb,html,rb}']", :white
        end
      end
    end
  end
end
