# frozen_string_literal: true

module Solidstats
  module CodeQuality
    class SectionComponent < BaseComponent
      def initialize(coverage:, log_data:)
        @coverage = coverage
        @log_data = log_data
        super()
      end

      private

      attr_reader :coverage, :log_data

      def tab_items
        [
          { id: "quality-metrics", label: "Metrics", active: true },
          { id: "test-coverage", label: "Test Coverage" },
          { id: "code-health", label: "Code Health" },
          { id: "log-monitor", label: "Log Monitor", icon: "📊" }
        ]
      end

      def coverage_status
        case coverage.to_f
        when 80..Float::INFINITY then 'status-ok'
        when 60...80 then 'status-warning'
        else 'status-danger'
        end
      end
    end
  end
end
