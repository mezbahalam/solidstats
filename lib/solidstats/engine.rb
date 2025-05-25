# frozen_string_literal: true

require "rails/engine" if defined?(Rails)

module Solidstats
  class Engine < ::Rails::Engine
    isolate_namespace Solidstats if defined?(Rails)

    # Engine configuration
    config.solidstats = ActiveSupport::OrderedOptions.new

    # Set default configuration values
    config.before_configuration do
      config.solidstats.cache_duration = 1.hour
      config.solidstats.enable_components = true
      config.solidstats.log_level = :info
      config.solidstats.enable_previews = Rails.env.development?
    end

    # Ensure gem only runs in development environment
    initializer "solidstats.environment_check", before: :load_config_initializers do
      unless Rails.env.development?
        raise Solidstats::ConfigurationError, 
              "Solidstats can only be used in development mode. Current environment: #{Rails.env}"
      end
    end

    # Load and configure ViewComponent if available
    initializer "solidstats.setup_view_component", after: :load_config_initializers do |app|
      setup_view_component(app) if view_component_available?
    end

    # Add custom paths for autoloading
    initializer "solidstats.autoload_paths" do |app|
      app.config.autoload_paths += Dir[Engine.root.join("app", "components", "**")]
      app.config.autoload_paths += Dir[Engine.root.join("app", "services", "**")]
    end

    # Load custom rake tasks
    rake_tasks do
      load_rake_tasks
    end

    # Add custom generators path
    config.generators do |g|
      g.test_framework :minitest, spec: false, fixture: false
    end

    private

    # Check if ViewComponent is available and properly loaded
    # @return [Boolean] true if ViewComponent is available
    def view_component_available?
      defined?(ViewComponent::Base) && Solidstats.view_component_available?
    end

    # Configure ViewComponent integration
    # @param app [Rails::Application] Rails application instance
    def setup_view_component(app)
      log_info "🔍 Solidstats: Setting up ViewComponent integration..."

      begin
        version = ViewComponent::VERSION rescue "unknown"
        log_info "✅ ViewComponent #{version} detected and configured"

        configure_view_component_settings(app)
        setup_preview_paths(app)
        
        log_info "🎯 ViewComponent::Base: #{ViewComponent::Base}"
      rescue StandardError => e
        log_error "❌ ViewComponent setup failed: #{e.message}"
        raise Solidstats::ComponentError, "Failed to configure ViewComponent: #{e.message}"
      end
    end

    # Configure ViewComponent specific settings
    # @param app [Rails::Application] Rails application instance
    def configure_view_component_settings(app)
      return unless app.config.respond_to?(:view_component)

      view_component_config = app.config.view_component
      view_component_config.show_previews = config.solidstats.enable_previews
      view_component_config.default_preview_layout = "solidstats/component_preview"
      
      # Set preview controller if not already set
      unless view_component_config.preview_controller
        view_component_config.preview_controller = "Solidstats::ComponentPreviewsController"
      end
    end

    # Setup preview paths for component development
    # @param app [Rails::Application] Rails application instance
    def setup_preview_paths(app)
      return unless app.config.respond_to?(:view_component) && config.solidstats.enable_previews

      preview_path = Engine.root.join("app", "components", "solidstats", "previews")
      
      unless app.config.view_component.preview_paths.include?(preview_path)
        app.config.view_component.preview_paths << preview_path
        log_info "📁 Added preview path: #{preview_path}"
      end
    end

    # Load custom rake tasks
    def load_rake_tasks
      task_files = Dir[Engine.root.join("lib", "tasks", "**", "*.rake")]
      task_files.each { |file| load file }
      
      log_info "📋 Loaded #{task_files.size} rake task(s)" if task_files.any?
    rescue StandardError => e
      log_error "Failed to load rake tasks: #{e.message}"
    end

    # Logging helpers with consistent formatting
    def log_info(message)
      Rails.logger&.info("[Solidstats] #{message}")
    end

    def log_error(message)
      Rails.logger&.error("[Solidstats] #{message}")
    end

    def log_debug(message)
      Rails.logger&.debug("[Solidstats] #{message}")
    end
  end
end
