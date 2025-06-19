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

    private

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
