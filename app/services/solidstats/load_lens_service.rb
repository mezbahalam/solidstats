# frozen_string_literal: true

module Solidstats
  # LoadLens - Development Performance Monitoring Service
  # Parses Rails development logs to extract performance metrics
  class LoadLensService
    DATA_DIR = Rails.root.join('solidstats')
    LOG_FILE = Rails.root.join('log', 'development.log')
    POSITION_FILE = DATA_DIR.join('last_position.txt')
    CACHE_FILE = "loadlens.json"
    SUMMARY_FILE = "summary.json"
    RETENTION_DAYS = 7

    # Regex patterns for parsing Rails development log
    REQUEST_START_REGEX = /Started\s+(\w+)\s+"([^"]+)"\s+for\s+[\d\.:]+\s+at\s+([\d\-\s:]+)/
    CONTROLLER_ACTION_REGEX = /Processing\s+by\s+([^#]+)#(\w+)\s+as/
    # Updated to capture all timing info from the completion line
    COMPLETED_REGEX = /Completed\s+(\d+)\s+\w+\s+in\s+([\d\.]+)ms(?:\s+\(([^)]+)\))?/
    # Separate patterns for extracting times from the completion line details
    VIEW_RENDERING_REGEX = /Views:\s+([\d\.]+)ms/
    ACTIVERECORD_REGEX = /ActiveRecord:\s+([\d\.]+)ms/

    def self.get_performance_data
      cache_file_path = solidstats_cache_path(CACHE_FILE)
      
      if File.exist?(cache_file_path) && cache_fresh?(cache_file_path, 15.minutes)
        raw_data = JSON.parse(File.read(cache_file_path))
        deep_indifferent_access(raw_data)
      else
        scan_and_cache
      end
    rescue JSON::ParserError, Errno::ENOENT
      Rails.logger.error("Error reading performance cache, regenerating...")
      scan_and_cache
    end

    def self.scan_and_cache
      performance_data = scan_development_log
      
      # Cache the performance data
      cache_performance_data(performance_data)
      
      # Update summary.json with performance monitoring card
      update_summary_json(performance_data)
      
      deep_indifferent_access(performance_data)
    end

    def self.refresh_data
      # Force refresh by removing cache and regenerating
      cache_file_path = solidstats_cache_path(CACHE_FILE)
      File.delete(cache_file_path) if File.exist?(cache_file_path)
      scan_and_cache
    end

    def self.parse_log_and_save
      return unless Rails.env.development?
      return unless File.exist?(LOG_FILE)

      ensure_data_directory
      cleanup_old_files

      begin
        last_position = read_last_position
        processed_count = 0
        current_requests = []
        
        File.open(LOG_FILE, 'r') do |file|
          file.seek(last_position)
          
          file.each_line do |line|
            process_line(line.strip, current_requests)
            update_last_position(file.pos)
          end
        end

        # Process any remaining incomplete requests
        current_requests.each do |req|
          if req[:completed]
            save_request(req)
            processed_count += 1
          end
        end
        
        Rails.logger.info("DevLogParser: Processed #{processed_count} requests")
        { success: true, processed: processed_count }
      rescue => e
        Rails.logger.error("DevLogParser: Failed to parse development log: #{e.message}")
        { success: false, error: e.message }
      end
    end

    private

    def self.deep_indifferent_access(data)
      if data.is_a?(Hash)
        data.with_indifferent_access.transform_values do |value|
          deep_indifferent_access(value)
        end
      elsif data.is_a?(Array)
        data.map { |element| deep_indifferent_access(element) }
      else
        data
      end
    end

    def self.scan_development_log
      # First, ensure the log parser runs to create perf files if they don't exist
      parse_recent_log_entries_if_needed

      # Now, load the performance data from the perf files
      data_files = []
      found_perf_files = []
      
      # Get last 7 days of data files
      7.times do |i|
        date = i.days.ago.to_date
        file_path = DATA_DIR.join("perf_#{date.strftime('%Y-%m-%d')}.json")
        
        if File.exist?(file_path)
          file_data = JSON.parse(File.read(file_path))
          data_files.concat(file_data)
          found_perf_files << file_path
        end
      end

      # Fallback: If no data files exist, parse recent entries from development.log
      if data_files.empty? && File.exist?(LOG_FILE) && Rails.env.development?
        Rails.logger.info("LoadLensService: No perf data files found, parsing recent log entries as a fallback.")
        data_files = parse_recent_log_entries
      end

      # Calculate metrics
      calculate_performance_metrics(data_files)
    end

    def self.parse_recent_log_entries_if_needed
      # Check if any perf files exist from the last 7 days
      has_recent_perf_files = 7.times.any? do |i|
        date = i.days.ago.to_date
        file_path = DATA_DIR.join("perf_#{date.strftime('%Y-%m-%d')}.json")
        File.exist?(file_path)
      end

      # If no recent perf files, run the parser
      unless has_recent_perf_files
        Rails.logger.info("LoadLensService: No recent perf files found. Parsing development log to generate initial data.")
        parse_recent_log_entries
      end
    end

    def self.parse_recent_log_entries
      # Parse recent entries from development.log as fallback when no data files exist
      recent_requests = []
      current_requests = []
      lines_processed = 0
      max_lines = 2000  # Process last 2000 lines for initial bootstrap
      
      begin
        # Get the last N lines from the log file efficiently
        log_lines = []
        File.open(LOG_FILE, 'r') do |file|
          file.each_line { |line| log_lines << line.strip }
        end
        
        # Take the last max_lines entries
        log_lines = log_lines.last(max_lines) if log_lines.size > max_lines
        
        # Process each line using existing parsing logic
        log_lines.each do |line|
          process_line(line, current_requests)
          lines_processed += 1
          
          # Collect completed requests
          current_requests.each do |req|
            if req[:completed]
              # Convert to the same format as saved requests
              clean_request = {
                'controller' => req[:controller],
                'action' => req[:action],
                'http_method' => req[:http_method],
                'path' => req[:path],
                'status' => req[:status],
                'total_time_ms' => req[:total_time_ms] || 0.0,
                'view_time_ms' => req[:view_time_ms] || 0.0,
                'activerecord_time_ms' => req[:activerecord_time_ms] || 0.0,
                'timestamp' => req[:timestamp]
              }
              
              # Only include complete requests with controller/action
              if clean_request['controller'] && clean_request['action']
                recent_requests << clean_request
              end
            end
          end
          
          # Remove completed requests from processing queue
          current_requests.reject! { |req| req[:completed] }
        end
        
        Rails.logger.info("DevLogParser: Parsed #{recent_requests.size} recent requests from #{lines_processed} log lines")
        recent_requests
        
      rescue => e
        Rails.logger.error("DevLogParser: Failed to parse recent log entries: #{e.message}")
        []
      end
    end

    def self.calculate_performance_metrics(requests)
      return default_metrics if requests.empty?

      total_requests = requests.size
      avg_response_time = (requests.sum { |req| req['total_time_ms'] || 0 } / total_requests).round(2)
      avg_view_time = (requests.sum { |req| req['view_time_ms'] || 0 } / total_requests).round(2)
      avg_db_time = (requests.sum { |req| req['activerecord_time_ms'] || 0 } / total_requests).round(2)
      slow_requests = requests.count { |req| (req['total_time_ms'] || 0) > 1000 }
      error_rate = ((requests.count { |req| (req['status'] || 200) >= 400 }.to_f / total_requests) * 100).round(2)

      status = determine_status(avg_response_time, error_rate, slow_requests, total_requests)

      {
        summary: {
          total_requests: total_requests,
          avg_response_time: avg_response_time,
          avg_view_time: avg_view_time,
          avg_db_time: avg_db_time,
          slow_requests: slow_requests,
          error_rate: error_rate,
          status: status,
          last_updated: Time.current.iso8601
        },
        recent_requests: requests.sort_by { |req| req['timestamp'] }.reverse.first(20),
        last_updated: Time.current.iso8601
      }
    end

    def self.default_metrics
      {
        summary: {
          total_requests: 0,
          avg_response_time: 0,
          avg_view_time: 0,
          avg_db_time: 0,
          slow_requests: 0,
          error_rate: 0,
          status: 'info',
          last_updated: Time.current.iso8601
        },
        recent_requests: [],
        last_updated: Time.current.iso8601
      }
    end

    def self.determine_status(avg_response_time, error_rate, slow_requests, total_requests)
      return 'error' if error_rate > 10
      return 'warning' if avg_response_time > 1000 || slow_requests > (total_requests * 0.1)
      return 'success'
    end

    def self.process_line(line, current_requests)
      # Start of new request
      if match = line.match(REQUEST_START_REGEX)
        method, path, timestamp = match.captures
        current_requests << {
          http_method: method,
          path: path,
          timestamp: parse_timestamp(timestamp),
          started_at: Time.current
        }
      
      # Controller and action info
      elsif match = line.match(CONTROLLER_ACTION_REGEX)
        controller, action = match.captures
        if current_request = current_requests.last
          current_request[:controller] = controller
          current_request[:action] = action
        end
      
      # Request completion with timing
      elsif match = line.match(COMPLETED_REGEX)
        status, total_time, timing_details = match.captures
        if current_request = current_requests.last
          current_request[:status] = status.to_i
          current_request[:total_time_ms] = total_time.to_f
          current_request[:completed] = true
          
          # Extract view and ActiveRecord times from timing details if present
          if timing_details
            if view_match = timing_details.match(VIEW_RENDERING_REGEX)
              current_request[:view_time_ms] = view_match[1].to_f
            end
            
            if ar_match = timing_details.match(ACTIVERECORD_REGEX)
              current_request[:activerecord_time_ms] = ar_match[1].to_f
            end
          end
        end
      
      # View rendering time
      elsif match = line.match(VIEW_RENDERING_REGEX)
        view_time = match.captures.first
        if current_request = current_requests.last
          current_request[:view_time_ms] = view_time.to_f
        end
      
      # ActiveRecord time
      elsif match = line.match(ACTIVERECORD_REGEX)
        ar_time = match.captures.first
        if current_request = current_requests.last
          current_request[:activerecord_time_ms] = ar_time.to_f
        end
      end

      # Save and remove completed requests
      current_requests.reject! do |request|
        if request[:completed]
          save_request(request)
          true
        end
      end
    end

    def self.save_request(request)
      # Clean up request data
      clean_request = {
        controller: request[:controller],
        action: request[:action],
        http_method: request[:http_method],
        path: request[:path],
        status: request[:status],
        total_time_ms: request[:total_time_ms] || 0.0,
        view_time_ms: request[:view_time_ms] || 0.0,
        activerecord_time_ms: request[:activerecord_time_ms] || 0.0,
        timestamp: request[:timestamp]
      }

      # Skip incomplete requests
      return unless clean_request[:controller] && clean_request[:action]

      perf_file = current_perf_file
      
      # Read existing data or create new array
      existing_data = if File.exist?(perf_file)
        JSON.parse(File.read(perf_file))
      else
        []
      end

      # Add new request
      existing_data << clean_request

      # Write back to file
      File.write(perf_file, JSON.pretty_generate(existing_data))
    end

    def self.current_perf_file
      date_suffix = Date.current.strftime('%Y-%m-%d')
      DATA_DIR.join("perf_#{date_suffix}.json")
    end

    def self.ensure_data_directory
      DATA_DIR.mkpath unless DATA_DIR.exist?
    end

    def self.cleanup_old_files
      cutoff_date = RETENTION_DAYS.days.ago.to_date
      
      Dir.glob(DATA_DIR.join('perf_*.json')).each do |file|
        if match = File.basename(file).match(/perf_(\d{4}-\d{2}-\d{2})\.json/)
          file_date = Date.parse(match[1])
          File.delete(file) if file_date < cutoff_date
        end
      end
    end

    def self.read_last_position
      return 0 unless File.exist?(POSITION_FILE)
      File.read(POSITION_FILE).to_i
    end

    def self.update_last_position(position)
      File.write(POSITION_FILE, position.to_s)
    end

    def self.parse_timestamp(timestamp_str)
      # Handle Rails timestamp format: "2025-06-10 14:30:45 +0000"
      Time.parse(timestamp_str).iso8601
    rescue
      Time.current.iso8601
    end

    def self.cache_performance_data(data)
      cache_file_path = solidstats_cache_path(CACHE_FILE)
      ensure_solidstats_directory
      
      File.write(cache_file_path, JSON.pretty_generate(data))
    rescue => e
      Rails.logger.error("Failed to cache performance data: #{e.message}")
    end

    def self.update_summary_json(performance_data)
      summary_file_path = solidstats_cache_path(SUMMARY_FILE)
      
      # Read existing summary or create new one
      begin
        existing_summary = File.exist?(summary_file_path) ? JSON.parse(File.read(summary_file_path)) : {}
      rescue JSON::ParserError
        existing_summary = {}
      end
      
      summary = performance_data[:summary]
      
      # Create badges based on performance metrics
      badges = []
      badges << { "text" => "#{summary[:total_requests]} Requests", "color" => "info" }
      
      case summary[:status]
      when 'error'
        badges << { "text" => "High Errors", "color" => "error" }
      when 'warning'
        badges << { "text" => "Slow Responses", "color" => "warning" }
      else
        badges << { "text" => "Healthy", "color" => "success" }
      end
      
      if summary[:avg_response_time] > 0
        badges << { "text" => "#{summary[:avg_response_time]}ms avg", "color" => "neutral" }
      end
      
      # Update the LoadLens monitoring entry
      existing_summary["LoadLens"] = {
        "icon" => "activity",
        "status" => summary[:status],
        "value" => generate_performance_message(summary),
        "last_updated" => summary[:last_updated],
        "url" => "/solidstats/performance/load_lens",
        "badges" => badges
      }
      
      # Write updated summary
      File.write(summary_file_path, JSON.pretty_generate(existing_summary))
    rescue => e
      Rails.logger.error("Failed to update summary.json: #{e.message}")
    end

    def self.generate_performance_message(summary)
      if summary[:total_requests] == 0
        "No requests tracked"
      elsif summary[:status] == 'error'
        "#{summary[:error_rate]}% error rate"
      elsif summary[:status] == 'warning'
        "#{summary[:avg_response_time]}ms avg"
      else
        "#{summary[:avg_response_time]}ms avg"
      end
    end

    def self.cache_fresh?(cache_file_path, max_age = 5.minutes)
      File.mtime(cache_file_path) > max_age.ago
    rescue
      false
    end
    
    def self.solidstats_cache_path(filename)
      Rails.root.join('solidstats', filename)
    end
    
    def self.ensure_solidstats_directory
      dir_path = File.dirname(solidstats_cache_path('dummy'))
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
    end
  end
end
