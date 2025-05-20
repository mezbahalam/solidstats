# frozen_string_literal: true

module Solidstats
  # Service to collect and process security audit data
  class AuditService < DataCollectorService
    # Initialize with default cache settings for audits
    def initialize
      super(Rails.root.join("tmp", "solidstats_audit.json"))
    end

    # Generate a summary for the dashboard display
    # @return [Hash] Summary information with status, count, and message
    def summary
      data = fetch
      vuln_count = data["vulnerabilities"]&.count || 0

      {
        count: vuln_count,
        status: determine_status(vuln_count),
        message: generate_message(vuln_count)
      }
    end

    private

    # Determine the status indicator based on vulnerability count
    # @param count [Integer] Number of vulnerabilities
    # @return [String] Status indicator (success, warning, or danger)
    def determine_status(count)
      case count
      when 0 then "success"
      when 1..2 then "warning"
      else "danger"
      end
    end

    # Generate a status message based on vulnerability count
    # @param count [Integer] Number of vulnerabilities
    # @return [String] Human-readable status message
    def generate_message(count)
      case count
      when 0 then "No vulnerabilities found"
      when 1 then "1 vulnerability found"
      else "#{count} vulnerabilities found"
      end
    end

    # Collect fresh audit data by running bundle-audit
    # @return [Hash] Parsed audit data
    def collect_data
      raw_output = `bundle audit check --update --format json`
      json_part = raw_output[/\{.*\}/m] # extract JSON starting from first '{'
      JSON.parse(json_part) rescue { "error" => "Failed to parse JSON", "vulnerabilities" => [] }
    end
  end
end
