# frozen_string_literal: true

# Solidstats Asset Manifest
# This file defines all assets that should be precompiled for production deployment
# Compatible with Sprockets, Webpacker, and Importmap

module Solidstats
  class AssetManifest
    # Define all assets that should be precompiled
    PRECOMPILE_ASSETS = [
      # Main application assets
      "solidstats/application.css",
      "solidstats/application.js",
      
      # Component-specific CSS files (using actual filenames)
      "solidstats/components/summary_card.css",
      "solidstats/components/dashboard_layout.css",
      "solidstats/components/tab_navigation.css",
      "solidstats/components/quick_navigation.css",
      "solidstats/components/action_button.css",
      "solidstats/components/dashboard_header.css",
      "solidstats/components/navigation.css",
      "solidstats/components/security.css",
      "solidstats/components/status_badge.css",
      "solidstats/components/dashboard.css"
    ].freeze

    # Assets that should be included in development mode
    DEVELOPMENT_ASSETS = [
      # Preview and development-only assets
      "solidstats/component_preview.css",
      "solidstats/development_toolbar.css"
    ].freeze

    # Image assets to precompile
    IMAGE_ASSETS = [
      # Add image assets here when they exist
      # "solidstats/icons/*.png",
      # "solidstats/logos/*.svg"
    ].freeze

    class << self
      # Get all assets for precompilation based on environment
      # @param environment [String] Rails environment
      # @return [Array<String>] Assets to precompile
      def assets_for_environment(environment = Rails.env)
        assets = PRECOMPILE_ASSETS.dup
        
        if environment == "development"
          assets.concat(DEVELOPMENT_ASSETS)
        end
        
        assets.concat(IMAGE_ASSETS)
        assets.uniq
      end

      # Configure asset precompilation for a Rails application
      # @param app [Rails::Application] Rails application instance
      def configure_precompilation(app)
        return unless app.config.respond_to?(:assets)

        assets_to_add = assets_for_environment - app.config.assets.precompile
        
        assets_to_add.each do |asset|
          app.config.assets.precompile << asset
        end

        # Add asset paths if not already present
        add_asset_paths(app)
        
        Rails.logger.info "[Solidstats] Added #{assets_to_add.size} assets to precompilation list"
      end

      # Add engine asset paths to application
      # @param app [Rails::Application] Rails application instance
      def add_asset_paths(app)
        return unless app.config.respond_to?(:assets)

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
      end

      # Get asset fingerprinting configuration
      # @param environment [String] Rails environment
      # @return [Hash] Fingerprinting configuration
      def fingerprint_config(environment = Rails.env)
        case environment
        when "production"
          {
            digest: true,
            compile: false,
            compress: true,
            gzip: true
          }
        when "staging"
          {
            digest: true,
            compile: false,
            compress: true,
            gzip: false
          }
        when "development"
          {
            digest: false,
            compile: true,
            compress: false,
            gzip: false,
            debug: true
          }
        when "test"
          {
            digest: false,
            compile: true,
            compress: false,
            gzip: false,
            debug: false
          }
        else
          # Default safe configuration
          {
            digest: true,
            compile: false,
            compress: true,
            gzip: false
          }
        end
      end

      # Apply fingerprinting configuration to application
      # @param app [Rails::Application] Rails application instance
      # @param environment [String] Rails environment
      def configure_fingerprinting(app, environment = Rails.env)
        return unless app.config.respond_to?(:assets)

        config = fingerprint_config(environment)
        
        config.each do |key, value|
          if app.config.assets.respond_to?("#{key}=")
            app.config.assets.public_send("#{key}=", value)
          end
        end

        Rails.logger.info "[Solidstats] Applied #{environment} asset fingerprinting configuration"
      end

      # Check if all required assets exist
      # @return [Array<String>] Missing assets
      def missing_assets
        missing = []
        
        PRECOMPILE_ASSETS.each do |asset|
          asset_path = resolve_asset_path(asset)
          unless File.exist?(asset_path)
            missing << asset
          end
        end
        
        missing
      end

      # Validate that all assets are available
      # @raise [Solidstats::Error] If required assets are missing
      def validate_assets!
        missing = missing_assets
        
        unless missing.empty?
          raise Solidstats::Error, 
                "Missing required assets: #{missing.join(', ')}"
        end
        
        true
      end

      private

      # Resolve the file system path for an asset
      # @param asset [String] Asset logical path
      # @return [String] File system path
      def resolve_asset_path(asset)
        # Remove the 'solidstats/' prefix and find the actual file
        relative_path = asset.sub(/^solidstats\//, '')
        
        # Try different possible locations
        possible_paths = [
          Solidstats::Engine.root.join("app", "assets", "stylesheets", "solidstats", relative_path),
          Solidstats::Engine.root.join("app", "assets", "javascripts", "solidstats", relative_path),
          Solidstats::Engine.root.join("app", "assets", "images", "solidstats", relative_path)
        ]
        
        possible_paths.find { |path| File.exist?(path) } || 
          Solidstats::Engine.root.join("app", "assets", "stylesheets", asset).to_s
      end
    end
  end
end
