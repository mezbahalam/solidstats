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

      # Calculate stats from the full data (temporary until refactored)
      @todo_stats = calculate_todo_stats(@todo_items)

      # TODO: Refactor these to use services as well
      @rubocop_output = "JSON.parse(`rubocop --format json`)"
      @coverage = "read_coverage_percent"
    end

    private

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
