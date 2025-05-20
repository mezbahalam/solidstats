require 'rails/generators/base'

module Solidstats
  module Generators
    # This generator installs Solidstats routes in the host application
    #
    # @example
    #   $ rails generate solidstats:install
    #
    # This will:
    # 1. Add the Solidstats routes to the host application's config/routes.rb
    # 2. Show a helpful README with next steps
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      desc "Adds Solidstats routes to your development application"

      def add_routes
        route_code = <<-RUBY
  # Solidstats Routes (development only)
  mount Solidstats::Engine => "/solidstats" if Rails.env.development?
        RUBY

        route route_code
        say_status :routes, "Mounting Solidstats engine at /solidstats (development environment only)", :green
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
