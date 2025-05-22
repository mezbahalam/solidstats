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
      @coverage = "100"
    end
    
    # Force refresh all dashboard data
    def refresh
      # Create services
      audit_service = AuditService.new
      todo_service = TodoService.new
      
      # Force refresh of data
      audit_output = audit_service.fetch(true) # Force refresh
      todo_items = todo_service.fetch(true)    # Force refresh
      
      # Get updated summaries
      audit_summary = audit_service.summary
      todo_summary = todo_service.summary
      
      # Get current time for last updated display
      last_updated = Time.now.strftime("%B %d, %Y at %H:%M")
      
      # Return JSON response with refreshed data
      render json: {
        audit_output: audit_output,
        todo_items: todo_items,
        audit_summary: audit_summary,
        todo_summary: todo_summary,
        last_updated: last_updated,
        status: "success"
      }
    rescue StandardError => e
      # Return error information
      render json: {
        status: "error",
        message: "Failed to refresh data: #{e.message}"
      }, status: :internal_server_error
    end
  end
end
