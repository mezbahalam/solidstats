# frozen_string_literal: true

require "solidstats/version"
require "solidstats/engine"
require "solidstats/asset_compatibility"
require "solidstats/asset_manifest"

module Solidstats
  # Base error class for all Solidstats-specific errors
  class Error < StandardError; end

  # Configuration-related errors
  class ConfigurationError < Error; end

  # Component-related errors
  class ComponentError < Error; end

  # Service-related errors
  class ServiceError < Error; end

  class << self
    # Returns the absolute path to this gem's root directory
    # @return [Pathname] Gem root path
    def root
      @root ||= Pathname.new(File.dirname(__dir__))
    end

    # Returns version string
    # @return [String] Version
    def version
      VERSION
    end

    # Returns the gem's app directory
    # @return [Pathname] App directory path
    def app_path
      @app_path ||= root.join("app")
    end

    # Returns the components directory
    # @return [Pathname] Components directory path
    def components_path
      @components_path ||= app_path.join("components", "solidstats")
    end

    # Returns the services directory
    # @return [Pathname] Services directory path
    def services_path
      @services_path ||= app_path.join("services", "solidstats")
    end

    # Check if ViewComponent is available and properly loaded
    # @return [Boolean] True if ViewComponent is loaded and usable
    def view_component_available?
      defined?(ViewComponent::Base) &&
        ViewComponent::Base.respond_to?(:new) &&
        defined?(Rails)
    end

    # Safely load ViewComponent if not already loaded
    # @return [Boolean] True if ViewComponent was loaded successfully
    def ensure_view_component!
      return true if view_component_available?

      unless defined?(Rails)
        logger.warn "[Solidstats] Rails not available - ViewComponent cannot be loaded"
        return false
      end

      begin
        require "view_component"
        require "view_component/engine"

        # Verify it loaded correctly
        if view_component_available?
          logger.info "[Solidstats] ViewComponent loaded successfully"
          true
        else
          logger.error "[Solidstats] ViewComponent loaded but not properly initialized"
          false
        end
      rescue LoadError => e
        logger.warn "[Solidstats] ViewComponent not available: #{e.message}"
        false
      rescue StandardError => e
        logger.error "[Solidstats] Failed to load ViewComponent: #{e.message}"
        false
      end
    end

    # Check if running in development mode
    # @return [Boolean] True if in development
    def development?
      defined?(Rails) && Rails.env.development?
    end

    # Check if running in production mode
    # @return [Boolean] True if in production
    def production?
      defined?(Rails) && Rails.env.production?
    end

    # Check if running in test mode
    # @return [Boolean] True if in test
    def test?
      defined?(Rails) && Rails.env.test?
    end

    # Current Rails environment
    # @return [String, nil] Environment name or nil if Rails not available
    def environment
      Rails.env if defined?(Rails)
    end

    # Configuration object for the gem
    # @return [Configuration] Configuration instance
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure the gem with a block
    # @yield [Configuration] Configuration object
    # @example
    #   Solidstats.configure do |config|
    #     config.cache_duration = 30.minutes
    #     config.enable_components = true
    #   end
    def configure
      yield(configuration) if block_given?
      configuration
    end

    # Reset configuration to defaults
    # @return [Configuration] New configuration instance
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Logger instance with fallback
    # @return [Logger] Logger instance
    def logger
      @logger ||= build_logger
    end

    # Set a custom logger
    # @param custom_logger [Logger] Custom logger instance
    def logger=(custom_logger)
      @logger = custom_logger
    end

    # Check if Solidstats can run in current environment
    # @return [Boolean] True if environment is suitable
    # @raise [ConfigurationError] If environment is not suitable
    def environment_suitable?
      unless development?
        raise ConfigurationError,
              "Solidstats can only be used in development mode. Current: #{environment || 'unknown'}"
      end

      true
    end

    # Get engine instance
    # @return [Solidstats::Engine] Engine instance
    def engine
      Engine
    end

    # Get asset strategy for current application
    # @return [Symbol] Asset strategy (:sprockets, :webpacker, :importmap, :auto)
    def asset_strategy
      return configuration.assets[:strategy] if configuration.assets[:strategy] != :auto

      # Auto-detect asset strategy
      if defined?(Importmap) && File.exist?(Rails.root.join("config/importmap.rb"))
        :importmap
      elsif defined?(Webpacker) && File.exist?(Rails.root.join("config/webpacker.yml"))
        :webpacker
      elsif defined?(Sprockets)
        :sprockets
      else
        :none
      end
    end

    # Check if assets should be fingerprinted
    # @return [Boolean] True if fingerprinting is enabled
    def asset_fingerprinting?
      configuration.assets[:fingerprint] && !Rails.env.development?
    end

    # Get the asset prefix for engine assets
    # @return [String] Asset prefix
    def asset_prefix
      case asset_strategy
      when :importmap, :sprockets
        "solidstats"
      when :webpacker
        "solidstats"
      else
        "solidstats"
      end
    end

    private

    # Build appropriate logger based on environment
    # @return [Logger] Logger instance
    def build_logger
      if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
        Rails.logger
      else
        require "logger"
        Logger.new($stdout, level: Logger::INFO).tap do |log|
          log.formatter = proc do |severity, datetime, progname, msg|
            "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
          end
        end
      end
    end
  end

  # Configuration class for Solidstats gem
  class Configuration
    # @!attribute [rw] cache_duration
    #   @return [ActiveSupport::Duration] Cache duration for services
    attr_accessor :cache_duration

    # @!attribute [rw] enable_components
    #   @return [Boolean] Whether to enable ViewComponent integration
    attr_accessor :enable_components

    # @!attribute [rw] log_level
    #   @return [Symbol] Logging level
    attr_accessor :log_level

    # @!attribute [rw] enable_previews
    #   @return [Boolean] Whether to enable component previews
    attr_accessor :enable_previews

    # @!attribute [rw] preview_layout
    #   @return [String] Layout for component previews
    attr_accessor :preview_layout

    # @!attribute [rw] assets
    #   @return [Hash] Asset configuration options
    attr_accessor :assets

    # @!attribute [rw] css_framework
    #   @return [Symbol] CSS framework integration (:none, :bootstrap, :tailwind)
    attr_accessor :css_framework

    def initialize
      set_defaults
    end

    # Check if components are enabled and available
    # @return [Boolean] True if components can be used
    def components_enabled?
      @enable_components && Solidstats.view_component_available?
    end

    # Check if previews are enabled
    # @return [Boolean] True if previews should be shown
    def previews_enabled?
      @enable_previews && Solidstats.development?
    end

    # Validate configuration
    # @return [Boolean] True if configuration is valid
    # @raise [ConfigurationError] If configuration is invalid
    def validate!
      unless cache_duration.respond_to?(:seconds)
        raise ConfigurationError, "cache_duration must be a time duration"
      end

      unless [ :debug, :info, :warn, :error, :fatal, :unknown ].include?(@log_level)
        raise ConfigurationError, "log_level must be a valid log level symbol"
      end

      true
    end

    private

    def set_defaults
      @cache_duration = 1.hour
      @enable_components = true
      @log_level = :info
      @enable_previews = true
      @preview_layout = "solidstats/component_preview"
      @assets = {
        fingerprint: true,
        strategy: :auto,
        precompile: true,
        compile_on_demand: Rails.env.development?
      }
      @css_framework = :none
    end
  end
end

# Auto-require common dependencies if in Rails environment
if defined?(Rails) && Rails.env.development?
  # Ensure ViewComponent is available
  Solidstats.ensure_view_component!

  # Auto-require core services that are commonly used
  begin
    require_relative "solidstats/gem_metadata/fetcher_service" if
      File.exist?(File.join(__dir__, "solidstats/gem_metadata/fetcher_service.rb"))
  rescue LoadError => e
    Solidstats.logger.debug "[Solidstats] Could not auto-load services: #{e.message}"
  end
end
