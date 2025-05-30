module Solidstats
  class DashboardController < ApplicationController
    layout 'solidstats/dashboard'
    
    TODO_CACHE_FILE = Rails.root.join("tmp", "solidstats_todos.json")
    AUDIT_CACHE_HOURS = 12 # Configure how many hours before refreshing


    def dashboard
      # Load dashboard cards from JSON file
      @dashboard_cards = load_dashboard_cards
      @quick_actions = quick_actions_data
      render 'dashboard'
    end

    private

    def quick_actions_data
      [
        {
          icon: 'refresh-cw',
          label: 'Refresh Data',
          color: 'blue',
          action: 'refresh_dashboard'
        },
        {
          icon: 'settings',
          label: 'Configure',
          color: 'purple',
          action: 'open_settings'
        },
        {
          icon: 'download',
          label: 'Export',
          color: 'green',
          action: 'export_data'
        },
        {
          icon: 'bell',
          label: 'Alerts',
          color: 'orange',
          action: 'view_alerts'
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
            last_updated: Time.zone.parse(data["last_updated"]),
            url: data["url"],
            badges: data["badges"] || []
          }
        end
      rescue Errno::ENOENT
        Rails.logger.error("Summary JSON file not found at #{json_file_path}")
        # Force a scan to create initial data if missing
        Solidstats::LogMonitoringService.scan_and_cache
        # Return sample cards with badges for demo
        sample_cards_with_badges
      rescue JSON::ParserError => e
        Rails.logger.error("Error parsing summary JSON: #{e.message}")
        # Fallback to empty array if JSON is invalid
        []
      end
    end
  end
end
