module Solidstats
  class DashboardController < ApplicationController
    layout "solidstats/dashboard"

    TODO_CACHE_FILE = Rails.root.join("tmp", "solidstats_todos.json")
    AUDIT_CACHE_HOURS = 12 # Configure how many hours before refreshing


    def dashboard
      # Load dashboard cards from JSON file
      @dashboard_cards = load_dashboard_cards
      @quick_actions = quick_actions_data
      render "dashboard"
    end

    def refresh
      # Refresh all services
      Solidstats::LogSizeMonitorService.scan_and_cache
      Solidstats::BundlerAuditService.scan_and_cache
      Solidstats::MyTodoService.collect_todos
      Solidstats::StylePatrolService.refresh_cache
      Solidstats::CoverageCompassService.refresh_cache
      Solidstats::LoadLensService.scan_and_cache

      respond_to do |format|
        format.html { redirect_to solidstats_dashboard_path, notice: "Dashboard data refreshed successfully!" }
        format.json { render json: { status: "success", message: "Dashboard data refreshed successfully!" } }
      end
    end

    private

    def quick_actions_data
      [
        {
          icon: "refresh-cw",
          label: "Refresh Data",
          color: "blue",
          action: "refresh_path"
        },
        {
          icon: "settings",
          label: "Configure",
          color: "purple",
          action: "#"
        },
        {
          icon: "download",
          label: "Export",
          color: "green",
          action: "#"
        },
        {
          icon: "bell",
          label: "Alerts",
          color: "orange",
          action: "#"
        }
      ]
    end

    def load_dashboard_cards
      json_file_path = Rails.root.join("solidstats", "summary.json")

      begin
        # Read and parse the JSON file
        json_data = JSON.parse(File.read(json_file_path))

        # Transform the JSON data into the format expected by the view
        json_data.map do |name, data|
          {
            name: name,
            icon: data["icon"],
            status: data["status"],
            value: data["value"],
            last_updated: Time.parse(data["last_updated"]),
            url: data["url"],
            badges: data["badges"] || []
          }
        end
      rescue Errno::ENOENT
        Rails.logger.warn("Summary JSON file not found, generating initial data...")
        # Fallback to empty array if JSON is invalid
        []
      rescue JSON::ParserError => e
        Rails.logger.error("Error parsing summary JSON: #{e.message}")
        # Fallback to empty array if JSON is invalid
        []
      end
    end
  end
end
