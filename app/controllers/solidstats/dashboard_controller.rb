module Solidstats
  class DashboardController < ApplicationController
    AUDIT_CACHE_FILE = Rails.root.join("tmp", "solidstats_audit.json")
    TODO_CACHE_FILE = Rails.root.join("tmp", "solidstats_todos.json")
    AUDIT_CACHE_HOURS = 12 # Configure how many hours before refreshing

    def index
      @audit_output = fetch_audit_output
      @rubocop_output = "JSON.parse(`rubocop --format json`)"
      @todo_items = fetch_todo_items
      @todo_stats = calculate_todo_stats(@todo_items)
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
      raw_output = `bundle audit check --update --format json`
      json_part = raw_output[/\{.*\}/m] # extract JSON starting from first '{'
      audit_output = JSON.parse(json_part) rescue { error: "Failed to parse JSON" }

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

    def fetch_todo_items
      # Check if cache file exists and is recent enough
      if File.exist?(TODO_CACHE_FILE)
        cached_data = JSON.parse(File.read(TODO_CACHE_FILE))
        last_run_time = Time.parse(cached_data["timestamp"])

        # Use cached data if it's less than AUDIT_CACHE_HOURS old
        if Time.now - last_run_time < AUDIT_CACHE_HOURS.hours
          return cached_data["output"]
        end
      end

      todos = []
      # Updated grep pattern to match only all-uppercase or all-lowercase variants
      raw_output = `grep -r -n -E "(TODO|FIXME|HACK|todo|fixme|hack)" app lib`.split("\n")

      raw_output.each do |line|
        if line =~ /^(.+):(\d+):(.+)$/
          file = $1
          line_num = $2
          content = $3

          # Match only exact lowercase or uppercase variants
          type_match = content.match(/(TODO|FIXME|HACK|todo|fixme|hack)/)
          if type_match
            # Convert to uppercase for consistency
            type = type_match.to_s.upcase

            todos << {
              file: file,
              line: line_num.to_i,
              content: content.strip,
              type: type
            }
          end
        end
      end

      # Save to cache file with timestamp
      cache_data = {
        "output" => todos,
        "timestamp" => Time.now.iso8601
      }

      # Ensure the tmp directory exists
      FileUtils.mkdir_p(File.dirname(TODO_CACHE_FILE))

      # Write the cache file
      File.write(TODO_CACHE_FILE, JSON.generate(cache_data))

      todos
    end

    def calculate_todo_stats(todos)
      return {} if todos.nil? || todos.empty?

      stats = {
        total: todos.count,
        by_type: {
          "TODO" => todos.count { |t| t[:type] == "TODO" },
          "FIXME" => todos.count { |t| t[:type] == "FIXME" },
          "HACK" => todos.count { |t| t[:type] == "HACK" }
        },
        by_file: {}
      }

      # Group by file path
      todos.each do |todo|
        file_path = todo[:file]
        stats[:by_file][file_path] ||= 0
        stats[:by_file][file_path] += 1
      end

      # Find files with most TODOs (top 5)
      stats[:hotspots] = stats[:by_file].sort_by { |_, count| -count }
                                       .first(5)
                                       .to_h

      stats
    end

    def read_coverage_percent
      file = Rails.root.join("coverage", ".last_run.json")
      return 0 unless File.exist?(file)

      data = JSON.parse(File.read(file))
      data.dig("result", "covered_percent").to_f.round(2)
    end
  end
end
