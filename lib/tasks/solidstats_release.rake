namespace :solidstats do
  desc "Build and release the SolidStats gem"
  task :release do
    puts "Starting release process for SolidStats..."

    # Ensure we're in the gem root directory
    gem_root = File.expand_path("../../..", __FILE__)
    Dir.chdir(gem_root) do
      # Double-check version
      require_relative "../../lib/solidstats/version"
      version = Solidstats::VERSION
      puts "Releasing version #{version}..."

      # Clean up any old gem builds
      puts "Cleaning up old gem builds..."
      system "rm -f *.gem"

      # Build the new gem
      puts "Building new gem version..."
      build_output = `gem build solidstats.gemspec`
      puts build_output

      # Get the filename of the newly built gem
      gem_file = build_output.match(/File: (.+\.gem)/)[1] rescue nil

      if gem_file && File.exist?(gem_file)
        puts "Successfully built #{gem_file}"
        puts "\nTo publish the gem to RubyGems, run:"
        puts "  gem push #{gem_file}"
        puts "\nTo install the gem locally, run:"
        puts "  gem install #{gem_file}"
        puts "\nTo verify the gem, run:"
        puts "  gem install -l #{gem_file}"
        puts "  gem list solidstats"
      else
        puts "Error: Failed to build gem properly"
        exit 1
      end
    end
  end

  desc "Verify the gem is ready for release"
  task :verify do
    puts "Verifying SolidStats gem..."

    # Check required files
    required_files = [ "README.md", "CHANGELOG.md", "lib/solidstats/version.rb", "solidstats.gemspec" ]
    missing_files = required_files.reject { |f| File.exist?(f) }

    if missing_files.any?
      puts "Error: Missing required files: #{missing_files.join(', ')}"
      exit 1
    end

    # Check version
    require_relative "../../lib/solidstats/version"
    version = Solidstats::VERSION
    puts "Current version: #{version}"

    # Check changelog
    changelog = File.read("CHANGELOG.md")
    unless changelog.include?("[#{version}]")
      puts "Warning: CHANGELOG.md does not contain an entry for version #{version}"
    end

    puts "Verification completed. Gem appears ready for release."
    puts "To release, run: rake solidstats:release"
  end
end
