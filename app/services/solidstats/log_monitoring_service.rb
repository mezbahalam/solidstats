module Solidstats
  class LogMonitoringService
    CACHE_FILE = "logs.json"
    SUMMARY_FILE = "summary.json"
    
    # Size thresholds in bytes
    WARNING_SIZE = 500.megabytes
    ERROR_SIZE = 1.gigabyte
    
    def self.get_logs_data
      cache_file_path = solidstats_cache_path(CACHE_FILE)
      
      if File.exist?(cache_file_path) && cache_fresh?(cache_file_path)
        JSON.parse(File.read(cache_file_path))
      else
        scan_and_cache
      end
    rescue JSON::ParserError, Errno::ENOENT
      Rails.logger.error("Error reading logs cache, regenerating...")
      scan_and_cache
    end
    
    def self.scan_and_cache
      logs_data = scan_log_files
      
      # Cache the logs data
      cache_logs_data(logs_data)
      
      # Update summary.json with log monitoring card
      update_summary_json(logs_data)
      
      logs_data
    end
    
    def self.truncate_log(filename)
      return { status: "error", message: "Filename required" } if filename.blank?
      
      log_file_path = find_log_file(filename)
      return { status: "error", message: "Log file not found" } unless log_file_path
      
      begin
        # Check if file is writable
        unless File.writable?(log_file_path)
          return { status: "error", message: "File is not writable" }
        end
        
        # Get original size for reporting
        original_size = File.size(log_file_path)
        
        # Truncate the file
        File.truncate(log_file_path, 0)
        
        # Update cache after truncation
        scan_and_cache
        
        {
          status: "success",
          message: "Log file truncated successfully",
          original_size: format_file_size(original_size),
          filename: filename
        }
      rescue => e
        Rails.logger.error("Error truncating log file #{filename}: #{e.message}")
        { status: "error", message: "Failed to truncate: #{e.message}" }
      end
    end
    
    private
    
    def self.scan_log_files
      log_files = discover_log_files
      total_size = 0
      files_data = []
      
      log_files.each do |file_path|
        next unless File.exist?(file_path) && File.readable?(file_path)
        
        file_stat = File.stat(file_path)
        file_size = file_stat.size
        total_size += file_size
        
        files_data << {
          name: File.basename(file_path),
          path: file_path,
          size_bytes: file_size,
          size_human: format_file_size(file_size),
          last_modified: file_stat.mtime.iso8601,
          status: determine_file_status(file_size),
          can_truncate: File.writable?(file_path)
        }
      end
      
      # Sort by size descending
      files_data.sort_by! { |f| -f[:size_bytes] }
      
      {
        summary: {
          total_files: files_data.length,
          total_size: format_file_size(total_size),
          total_size_bytes: total_size,
          largest_file: files_data.first&.dig(:name) || "None",
          largest_file_size: files_data.first&.dig(:size_human) || "0 B",
          last_updated: Time.current.iso8601,
          status: determine_overall_status(total_size, files_data)
        },
        files: files_data
      }
    end
    
    def self.discover_log_files
      log_paths = []
      
      # Rails log directory
      if defined?(Rails) && Rails.root
        rails_log_dir = Rails.root.join('log')
        log_paths += Dir.glob(rails_log_dir.join('*.log')) if Dir.exist?(rails_log_dir)
      end
      
      # Remove duplicates and filter readable files
      log_paths.uniq.select { |path| File.readable?(path) }
    end
    
    def self.find_log_file(filename)
      discovered_files = discover_log_files
      discovered_files.find { |path| File.basename(path) == filename }
    end
    
    def self.determine_file_status(size_bytes)
      if size_bytes >= ERROR_SIZE
        'error'
      elsif size_bytes >= WARNING_SIZE
        'warning'
      else
        'success'
      end
    end
    
    def self.determine_overall_status(total_size, files_data)
      error_files = files_data.count { |f| f[:status] == 'error' }
      warning_files = files_data.count { |f| f[:status] == 'warning' }
      
      if error_files > 0 || total_size >= ERROR_SIZE * 2
        'error'
      elsif warning_files > 0 || total_size >= WARNING_SIZE * 3
        'warning'
      else
        'success'
      end
    end
    
    def self.format_file_size(size_bytes)
      return "0 B" if size_bytes.zero?
      
      units = ['B', 'KB', 'MB', 'GB', 'TB']
      base = 1024.0
      exp = (Math.log(size_bytes) / Math.log(base)).to_i
      exp = [exp, units.length - 1].min
      
      "%.1f %s" % [size_bytes / (base ** exp), units[exp]]
    end
    
    def self.cache_logs_data(logs_data)
      cache_file_path = solidstats_cache_path(CACHE_FILE)
      ensure_solidstats_directory
      
      File.write(cache_file_path, JSON.pretty_generate(logs_data))
    rescue => e
      Rails.logger.error("Failed to cache logs data: #{e.message}")
    end
    
    def self.update_summary_json(logs_data)
      summary_file_path = solidstats_cache_path(SUMMARY_FILE)
      
      # Read existing summary or create new one
      begin
        existing_summary = File.exist?(summary_file_path) ? JSON.parse(File.read(summary_file_path)) : {}
      rescue JSON::ParserError
        existing_summary = {}
      end
      
      # Create badges based on status
      badges = []
      badges << { "text" => "#{logs_data[:summary][:total_files]} Files", "color" => "info" }
      
      case logs_data[:summary][:status]
      when 'error'
        badges << { "text" => "Large Size", "color" => "error" }
      when 'warning'
        badges << { "text" => "Growing", "color" => "warning" }
      else
        badges << { "text" => "Healthy", "color" => "success" }
      end
      
      # Update the log monitoring entry
      existing_summary["Log Files"] = {
        "icon" => "file-text",
        "status" => logs_data[:summary][:status],
        "value" => logs_data[:summary][:total_size],
        "last_updated" => logs_data[:summary][:last_updated],
        "url" => "/solidstats/logs/size",
        "badges" => badges
      }
      
      # Write updated summary
      File.write(summary_file_path, JSON.pretty_generate(existing_summary))
    rescue => e
      Rails.logger.error("Failed to update summary.json: #{e.message}")
    end
    
    def self.cache_fresh?(cache_file_path, max_age = 30.minutes)
      File.mtime(cache_file_path) > max_age.ago
    rescue
      false
    end
    
    def self.solidstats_cache_path(filename)
      Rails.root.join( 'solidstats', filename)
    end
    
    def self.ensure_solidstats_directory
      dir_path = File.dirname(solidstats_cache_path('dummy'))
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
    end
  end
end
