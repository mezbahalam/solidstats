module Solidstats
  class Engine < ::Rails::Engine
    isolate_namespace Solidstats

    initializer "solidstats.only_in_dev" do
      unless Rails.env.development?
        raise "Solidstats can only be used in development mode."
      end
    end

    initializer "solidstats.assets.precompile" do |app|
      if Rails.env.development?
        app.config.assets.precompile += %w[ solidstats/application.css ]
      end
    end
    
    # Load the solidstats rake tasks
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "../tasks/**/*.rake")].each { |f| load f }
    end
  end
end
