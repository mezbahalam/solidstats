module Solidstats
  class LogsController < ApplicationController
    layout "solidstats/dashboard"

    def logs_size
      @logs_data = Solidstats::LogSizeMonitorService.get_logs_data
    end

    def truncate
      filename = params[:filename]

      # Validate filename presence
      if filename.blank?
        return render json: {
          status: "error",
          message: "Filename is required"
        }, status: :bad_request
      end

      # Remove any path traversal attempts for security
      filename = File.basename(filename)

      # Ensure it's a .log file
      unless filename.end_with?(".log")
        filename = "#{filename}.log" if filename.present?
      end

      # Additional security check
      unless filename.end_with?(".log")
        return render json: {
          status: "error",
          message: "Invalid file type. Only .log files can be truncated."
        }, status: :bad_request
      end

      result = Solidstats::LogSizeMonitorService.truncate_log(filename)

      if result[:status] == "success"
        render json: {
          status: "success",
          message: result[:message] || "Log file truncated successfully",
          filename: filename,
          original_size: result[:original_size]
        }
      else
        render json: result, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error("Failed to truncate log #{filename}: #{e.message}")
      render json: {
        status: "error",
        message: "Failed to truncate log: #{e.message}"
      }, status: :internal_server_error
    end

    def refresh
      # Force refresh of log monitoring data
      result = Solidstats::LogSizeMonitorService.scan_and_cache

      render json: {
        status: "success",
        message: "Log data refreshed",
        data: result
      }
    rescue StandardError => e
      render json: {
        status: "error",
        message: "Failed to refresh log data: #{e.message}"
      }, status: :internal_server_error
    end
  end
end
