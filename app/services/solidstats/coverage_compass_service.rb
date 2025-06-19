require "json"
require "fileutils"

module Solidstats
  class CoverageCompassService
    class << self
      def collect_data(force_refresh: false)
        # Check if cached data exists and is fresh
        if !force_refresh && cached_data_exists? && cache_fresh?
          Rails.logger.info "CoverageCompass: Using cached data"
          return load_cached_data
        end

        Rails.logger.info "CoverageCompass: Collecting fresh coverage data"

        # Collect fresh coverage data
        coverage_data = collect_coverage_data

        # Cache the data if it's valid coverage information
        if coverage_data && !coverage_data[:setup_required] && !coverage_data[:error]
          cache_coverage_data(coverage_data)
          Rails.logger.info "CoverageCompass: Data cached successfully"
        end

        # Always update summary file
        update_summary_file(coverage_data) if coverage_data

        coverage_data
      rescue => e
        Rails.logger.error "Coverage collection failed: #{e.message}"
        { error: e.message, collected_at: Time.current, analyzed_at: Time.current }
      end

      def refresh_cache
        File.delete(cache_file_path) if File.exist?(cache_file_path)
        collect_data(force_refresh: true)
      end

      private

      def get_resultset_file_path
        # Only check in the coverage directory
        coverage_file = File.join(Rails.root, "coverage", ".resultset.json")

        Rails.logger.info "CoverageCompass: Looking for coverage file at: #{coverage_file}"

        if File.exist?(coverage_file)
          Rails.logger.info "CoverageCompass: Coverage file found - Size: #{File.size(coverage_file)} bytes"
          coverage_file
        else
          Rails.logger.warn "CoverageCompass: Coverage file not found"
          nil
        end
      end

      def cached_data_exists?
        File.exist?(cache_file_path)
      end

      def cache_fresh?
        return false unless cached_data_exists?

        resultset_path = get_resultset_file_path
        return false unless resultset_path

        cache_time = File.mtime(cache_file_path)
        resultset_time = File.mtime(resultset_path)

        # Cache is fresh if it's newer than the resultset file
        cache_time >= resultset_time
      end

      def load_cached_data
        cached_data = JSON.parse(File.read(cache_file_path)).deep_symbolize_keys

        # Convert string timestamps back to Time objects
        [ :collected_at, :analyzed_at, :data_timestamp ].each do |time_field|
          if cached_data[time_field].is_a?(String)
            cached_data[time_field] = Time.parse(cached_data[time_field])
          end
        end

        cached_data
      rescue => e
        Rails.logger.error "Failed to load cached coverage data: #{e.message}"
        nil
      end

      def collect_coverage_data
        resultset_path = get_resultset_file_path

        unless resultset_path
          return setup_instructions_data
        end

        # Check if coverage data is stale (older than 24 hours)
        if File.mtime(resultset_path) < 24.hours.ago
          return stale_coverage_data(resultset_path)
        end

        parse_resultset_file(resultset_path)
      end

      def parse_resultset_file(file_path)
        Rails.logger.info "CoverageCompass: Parsing file #{file_path}"
        resultset_data = JSON.parse(File.read(file_path)).deep_symbolize_keys

        Rails.logger.info "CoverageCompass: Found test suites: #{resultset_data.keys}"

        # Extract coverage data from SimpleCov resultset format
        coverage_results = {}
        total_lines = 0
        covered_lines = 0

        resultset_data.each do |test_suite, suite_data|
          Rails.logger.info "CoverageCompass: Processing suite '#{test_suite}'"

          unless suite_data[:coverage]
            Rails.logger.warn "CoverageCompass: No coverage data in suite '#{test_suite}'"
            next
          end

          Rails.logger.info "CoverageCompass: Found #{suite_data[:coverage].keys.size} files in '#{test_suite}'"

          suite_data[:coverage].each do |file_path, file_coverage|
            # Convert file_path to string in case it's a symbol
            file_path_str = file_path.to_s
            next if file_path_str.include?("vendor/") || file_path_str.include?("spec/") || file_path_str.include?("test/")

            # Handle different SimpleCov formats - newer versions use "lines" key
            line_coverage = file_coverage.is_a?(Hash) ? file_coverage[:lines] : file_coverage

            unless line_coverage.is_a?(Array)
              Rails.logger.warn "CoverageCompass: Invalid line coverage format for #{file_path_str}"
              next
            end

            relative_path = file_path_str.sub("#{Rails.root}/", "")
            line_count = line_coverage.compact.size
            covered_count = line_coverage.compact.count { |hits| hits > 0 }

            # Find uncovered lines (lines that are trackable but have 0 hits)
            missed_lines = []
            line_coverage.each_with_index do |hits, index|
              next if hits.nil? # Skip non-trackable lines
              missed_lines << (index + 1) if hits == 0 # Line numbers are 1-based
            end

            coverage_results[relative_path] = {
              total_lines: line_count,
              covered_lines: covered_count,
              missed_lines: missed_lines,
              coverage_percentage: line_count > 0 ? (covered_count.to_f / line_count * 100).round(2) : 0
            }

            total_lines += line_count
            covered_lines += covered_count
          end
        end

        overall_percentage = total_lines > 0 ? (covered_lines.to_f / total_lines * 100).round(2) : 0

        Rails.logger.info "CoverageCompass: Processed #{coverage_results.size} files, #{overall_percentage}% coverage"

        {
          overall_coverage: overall_percentage,
          file_coverage: coverage_results,
          total_lines: total_lines,
          covered_lines: covered_lines,
          collected_at: Time.current,
          analyzed_at: Time.current,
          data_timestamp: File.mtime(file_path)
        }
      rescue => e
        Rails.logger.error "Failed to parse coverage resultset: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        { error: "Failed to parse coverage data: #{e.message}", collected_at: Time.current, analyzed_at: Time.current }
      end

      def setup_instructions_data
        {
          setup_required: true,
          message: "No coverage data found. Please set up code coverage in your project.",
          instructions: {
            rspec: {
              title: "For RSpec projects:",
              steps: [
                "Add 'simplecov' to your Gemfile",
                "Add the following to spec/spec_helper.rb:",
                "require 'simplecov'\nSimpleCov.start 'rails'",
                "Run your test suite: bundle exec rspec"
              ]
            },
            minitest: {
              title: "For Minitest projects:",
              steps: [
                "Add 'simplecov' to your Gemfile",
                "Add the following to test/test_helper.rb:",
                "require 'simplecov'\nSimpleCov.start 'rails'",
                "Run your test suite: bundle exec rails test"
              ]
            },
            custom: {
              title: "For other test frameworks:",
              steps: [
                "Install SimpleCov gem",
                "Configure SimpleCov at the beginning of your test helper",
                "Run your test suite to generate coverage data"
              ]
            }
          },
          collected_at: Time.current,
          analyzed_at: Time.current
        }
      end

      def stale_coverage_data(resultset_path)
        data_age = Time.current - File.mtime(resultset_path)
        hours_old = (data_age / 1.hour).round(1)

        # Get the last coverage data even if it's stale
        last_coverage_data = parse_resultset_file(resultset_path)

        {
          stale_data: true,
          message: "Coverage data is #{hours_old} hours old. Consider running tests to get fresh data.",
          suggestions: [
            "Run your test suite: bundle exec rspec (or rails test)",
            "Check if your CI/CD pipeline is running tests",
            "Verify SimpleCov is properly configured"
          ],
          last_coverage: last_coverage_data,
          data_age_hours: hours_old,
          collected_at: Time.current,
          analyzed_at: Time.current
        }
      end

      def cache_coverage_data(data)
        ensure_solidstats_directory
        File.write(cache_file_path, JSON.pretty_generate(data))
        Rails.logger.info "Coverage data cached to #{cache_file_path}"
      rescue => e
        Rails.logger.error "Failed to cache coverage data: #{e.message}"
      end

      def update_summary_file(coverage_data)
        summary_file_path = Rails.root.join("solidstats", "summary.json")

        # Ensure directory exists
        FileUtils.mkdir_p(File.dirname(summary_file_path))

        # Read existing summary or create new one
        begin
          existing_summary = File.exist?(summary_file_path) ? JSON.parse(File.read(summary_file_path)) : {}
        rescue JSON::ParserError
          existing_summary = {}
        end

        # Calculate coverage metrics
        overall_coverage = coverage_data[:overall_coverage] || 0
        total_files = coverage_data[:file_coverage]&.size || 0
        status = determine_status(coverage_data)

        # Create badges based on coverage metrics
        badges = []
        badges << { "text" => "#{overall_coverage.round(1)}% Coverage", "color" => coverage_badge_color(overall_coverage) }
        badges << { "text" => "#{total_files} Files", "color" => "info" }

        # Update the Coverage Compass entry
        existing_summary["Coverage Compass"] = {
          "icon" => "target",
          "status" => status,
          "value" => generate_coverage_message(coverage_data),
          "last_updated" => Time.current.iso8601,
          "url" => "/solidstats/quality/coverage_compass",
          "badges" => badges
        }

        # Write updated summary
        File.write(summary_file_path, JSON.pretty_generate(existing_summary))
        Rails.logger.info("Updated summary.json with Coverage Compass data")
      rescue => e
        Rails.logger.error("Failed to update summary.json: #{e.message}")
      end

      def determine_status(coverage_data)
        return "danger" if coverage_data[:setup_required] || coverage_data[:error]
        return "warning" if coverage_data[:stale_data]

        coverage = coverage_data[:overall_coverage] || 0
        case coverage
        when 0...50 then "danger"
        when 50...80 then "warning"
        when 80...95 then "info"
        else "success"
        end
      end

      def generate_coverage_message(coverage_data)
        return "Setup required" if coverage_data[:setup_required]
        return "Analysis error" if coverage_data[:error]
        return "Stale data" if coverage_data[:stale_data]

        coverage = coverage_data[:overall_coverage] || 0
        "#{coverage.round(1)}% coverage"
      end

      def coverage_badge_color(coverage)
        case coverage
        when 0...50 then "error"
        when 50...80 then "warning"
        when 80...95 then "info"
        else "success"
        end
      end

      def cache_file_path
        File.join(solidstats_directory, "coverage_cache.json")
      end

      def summary_file_path
        File.join(solidstats_directory, "summary.json")
      end

      def solidstats_directory
        File.join(Rails.root, "solidstats")
      end

      def ensure_solidstats_directory
        FileUtils.mkdir_p(solidstats_directory) unless File.directory?(solidstats_directory)
      end
    end
  end
end
