# frozen_string_literal: true

module Solidstats
  class PerformanceController < ApplicationController
    layout "solidstats/dashboard"

    def load_lens
      @performance_data = LoadLensService.get_performance_data
      @metrics = @performance_data[:summary] || {}
      @recent_requests = @performance_data[:recent_requests] || []
    end

    def refresh
      # Parse new log entries and refresh cache
      parse_result = LoadLensService.parse_log_and_save
      LoadLensService.refresh_data

      if parse_result[:success]
        redirect_to load_lens_performance_index_path, notice: "LoadLens data refreshed! Parsed #{parse_result[:processed]} new requests."
      else
        redirect_to load_lens_performance_index_path, alert: "Failed to parse logs: #{parse_result[:error]}"
      end
    end
  end
end
