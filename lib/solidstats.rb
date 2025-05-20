require "solidstats/version"
require "solidstats/engine"

module Solidstats
  class << self
    # Returns the absolute path to this gem's root directory
    # @return [String] Gem root path
    def root
      File.dirname(__dir__)
    end

    # Returns version string
    # @return [String] Version
    def version
      VERSION
    end
  end
end
