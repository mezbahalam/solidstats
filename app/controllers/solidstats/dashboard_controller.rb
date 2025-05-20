module Solidstats
  class DashboardController < ApplicationController
    TODO_CACHE_FILE = Rails.root.join("tmp", "solidstats_todos.json")
    AUDIT_CACHE_HOURS = 12 # Configure how many hours before refreshing

    def index
      # Use new services for data collection
      audit_service = AuditService.new
      todo_service = TodoService.new

      # Get full data for detailed views
      @audit_output = audit_service.fetch
      @todo_items = todo_service.fetch

      # Get summary data for dashboard cards
      @audit_summary = audit_service.summary
      @todo_summary = todo_service.summary

      # Use summary for stats in views
      # @todo_stats is now replaced by @todo_summary

      # TODO: Refactor these to use services as well
      @rubocop_output = "JSON.parse(`rubocop --format json`)"
      @coverage = "read_coverage_percent"
    end

    private

    def read_coverage_percent
      file = Rails.root.join("coverage", ".last_run.json")
      return 0 unless File.exist?(file)

      data = JSON.parse(File.read(file))
      data.dig("result", "covered_percent").to_f.round(2)
    end
  end
end
