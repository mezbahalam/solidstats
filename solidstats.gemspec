require_relative "lib/solidstats/version"

Gem::Specification.new do |spec|
  spec.name        = "solidstats"
  spec.version     = Solidstats::VERSION
  spec.authors     = [ "MezbahAlam" ]
  spec.email       = [ "mezbah@infolily.com" ]
  spec.homepage    = "https://solidstats.infolily.com"
  spec.summary     = "Development dashboard for Rails apps"
  spec.description = "View local project health: security dashboard with vulnerability analysis, gem impact assessment, code quality metrics, and project task tracking."
  spec.license     = "MIT"


  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  # Allow Rails 6.1+ but let Ruby version determine max Rails version
  spec.required_ruby_version = ">= 2.7.0"

  # This will use the highest compatible version for the Ruby version
  # Rails 7.0 supports Ruby 2.7+
  # Rails 7.1 supports Ruby 3.0+
  # Rails 8.0 supports Ruby 3.2+
  begin
    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.0.0")
      spec.add_dependency "rails", ">= 6.1", "< 7.1"
    elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.2.0")
      spec.add_dependency "rails", ">= 6.1", "< 8.0"
    else
      spec.add_dependency "rails", ">= 6.1"
    end
  rescue => e
    # In CI, we might get here if something goes wrong with Ruby version detection
    # In that case, use the most conservative constraint
    warn "Warning: Exception during Rails version constraint selection: #{e.message}"
    warn "Defaulting to conservative Rails constraint (>= 6.1, < 7.1)"
    spec.add_dependency "rails", ">= 6.1", "< 7.1"
  end

  spec.add_dependency "bundler-audit"
  spec.add_dependency "standard"
end
