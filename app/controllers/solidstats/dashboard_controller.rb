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

      # TODO: Refactor these to use services as well
      @rubocop_output = "JSON.parse(`rubocop --format json`)"
      @coverage = "Coverage Percent %"
    end
  end
end
