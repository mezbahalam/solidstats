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

    # Isolate the Solidstats engine's namespace
    isolate_namespace Solidstats

    # Set up Solidstats asset precompilation
    initializer "solidstats.assets.precompile" do |app|
      app.config.assets.precompile += %w[solidstats/application.css]
    end

    # Automatically run DevLogParserService in the background in development
    initializer "solidstats.dev_log_parser" do |app|
      if Rails.env.development?
        # Ensure this runs after initializers are complete
        app.config.after_initialize do
          # Use a separate thread to avoid blocking server startup
          Thread.new do
            loop do
              Solidstats::LoadLensService.parse_log_and_save
              sleep 1200 # Check every 20 minutes
            end
          end
        end
      end
    end

    private

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
