require "solidstats/version"
require "solidstats/engine"

# Top-level module for Solidstats gem
module Solidstats
  # Gem setup
  extend self

  # Gem version
  def version
    VERSION
  end

  # Simple logger for internal use
  def logger
    @logger ||= Logger.new($stdout)
  end

  # Error classes for Solidstats specific exceptions
  class Error < StandardError; end
  class ComponentError < Error; end
  class ServiceError < Error; end

  # Load and initialize Solidstats in a Rails environment
  def self.load!
    nil unless defined?(Rails)
  end
end

# Load Solidstats automatically when Rails is loaded
Solidstats.load! if defined?(Rails)
