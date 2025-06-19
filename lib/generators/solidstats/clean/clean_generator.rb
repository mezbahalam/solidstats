require "rails/generators/base"

module Solidstats
  module Generators
    # This generator cleans up Solidstats data by invoking the Rake task
    #
    # @example
    #   $ rails generate solidstats:clean
    #   or
    #   $ rake solidstats:clean
    class CleanGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Cleans up Solidstats data in your Rails application"

      def run_clean_task
        rake "solidstats:clean"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
