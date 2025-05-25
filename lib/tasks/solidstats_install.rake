
# frozen_string_literal: true

namespace :solidstats do
  desc "Install Solidstats in the current Rails application"
  task :install do
    puts "🚀 Installing Solidstats..."

    # Check Rails environment
    unless Rails.env.development?
      puts "⚠️  Warning: Solidstats is designed for development environments."
      puts "Current environment: #{Rails.env}"
    end

    # Run the generator
    if system("rails generate solidstats:install")
      puts "\n✅ Solidstats installation completed successfully!"
      puts "   Start your Rails server and visit http://localhost:3000/solidstats\n\n"
    else
      puts "\n❌ Solidstats installation failed. Please try running manually:"
      puts "   bundle exec rails generate solidstats:install\n\n"
    end
  end

  desc "Validate Solidstats installation and configuration"
  task validate: :environment do
    puts "🔍 Validating Solidstats installation..."

    begin
      # Check basic configuration
      Solidstats.configuration
      puts "✅ Configuration loaded"

      # Check ViewComponent availability
      if Solidstats.view_component_available?
        version = defined?(ViewComponent::VERSION) ? ViewComponent::VERSION : "unknown"
        puts "✅ ViewComponent available (#{version})"
      else
        puts "❌ ViewComponent not available"
      end

      # Check asset strategy
      strategy = Solidstats.asset_strategy
      puts "✅ Asset strategy: #{strategy}"

      # Validate asset manifest
      Solidstats::AssetManifest.validate_assets!
      puts "✅ All required assets present"

      # Check routes
      if Rails.application.routes.routes.any? { |r| r.path.spec.to_s.include?("solidstats") }
        puts "✅ Routes mounted"
      else
        puts "⚠️  Routes not mounted - add 'mount Solidstats::Engine => \"/solidstats\"' to config/routes.rb"
      end

      puts "\n🎉 Solidstats validation complete!"

    rescue => e
      puts "❌ Validation failed: #{e.message}"
      exit 1
    end
  end

  desc "Show asset configuration information"
  task assets: :environment do
    puts "📦 Solidstats Asset Configuration"
    puts "=" * 40

    puts "Asset Strategy: #{Solidstats.asset_strategy}"
    puts "Fingerprinting: #{Solidstats.asset_fingerprinting?}"
    puts "Asset Prefix: #{Solidstats.asset_prefix}"

    puts "\nPrecompiled Assets:"
    Solidstats::AssetManifest.assets_for_environment.each do |asset|
      puts "  • #{asset}"
    end

    if Rails.application.config.respond_to?(:assets)
      puts "\nAsset Paths:"
      Rails.application.config.assets.paths.select { |p| p.include?("solidstats") }.each do |path|
        puts "  • #{path}"
      end
    end
  end

  desc "Test asset compilation"
  task compile_assets: :environment do
    puts "🔧 Testing asset compilation..."

    begin
      test_assets = [ "solidstats/application.css", "solidstats/application.js" ]

      if Rails.application.config.respond_to?(:assets)
        manifest = Rails.application.assets

        # Check if we're using Propshaft (Rails 7+) or Sprockets
        if manifest.respond_to?(:find_asset)
          # Sprockets
          test_assets.each do |asset|
            if manifest.find_asset(asset)
              puts "✅ #{asset} - found and compilable (Sprockets)"
            else
              puts "❌ #{asset} - not found (Sprockets)"
            end
          end
        elsif manifest.respond_to?(:load_path) && manifest.load_path.respond_to?(:find)
          # Propshaft
          test_assets.each do |asset|
            if manifest.load_path.find(asset)
              puts "✅ #{asset} - found and compilable (Propshaft)"
            else
              puts "❌ #{asset} - not found (Propshaft)"
            end
          end
        else
          # Unknown asset pipeline
          puts "⚠️  Unknown asset pipeline type: #{manifest.class}"
          puts "Available methods: #{manifest.methods.grep(/find/).join(', ')}"
        end
      else
        puts "⚠️  No asset pipeline detected"
      end

      puts "✅ Asset compilation test complete"

    rescue => e
      puts "❌ Asset compilation failed: #{e.message}"
      puts "Asset pipeline class: #{Rails.application.assets.class}" if Rails.application.respond_to?(:assets)
      exit 1
    end
  end
end
