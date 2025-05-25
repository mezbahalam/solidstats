# frozen_string_literal: true

module Solidstats
  # Asset compatibility layer for Rails engines
  # Provides universal asset loading across different Rails asset pipelines
  module AssetCompatibility
    extend self

    # Include engine assets in host application
    # @param app [Rails::Application] Rails application instance
    def setup_assets(app)
      detect_asset_pipeline(app, force_refresh: true)
      configure_asset_pipeline(app)
      add_asset_helpers(app)
    end

    # Detect which asset pipeline is being used
    # @param app [Rails::Application] Rails application instance
    # @param force_refresh [Boolean] Force refresh of cached detection
    # @return [Symbol] Detected pipeline (:propshaft, :sprockets, :webpacker, :importmap, :unknown)
    def detect_asset_pipeline(app, force_refresh: false)
      if force_refresh
        @pipeline = nil
      end

      @pipeline ||= begin
        if propshaft_available?(app)
          :propshaft
        elsif importmap_available?(app)
          :importmap
        elsif webpacker_available?(app)
          :webpacker
        elsif sprockets_available?(app)
          :sprockets
        else
          :unknown
        end
      end
    end

    # Configure the detected asset pipeline
    # @param app [Rails::Application] Rails application instance
    def configure_asset_pipeline(app)
      case detect_asset_pipeline(app)
      when :propshaft
        configure_propshaft(app)
      when :sprockets
        configure_sprockets(app)
      when :webpacker
        configure_webpacker(app)
      when :importmap
        configure_importmap(app)
      when :unknown
        Solidstats.logger.warn "[Solidstats] No supported asset pipeline detected"
      end
    end

    # Add universal asset helper methods
    # @param app [Rails::Application] Rails application instance
    def add_asset_helpers(app)
      return unless defined?(ActionView::Base)

      ActionView::Base.class_eval do
        # Universal stylesheet helper for Solidstats
        def solidstats_stylesheets(*args)
          options = args.extract_options!
          strategy = Solidstats.asset_strategy

          case strategy
          when :importmap, :sprockets, :propshaft
            stylesheet_link_tag "solidstats/application", **options
          when :webpacker
            if respond_to?(:stylesheet_pack_tag)
              stylesheet_pack_tag "solidstats/application", **options
            else
              stylesheet_link_tag "solidstats/application", **options
            end
          else
            stylesheet_link_tag "solidstats/application", **options
          end
        end

        # Universal javascript helper for Solidstats
        def solidstats_javascripts(*args)
          options = args.extract_options!
          strategy = Solidstats.asset_strategy

          case strategy
          when :importmap
            javascript_importmap_tags
            javascript_include_tag "solidstats", **options
          when :webpacker
            if respond_to?(:javascript_pack_tag)
              javascript_pack_tag "solidstats/application", **options
            else
              javascript_include_tag "solidstats/application", **options
            end
          when :sprockets, :propshaft
            javascript_include_tag "solidstats/application", **options
          else
            javascript_include_tag "solidstats/application", **options
          end
        end

        # Convenience method to include all Solidstats assets
        def solidstats_assets(*args)
          options = args.extract_options!

          content = []
          content << solidstats_stylesheets(**options.slice(:media, :crossorigin))
          content << solidstats_javascripts(**options.slice(:defer, :async, :crossorigin))

          safe_join(content, "\n")
        end
      end

      Solidstats.logger.info "[Solidstats] Added universal asset helpers"
    rescue => e
      Solidstats.logger.warn "[Solidstats] Could not add asset helpers: #{e.message}"
    end

    private

    # Check if Propshaft is available
    def propshaft_available?(app)
      defined?(Propshaft) && app.config.respond_to?(:assets) &&
        app.assets.is_a?(Propshaft::Assembly)
    end

    # Check if Importmap is available
    def importmap_available?(app)
      defined?(Importmap) &&
        app.config.respond_to?(:importmap) &&
        File.exist?(Rails.root.join("config/importmap.rb"))
    end

    # Check if Webpacker is available
    def webpacker_available?(app)
      defined?(Webpacker) &&
        app.config.respond_to?(:webpacker) &&
        File.exist?(Rails.root.join("config/webpacker.yml"))
    end

    # Check if Sprockets is available
    def sprockets_available?(app)
      defined?(Sprockets) && app.config.respond_to?(:assets) &&
        !propshaft_available?(app)
    end

    # Configure Propshaft asset pipeline
    def configure_propshaft(app)
      return unless app.config.respond_to?(:assets)

      # Add engine asset paths
      engine_paths = [
        Solidstats::Engine.root.join("app", "assets", "stylesheets"),
        Solidstats::Engine.root.join("app", "assets", "javascripts"),
        Solidstats::Engine.root.join("app", "assets", "images")
      ]

      engine_paths.each do |path|
        path_str = path.to_s
        unless app.config.assets.paths.include?(path_str)
          app.config.assets.paths << path_str
        end
      end

      # Add to precompile list
      precompile_assets = [
        "solidstats/application.css",
        "solidstats/application.js"
      ]

      precompile_assets.each do |asset|
        unless app.config.assets.precompile.include?(asset)
          app.config.assets.precompile << asset
        end
      end

      Solidstats.logger.info "[Solidstats] Configured Propshaft asset pipeline"
    end

    # Configure Sprockets asset pipeline
    def configure_sprockets(app)
      return unless app.config.respond_to?(:assets)

      # Add engine asset paths
      engine_paths = [
        Solidstats::Engine.root.join("app", "assets", "stylesheets"),
        Solidstats::Engine.root.join("app", "assets", "javascripts"),
        Solidstats::Engine.root.join("app", "assets", "images")
      ]

      engine_paths.each do |path|
        path_str = path.to_s
        unless app.config.assets.paths.include?(path_str)
          app.config.assets.paths << path_str
        end
      end

      # Add to precompile list
      precompile_assets = [
        "solidstats/application.css",
        "solidstats/application.js"
      ]

      precompile_assets.each do |asset|
        unless app.config.assets.precompile.include?(asset)
          app.config.assets.precompile << asset
        end
      end

      Solidstats.logger.info "[Solidstats] Configured Sprockets asset pipeline"
    end

    # Configure Webpacker asset pipeline
    def configure_webpacker(app)
      # Webpacker configuration is more complex and typically requires
      # manual setup in the host application
      Solidstats.logger.info "[Solidstats] Webpacker detected - manual configuration may be required"

      # Add source path if possible
      if app.config.webpacker.respond_to?(:source_path)
        engine_source = Solidstats::Engine.root.join("app", "javascript")
        if engine_source.exist?
          Solidstats.logger.info "[Solidstats] Engine JavaScript available at: #{engine_source}"
        end
      end
    end

    # Configure Importmap asset pipeline
    def configure_importmap(app)
      # Importmap configuration is handled through config/importmap.rb
      # The generator should add the appropriate pin statements
      Solidstats.logger.info "[Solidstats] Importmap detected - configuration in config/importmap.rb"
    end
  end
end
