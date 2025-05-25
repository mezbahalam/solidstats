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

    # Add asset paths early in the initialization process - compatible with all asset pipelines
    initializer "solidstats.asset_paths", before: "sprockets.environment" do |app|
      configure_asset_paths(app)
    end

    # Configure assets for the engine - supports all Rails asset compilation strategies
    initializer "solidstats.assets", after: "solidstats.asset_paths" do |app|
      configure_assets(app)
    end

    # Setup asset compatibility layer
    initializer "solidstats.setup_assets", after: "solidstats.assets" do |app|
      begin
        if defined?(Solidstats::AssetCompatibility)
          Solidstats::AssetCompatibility.setup_assets(app)
        else
          log_info "⚠️  AssetCompatibility not available, skipping setup"
        end
      rescue => e
        log_error "Failed to setup asset compatibility: #{e.message}"
      end
    end

    # Configure asset precompilation for production
    initializer "solidstats.asset_precompilation", after: "solidstats.setup_assets" do |app|
      begin
        if defined?(Solidstats::AssetManifest)
          Solidstats::AssetManifest.configure_precompilation(app)
          Solidstats::AssetManifest.configure_fingerprinting(app)
        else
          # Fallback to basic precompilation configuration
          configure_asset_precompilation(app)
        end
      rescue => e
        log_error "Failed to configure asset precompilation: #{e.message}"
        # Fallback to basic configuration
        configure_asset_precompilation(app)
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

    # Configure asset paths for all asset pipeline types
    # @param app [Rails::Application] Rails application instance
    def configure_asset_paths(app)
      # Standard Sprockets asset paths
      if app.config.respond_to?(:assets)
        asset_paths = [
          Engine.root.join("app", "assets", "stylesheets"),
          Engine.root.join("app", "assets", "javascripts"), 
          Engine.root.join("app", "assets", "images")
        ]
        
        asset_paths.each do |path|
          path_str = path.to_s
          unless app.config.assets.paths.include?(path_str)
            app.config.assets.paths << path_str
          end
        end
        
        log_info "📁 Added Sprockets asset paths to Rails application"
      end

      # Webpacker compatibility (for older Rails apps)
      if defined?(Webpacker) && app.config.respond_to?(:webpacker)
        begin
          webpacker_config = app.config.webpacker
          engine_source_path = Engine.root.join("app", "javascript")
          
          if engine_source_path.exist? && webpacker_config.respond_to?(:source_path)
            log_info "📦 Webpacker detected - engine assets available at #{engine_source_path}"
          end
        rescue => e
          log_info "⚠️  Webpacker configuration skipped: #{e.message}"
        end
      end

      # Importmap compatibility (for Rails 7+)
      if defined?(Importmap) && app.config.respond_to?(:importmap)
        log_info "🗺️  Importmap detected - assets will be served via standard asset pipeline"
      end
    end

    # Configure assets for the engine - universal compatibility
    # @param app [Rails::Application] Rails application instance
    def configure_assets(app)
      return unless app.config.respond_to?(:assets)

      # Environment-specific asset configuration
      if Rails.env.development?
        app.config.assets.compile = true
        app.config.assets.debug = true
        app.config.assets.digest = false
        log_info "🔧 Development asset configuration applied"
      elsif Rails.env.production?
        app.config.assets.compile = false
        app.config.assets.digest = true
        app.config.assets.compress = true
        log_info "🏭 Production asset configuration applied"
      end

      # Ensure asset compilation works across different setups
      configure_asset_serving(app)
    end

    # Configure asset precompilation list
    # @param app [Rails::Application] Rails application instance  
    def configure_asset_precompilation(app)
      return unless app.config.respond_to?(:assets)

      # Assets that should be precompiled
      assets_to_precompile = [
        "solidstats/application.css",
        "solidstats/application.js"
      ]

      # Add component-specific assets
      begin
        component_assets = Dir[Engine.root.join("app", "assets", "stylesheets", "solidstats", "components", "*.css")]
        component_assets.each do |asset|
          asset_name = "solidstats/components/#{File.basename(asset)}"
          assets_to_precompile << asset_name unless assets_to_precompile.include?(asset_name)
        end
      rescue => e
        log_error "Failed to load component assets: #{e.message}"
      end

      # Add to precompile list
      assets_to_precompile.each do |asset|
        unless app.config.assets.precompile.include?(asset)
          app.config.assets.precompile << asset
        end
      end
      
      log_info "📦 Assets configured for precompilation: #{assets_to_precompile.join(', ')}"
    end

    # Configure asset serving strategies
    # @param app [Rails::Application] Rails application instance
    def configure_asset_serving(app)
      # Ensure proper asset serving in engines
      if app.config.assets.respond_to?(:prefix)
        log_info "🌐 Asset prefix: #{app.config.assets.prefix}"
      end

      # Add engine-specific asset resolver if needed
      if defined?(ActionController::Base)
        add_asset_helpers
      end
    end

    # Add asset helper methods for easy integration
    def add_asset_helpers
      return unless defined?(ActionView::Base)

      ActionView::Base.class_eval do
        def solidstats_stylesheet_link_tag(*args)
          options = args.extract_options!
          sources = args.map { |source| "solidstats/#{source}" }
          stylesheet_link_tag(*sources, **options)
        end

        def solidstats_javascript_include_tag(*args) 
          options = args.extract_options!
          sources = args.map { |source| "solidstats/#{source}" }
          javascript_include_tag(*sources, **options)
        end
      end

      log_info "🎨 Added Solidstats asset helper methods"
    rescue => e
      log_info "⚠️  Asset helper setup skipped: #{e.message}"
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
