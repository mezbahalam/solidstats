# frozen_string_literal: true

module Solidstats
  module Security
    class TimelineComponent < BaseComponent
      def initialize
        super()
      end

      private

      def timeline_points
        [
          { position: "10%", severity: "critical", date: "Jan 2025" },
          { position: "30%", severity: "medium", date: "Feb 2025" },
          { position: "65%", severity: "low", date: "Apr 2025" },
          { position: "85%", severity: "critical", date: "May 2025" }
        ]
      end

      def legend_items
        [
          { color: "#dc3545", label: "Critical" },
          { color: "#ffc107", label: "Medium" },
          { color: "#28a745", label: "Low" }
        ]
      end

      def insights
        [
          {
            title: "Notable Trend",
            description: "4 vulnerabilities discovered in the last 3 months."
          },
          {
            title: "Recent Activity",
            description: "Last security scan: #{Time.now.strftime('%B %d, %Y')}"
          }
        ]
      end
    end
  end
end
