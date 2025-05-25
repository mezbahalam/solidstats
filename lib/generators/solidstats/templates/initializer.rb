# frozen_string_literal: true

# Solidstats Configuration
# This file configures the Solidstats development dashboard
# Documentation: https://github.com/your-org/solidstats

Solidstats.configure do |config|
  # Cache duration for dashboard data (default: 1 hour)
  # config.cache_duration = 1.hour

  # Enable ViewComponent integration (default: true)
  # config.enable_components = true

  # Log level for Solidstats operations (default: :info)
  # Levels: :debug, :info, :warn, :error
  # config.log_level = :info

  # Enable component previews in development (default: true in development)
  # config.enable_previews = Rails.env.development?

  # Asset configuration for Rails engine compatibility
  config.assets = {
    # Enable asset fingerprinting in production (default: true)
    fingerprint: Rails.env.production?,

    # Asset pipeline strategy (default: :auto)
    # Options: :sprockets, :webpacker, :importmap, :auto (auto-detect)
    strategy: :auto,

    # Enable asset precompilation for production (default: true)
    precompile: true,

    # Compile assets on demand in development (default: true in dev)
    compile_on_demand: Rails.env.development?
  }

  # CSS framework integration (default: :none)
  # Options: :none, :bootstrap, :tailwind
  # config.css_framework = :none

  # Security scan settings
  # config.security = {
  #   # Include retired gems in vulnerability scans (default: true)
  #   include_retired: true,
  #
  #   # Severity levels to report (default: [:high, :medium, :low])
  #   severity_levels: [:high, :medium, :low],
  #
  #   # Cache security scan results (default: 30 minutes)
  #   cache_duration: 30.minutes
  # }

  # Code quality settings
  # config.code_quality = {
  #   # Enable complexity analysis (default: true)
  #   analyze_complexity: true,
  #
  #   # Enable dependency analysis (default: true)
  #   analyze_dependencies: true,
  #
  #   # Paths to exclude from analysis
  #   exclude_paths: ['tmp/', 'log/', 'vendor/']
  # }

  # Task tracking settings
  # config.tasks = {
  #   # Patterns to scan for TODO/FIXME comments
  #   patterns: ['TODO', 'FIXME', 'HACK', 'BUG'],
  #
  #   # File extensions to scan
  #   file_extensions: ['.rb', '.erb', '.js', '.css', '.yml'],
  #
  #   # Paths to exclude from task scanning
  #   exclude_paths: ['vendor/', 'node_modules/', 'tmp/']
  # }

  # Asset configuration (advanced)
  # config.assets = {
  #   # Enable asset fingerprinting in production (default: true)
  #   fingerprint: Rails.env.production?,
  #
  #   # Asset compilation strategy
  #   # Options: :sprockets, :webpacker, :importmap, :auto
  #   strategy: :auto
  # }
end

# Environment-specific configuration
if Rails.env.development?
  # Development-specific settings
  Solidstats.configure do |config|
    config.log_level = :debug
    config.enable_previews = true
  end
end

# Example: Custom CSS framework integration
# Uncomment and modify based on your CSS framework
#
# # Bootstrap integration
# if defined?(Bootstrap)
#   Solidstats.configure do |config|
#     config.css_framework = :bootstrap
#   end
# end
#
# # Tailwind CSS integration
# if Rails.application.config.assets.css_compressor == :tailwindcss
#   Solidstats.configure do |config|
#     config.css_framework = :tailwind
#   end
# end
