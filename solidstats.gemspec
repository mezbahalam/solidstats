require_relative "lib/solidstats/version"

Gem::Specification.new do |spec|
  spec.name        = "solidstats"
  spec.version     = Solidstats::VERSION
  spec.authors     = [ "MezbahAlam" ]
  spec.email       = [ "mezbah@infolily.com" ]
  spec.homepage    = "solidstats.infolily.com"
  spec.summary     = "Development dashboard for Rails apps"
  spec.description = "View local project health: secuiry, lints, performance, and more."
  spec.license     = "MIT"


  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
end
