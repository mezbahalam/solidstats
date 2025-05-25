# frozen_string_literal: true

module Solidstats
  module Security
    # Security overview component showing security score and key metrics
    class OverviewComponent < Solidstats::BaseComponent
      def initialize(vulnerabilities: [], **options)
        @vulnerabilities = vulnerabilities
        @options = options
      end

      private

      attr_reader :vulnerabilities, :options

      def overview_classes
        css_classes("security-overview", options[:class])
      end

      def overview_attributes
        { class: overview_classes }.merge(options.except(:class))
      end

      def vulnerabilities_count
        vulnerabilities.size
      end

      def high_severity_count
        vulnerabilities.count do |vuln|
          severity = vuln.dig("advisory", "criticality").to_s.downcase
          %w[high critical].include?(severity)
        end
      end

      def affected_gems_count
        vulnerabilities.map { |vuln| vuln.dig("gem", "name") }.uniq.size
      end

      def security_score
        if vulnerabilities_count == 0
          "A+"
        elsif high_severity_count > 0
          "C"
        else
          "B"
        end
      end

      def security_score_class
        if vulnerabilities_count == 0
          "score-excellent"
        elsif high_severity_count > 0
          "score-critical"
        else
          "score-warning"
        end
      end

      def score_container_classes
        css_classes("security-score-container")
      end

      def score_classes
        css_classes("security-score", security_score_class)
      end

      def metric_class(count, type = :warning)
        return "" if count == 0

        case type
        when :critical
          "metric-critical"
        when :warning
          "metric-warning"
        else
          ""
        end
      end

      def metrics_data
        [
          {
            icon: "⚠️",
            value: high_severity_count,
            label: "Critical Issues",
            class: metric_class(high_severity_count, :critical)
          },
          {
            icon: "🔍",
            value: vulnerabilities_count,
            label: "Total Vulnerabilities",
            class: metric_class(vulnerabilities_count, :warning)
          },
          {
            icon: "💎",
            value: affected_gems_count,
            label: "Affected Gems",
            class: metric_class(affected_gems_count, :warning)
          }
        ]
      end
    end
  end
end
