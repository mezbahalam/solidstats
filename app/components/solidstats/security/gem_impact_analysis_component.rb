# frozen_string_literal: true

module Solidstats
  module Security
    class GemImpactAnalysisComponent < BaseComponent
      def initialize(results:)
        @results = results
        super()
      end

      private

      attr_reader :results

      def affected_gems
        return [] unless results.any?
        
        results.map { |r| r.dig("gem", "name") }.uniq.map do |gem_name|
          gem_vulns = results.select { |r| r.dig("gem", "name") == gem_name }
          highest_severity = calculate_highest_severity(gem_vulns)
          
          {
            name: gem_name,
            vulnerabilities: gem_vulns,
            vulnerability_count: gem_vulns.size,
            current_version: gem_vulns.first.dig("gem", "version") || "Unknown",
            target_version: gem_vulns.first.dig("advisory", "patched_versions")&.first || "N/A",
            severity: highest_severity,
            severity_class: "severity-#{highest_severity}"
          }
        end
      end

      def calculate_highest_severity(gem_vulns)
        severities = gem_vulns.map { |v| v.dig("advisory", "criticality").to_s.downcase }
        valid_severities = severities.select { |s| %w[critical high medium low].include?(s) }
        valid_severities.min_by { |s| %w[critical high medium low].index(s) || 999 } || "unknown"
      end

      def has_affected_gems?
        results.any?
      end
    end
  end
end
