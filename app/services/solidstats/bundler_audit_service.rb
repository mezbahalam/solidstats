# frozen_string_literal: true

module Solidstats
  # Service to collect and process bundler audit security vulnerability data
  class BundlerAuditService
    CACHE_FILE = Rails.root.join("solidstats", "bundler_audit.json")
    CACHE_HOURS = 24 # Cache for 24 hours

    class << self
      # Get cached vulnerabilities or scan if cache is stale
      # @return [Hash] The vulnerability data from JSON file
      def fetch_vulnerabilities
        if cache_stale?
          scan_and_cache
        end

        load_cached_data
      end

      # Force a fresh scan and update cache
      # @return [Hash] Fresh vulnerability data
      def scan_and_cache
        Rails.logger.info("Running bundler audit scan...")

        begin
          vulnerabilities_data = collect_bundler_audit_data
          save_to_cache(vulnerabilities_data)
          update_summary_json(vulnerabilities_data)
          vulnerabilities_data
        rescue => e
          Rails.logger.error("Error running bundler audit: #{e.message}")
          { "output" => { "results" => [], "error" => e.message } }
        end
      end

      # Get summary for dashboard display
      # @return [Hash] Summary information with status, count, and message
      def summary
        data = fetch_vulnerabilities
        results = data.dig("output", "results") || []
        vuln_count = results.count

        {
          count: vuln_count,
          status: determine_status(vuln_count),
          message: generate_message(vuln_count),
          last_updated: data.dig("output", "created_at") || Time.current
        }
      end

      private

      # Check if cache file exists and is fresh
      # @return [Boolean] true if cache is stale or missing
      def cache_stale?
        return true unless File.exist?(CACHE_FILE)

        file_age = Time.current - File.mtime(CACHE_FILE)
        file_age > CACHE_HOURS.hours
      end

      # Load data from cache file
      # @return [Hash] Cached vulnerability data
      def load_cached_data
        return { "output" => { "results" => [] } } unless File.exist?(CACHE_FILE)

        JSON.parse(File.read(CACHE_FILE))
      rescue JSON::ParserError => e
        Rails.logger.error("Error parsing bundler audit cache: #{e.message}")
        { "output" => { "results" => [] } }
      end

      # Run bundler audit and collect vulnerability data
      # @return [Hash] Fresh vulnerability data
      def collect_bundler_audit_data
        # Run bundler audit with JSON format
        result = `bundle audit check --update --format json 2>&1`

        # Check if bundler-audit is installed
        if $?.exitstatus == 127 || result.include?("command not found")
          raise "bundler-audit gem is not installed. Please run: gem install bundler-audit"
        end

        # Extract JSON part from output (bundler-audit may include extra text)
        json_match = result.match(/(\{.*\})/m)
        if json_match
          parsed_data = JSON.parse(json_match[1])

          # Add metadata
          {
            "output" => {
              "version" => parsed_data.dig("version") || "unknown",
              "created_at" => Time.current.strftime("%Y-%m-%d %H:%M:%S %z"),
              "results" => parsed_data.dig("results") || []
            }
          }
        else
          # If no JSON found, create empty structure
          {
            "output" => {
              "version" => "unknown",
              "created_at" => Time.current.strftime("%Y-%m-%d %H:%M:%S %z"),
              "results" => []
            }
          }
        end
      rescue JSON::ParserError => e
        raise "Failed to parse bundler audit JSON output: #{e.message}"
      end

      # Save vulnerability data to cache file
      # @param data [Hash] Vulnerability data to cache
      def save_to_cache(data)
        FileUtils.mkdir_p(File.dirname(CACHE_FILE))
        File.write(CACHE_FILE, JSON.pretty_generate(data))
        Rails.logger.info("Bundler audit data cached to #{CACHE_FILE}")
      end

      # Update the main summary.json file with security vulnerabilities
      # @param data [Hash] Vulnerability data
      def update_summary_json(data)
        summary_file = Rails.root.join("solidstats", "summary.json")

        # Ensure directory exists
        FileUtils.mkdir_p(File.dirname(summary_file))

        # Load existing summary or create new
        existing_summary = if File.exist?(summary_file)
          JSON.parse(File.read(summary_file))
        else
          {}
        end

        # Get vulnerability count and status
        results = data.dig("output", "results") || []
        vuln_count = results.count
        status = determine_status(vuln_count)

        # Calculate severity distribution
        severity_counts = results.group_by { |r| r.dig("advisory", "criticality") || "unknown" }
                                 .transform_values(&:count)

        # Create badges for severity levels
        badges = []
        %w[critical high medium low].each do |severity|
          count = severity_counts[severity] || 0
          if count > 0
            badges << {
              "text" => "#{severity.capitalize}: #{count}",
              "color" => severity_badge_color(severity)
            }
          end
        end

        # Update summary
        existing_summary["Security Vulnerabilities"] = {
          "icon" => "shield-alert",
          "status" => status,
          "value" => generate_message(vuln_count),
          "last_updated" => data.dig("output", "created_at") || Time.current.iso8601,
          "url" => "/solidstats/securities/bundler_audit",
          "badges" => badges
        }

        # Save updated summary
        File.write(summary_file, JSON.pretty_generate(existing_summary))
        Rails.logger.info("Updated summary.json with security vulnerabilities")
      end

      # Determine status color based on vulnerability count
      # @param count [Integer] Number of vulnerabilities
      # @return [String] Status indicator
      def determine_status(count)
        case count
        when 0 then "success"
        when 1..2 then "warning"
        else "danger"
        end
      end

      # Generate status message based on vulnerability count
      # @param count [Integer] Number of vulnerabilities
      # @return [String] Human-readable status message
      def generate_message(count)
        case count
        when 0 then "No vulnerabilities"
        when 1 then "1 vulnerability"
        else "#{count} vulnerabilities"
        end
      end

      # Get badge color for severity level
      # @param severity [String] Severity level
      # @return [String] Badge color
      def severity_badge_color(severity)
        case severity.downcase
        when "critical" then "red"
        when "high" then "orange"
        when "medium" then "yellow"
        when "low" then "blue"
        else "gray"
        end
      end
    end
  end
end
