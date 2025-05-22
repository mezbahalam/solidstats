module Solidstats
  class LogSizeMonitorService
    WARNING_THRESHOLD = 25  # In megabytes
    DANGER_THRESHOLD = 50   # In megabytes

    def collect_data
      log_files = scan_log_directory
      total_size_bytes = log_files.sum { |file| file[:size_bytes] }
      
      # Create aggregated data
      {
        log_dir_path: log_directory,
        total_size_bytes: total_size_bytes,
        total_size_mb: bytes_to_mb(total_size_bytes),
        status: calculate_status(total_size_bytes),
        logs_count: log_files.size,
        log_files: log_files,
        created_at: Time.now.iso8601
      }
    end

    def truncate_log(filename = nil)
      begin
        if filename.present?
          # Truncate specific log file
          # Ensure filename has .log extension
          filename = "#{filename}.log" unless filename.end_with?('.log')
          
          file_path = File.join(log_directory, filename)
          if File.exist?(file_path)
            File.open(file_path, 'w') { |f| f.truncate(0) }
            { success: true, message: "Log file '#{filename}' truncated successfully" }
          else
            { success: false, message: "Log file '#{filename}' not found" }
          end
        else
          # Truncate all log files
          scan_log_directory.each do |log_file|
            File.open(log_file[:path], 'w') { |f| f.truncate(0) }
          end
          { success: true, message: "All log files truncated successfully" }
        end
      rescue => e
        { success: false, message: "Failed to truncate log file: #{e.message}" }
      end
    end

    private

    def log_directory
      Rails.root.join("log").to_s
    end
    
    def scan_log_directory
      log_files = []
      
      # Get all files in the log directory
      Dir.glob(File.join(log_directory, "*.log")).each do |file_path|
        if File.file?(file_path)
          size_bytes = File.size(file_path)
          filename = File.basename(file_path)
          
          log_files << {
            filename: filename,
            path: file_path,
            size_bytes: size_bytes,
            size_mb: bytes_to_mb(size_bytes),
            status: calculate_status(size_bytes),
            last_modified: File.mtime(file_path)
          }
        end
      end
      
      # Sort by size (largest first)
      log_files.sort_by { |file| -file[:size_bytes] }
    end

    def bytes_to_mb(bytes)
      (bytes.to_f / (1024 * 1024)).round(2)
    end

    def calculate_status(size_bytes)
      size_mb = bytes_to_mb(size_bytes)
      
      if size_mb >= DANGER_THRESHOLD
        :danger
      elsif size_mb >= WARNING_THRESHOLD
        :warning
      else
        :ok
      end
    end
  end
end
