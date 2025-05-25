# frozen_string_literal: true

module Solidstats
  module Security
    class SectionComponent < BaseComponent
      def initialize(audit_output:)
        @audit_output = audit_output
        super()
      end

      private

      attr_reader :audit_output

      def results
        @results ||= audit_output.dig("results") || []
      end

      def vulnerabilities_count
        results.size
      end

      def high_severity_count
        results.count { |r| %w[high critical].include?(r.dig("advisory", "criticality").to_s.downcase) }
      end

      def affected_gems_count
        results.map { |r| r.dig("gem", "name") }.uniq.size
      end

      def security_rating
        return "A+" if vulnerabilities_count.zero?
        return "C" if high_severity_count > 0
        "B"
      end

      def security_score_class
        return "score-excellent" if vulnerabilities_count.zero?
        return "score-critical" if high_severity_count > 0
        "score-warning"
      end

      def tab_items
        [
          { id: "security-overview", label: "Overview", icon: "📊", active: true },
          { id: "security-gems", label: "Affected Gems", icon: "💎" },
          { id: "security-timeline", label: "Timeline", icon: "📈" }
        ]
      end
    end
  end
end
