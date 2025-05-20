# frozen_string_literal: true

module Solidstats
  # Base service class for all data collectors
  # This class handles caching logic and provides a common interface
  # for all data collection services in SolidStats
  class DataCollectorService
    attr_reader :cache_file, :cache_duration

    # Initialize the data collector with cache configuration
    # @param cache_file [String] Path to the cache file
    # @param cache_duration [ActiveSupport::Duration] Duration to keep the cache valid
    def initialize(cache_file, cache_duration = 12.hours)
      @cache_file = cache_file
      @cache_duration = cache_duration
    end

    # Fetch data with caching
    # Returns cached data if available and not expired,
    # otherwise collects fresh data
    # @return [Hash] The collected data
    def fetch
      return cached_data if fresh_cache?

      data = collect_data
      save_to_cache(data)
      data
    end

    # Get a summary of the data for dashboard display
    # @return [Hash] Summary information
    def summary
      raise NotImplementedError, "Subclasses must implement summary"
    end

    private

    # Get data from the cache file
    # @return [Hash, nil] Cached data or nil if cache invalid
    def cached_data
      JSON.parse(File.read(cache_file))["output"]
    rescue StandardError => e
      Rails.logger.error "Error reading cache: #{e.message}"
      nil
    end

    # Check if the cache is fresh (exists and not expired)
    # @return [Boolean] True if cache is valid and not expired
    def fresh_cache?
      return false unless File.exist?(cache_file)

      begin
        cached_data = JSON.parse(File.read(cache_file))
        last_run_time = Time.parse(cached_data["timestamp"])
        Time.now - last_run_time < cache_duration
      rescue StandardError => e
        Rails.logger.error "Error checking cache freshness: #{e.message}"
        false
      end
    end

    # Save data to the cache file
    # @param data [Hash] Data to save to cache
    def save_to_cache(data)
      cache_data = {
        "output" => data,
        "timestamp" => Time.now.iso8601
      }

      FileUtils.mkdir_p(File.dirname(cache_file))
      File.write(cache_file, JSON.generate(cache_data))
    rescue StandardError => e
      Rails.logger.error "Error saving to cache: #{e.message}"
    end

    # Collect fresh data - to be implemented by subclasses
    # @return [Hash] The collected data
    def collect_data
      raise NotImplementedError, "Subclasses must implement collect_data"
    end
  end
end
