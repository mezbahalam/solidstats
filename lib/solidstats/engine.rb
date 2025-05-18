module Solidstats
  class Engine < ::Rails::Engine
    isolate_namespace Solidstats

    initializer "solidstats.only_in_dev" do
      unless Rails.env.development?
        raise "Solidstats can only be used in development mode."
      end
    end
  end
end
