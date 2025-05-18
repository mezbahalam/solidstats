module Solidstats
  class DashboardController < ApplicationController
    AUDIT_CACHE_FILE = Rails.root.join("tmp", "solidstats_audit.json")
    AUDIT_CACHE_HOURS = 12 # Configure how many hours before refreshing

    def index
      @audit_output = fetch_audit_output
      @rubocop_output = "JSON.parse(`rubocop --format json`)"
      @todo_count = `grep -r -E \"TODO|FIXME|HACK\" app lib | wc -l`.to_i
      @coverage = "read_coverage_percent"
    end

    private

    def fetch_audit_output
      # Check if cache file exists and is recent enough
      if File.exist?(AUDIT_CACHE_FILE)
        cached_data = JSON.parse(File.read(AUDIT_CACHE_FILE))
        last_run_time = Time.parse(cached_data["timestamp"])
        
        # Use cached data if it's less than AUDIT_CACHE_HOURS old
        if Time.now - last_run_time < AUDIT_CACHE_HOURS.hours
          return cached_data["output"]
        end
      end

      # Cache expired or doesn't exist, run the audit
      audit_output = `bundle audit check --update`
      
      # Save to cache file with timestamp
      cache_data = {
        "output" => audit_output,
        "timestamp" => Time.now.iso8601
      }
      
      # Ensure the tmp directory exists
      FileUtils.mkdir_p(File.dirname(AUDIT_CACHE_FILE))
      
      # Write the cache file
      File.write(AUDIT_CACHE_FILE, JSON.generate(cache_data))
      
      audit_output
    end

    def read_coverage_percent
      file = Rails.root.join("coverage", ".last_run.json")
      return 0 unless File.exist?(file)

      data = JSON.parse(File.read(file))
      data.dig("result", "covered_percent").to_f.round(2)
    end
  end
end