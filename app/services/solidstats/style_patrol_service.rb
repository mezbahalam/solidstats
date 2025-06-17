# frozen_string_literal: true

require 'fileutils'
require 'json'

module Solidstats
  class StylePatrolService
    CACHE_KEY = "style_patrol_data"
    CACHE_DURATION = 6.hours
    STANDARD_JSON_FILE = Rails.root.join('solidstats', 'standard.json')

    def self.collect_data(force_refresh: false)
      return cached_data unless force_refresh || cache_expired?
      
      analysis_data = analyze_code_quality
      cache_data(analysis_data)
      save_to_standard_json(analysis_data)
      update_summary_json(analysis_data)
      analysis_data
    end

    def self.get_summary
      data = collect_data
      {
        status: data[:status],
        total_files: data.dig(:summary, :total_files) || 0,
        total_offenses: data.dig(:summary, :total_offenses) || 0,
        correctable_count: data.dig(:summary, :correctable_count) || 0,
        last_analyzed: data[:analyzed_at],
        health_score: calculate_health_score(data)
      }
    end

    def self.refresh_cache
      Rails.cache.delete(CACHE_KEY)
      collect_data(force_refresh: true)
    end

    private

    def self.analyze_code_quality
      result = `standardrb --format json 2>&1`
      
      # Extract JSON from output (may contain debug info or other text)
      json_content = extract_json_from_output(result)
      
      if json_content.nil?
        # No JSON found - could be clean result or error
        if $?.success?
          # Clean result - no issues found
          {
            status: "clean",
            issues: [],
            summary: { 
              total_files: 0, 
              total_offenses: 0, 
              correctable_count: 0,
              target_file_count: 0,
              inspected_file_count: 0
            },
            raw_data: nil,
            analyzed_at: Time.current.iso8601
          }
        else
          {
            status: "error",
            error_message: result,
            analyzed_at: Time.current.iso8601
          }
        end
      else
        begin
          json_output = JSON.parse(json_content)
          process_standard_output(json_output)
        rescue JSON::ParserError => e
          {
            status: "error",
            error_message: "Failed to parse JSON: #{e.message}\nRaw output: #{result}",
            analyzed_at: Time.current.iso8601
          }
        end
      end
    rescue StandardError => e
      {
        status: "error",
        error_message: e.message,
        analyzed_at: Time.current.iso8601
      }
    end

    def self.process_standard_output(json_data)
      issues = []
      
      # Handle StandardRB JSON format
      files = json_data["files"] || []
      
      files.each do |file_data|
        file_data["offenses"]&.each do |offense|
          issues << {
            file: file_data["path"],
            line: offense["location"]["line"],
            column: offense["location"]["column"],
            severity: offense["severity"],
            message: offense["message"],
            cop_name: offense["cop_name"],
            correctable: offense["correctable"] || false
          }
        end
      end

      # Get summary from StandardRB output
      summary_data = json_data["summary"] || {}
      
      {
        status: issues.any? ? "issues_found" : "clean",
        issues: issues,
        summary: {
          total_files: files.count,
          total_offenses: summary_data["offense_count"] || issues.count,
          correctable_count: issues.count { |i| i[:correctable] },
          target_file_count: summary_data["target_file_count"] || 0,
          inspected_file_count: summary_data["inspected_file_count"] || 0
        },
        raw_data: json_data,
        analyzed_at: Time.current.iso8601
      }
    end

    def self.cached_data
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
        analyze_code_quality
      end
    end

    def self.cache_data(data)
      Rails.cache.write(CACHE_KEY, data, expires_in: CACHE_DURATION)
      data
    end

    def self.cache_expired?
      cached_entry = Rails.cache.read(CACHE_KEY)
      return true if cached_entry.nil?
      
      cached_time = Time.parse(cached_entry[:analyzed_at])
      Time.current > cached_time + CACHE_DURATION
    rescue
      true
    end

    def self.calculate_health_score(data)
      return 100 if data[:status] == "clean"
      return 0 if data[:status] == "error"
      
      total_offenses = data.dig(:summary, :total_offenses) || 0
      total_files = data.dig(:summary, :total_files) || 1
      
      # Health score: 100 - (offenses per file * 10), minimum 0
      score = 100 - ((total_offenses.to_f / total_files) * 10).round
      [score, 0].max
    end

    def self.update_summary_json(data)
      summary_file_path = Rails.root.join('solidstats', 'summary.json')
      
      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(summary_file_path))
      
      # Read existing summary or create new one
      begin
        existing_summary = File.exist?(summary_file_path) ? JSON.parse(File.read(summary_file_path)) : {}
      rescue JSON::ParserError
        existing_summary = {}
      end
      
      # Calculate style patrol statistics
      total_offenses = data.dig(:summary, :total_offenses) || 0
      correctable_count = data.dig(:summary, :correctable_count) || 0
      status = determine_dashboard_status(data[:status], total_offenses)
      health_score = calculate_health_score(data)
      
      # Create badges based on code quality metrics
      badges = []
      badges << { "text" => "Health: #{health_score}%", "color" => health_badge_color(health_score) }
      
      if total_offenses > 0
        badges << { "text" => "#{total_offenses} Issues", "color" => "warning" }
        
        if correctable_count > 0
          badges << { "text" => "#{correctable_count} Auto-fixable", "color" => "info" }
        end
      end
      
      # Update the StylePatrol entry
      existing_summary["StylePatrol"] = {
        "icon" => "code",
        "status" => status,
        "value" => generate_dashboard_message(data[:status], total_offenses, health_score),
        "last_updated" => data[:analyzed_at],
        "url" => "/solidstats/quality/style_patrol",
        "badges" => badges
      }
      
      # Write updated summary
      File.write(summary_file_path, JSON.pretty_generate(existing_summary))
      Rails.logger.info("Updated summary.json with StylePatrol data")
    rescue => e
      Rails.logger.error("Failed to update summary.json: #{e.message}")
    end

    def self.determine_dashboard_status(analysis_status, offense_count)
      case analysis_status
      when "clean" then "success"
      when "error" then "danger"
      when "issues_found"
        case offense_count
        when 0..5 then "info"
        when 6..15 then "warning"
        else "danger"
        end
      else "warning"
      end
    end

    def self.health_badge_color(score)
      case score
      when 90..100 then "success"
      when 70..89 then "info"
      when 50..69 then "warning"
      else "error"
      end
    end

    def self.generate_dashboard_message(status, offense_count, health_score)
      case status
      when "clean"
        "Code is clean! ✨"
      when "error"
        "Analysis failed ❌"
      when "issues_found"
        "#{offense_count} issues found"
      else
        "Status unknown"
      end
    end

    def self.save_to_standard_json(data)
      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(STANDARD_JSON_FILE))
      
      # Prepare data for standard.json file
      standard_data = {
        last_updated: data[:analyzed_at],
        status: data[:status],
        metadata: data.dig(:raw_data, "metadata") || {},
        files: data.dig(:raw_data, "files") || [],
        summary: data.dig(:raw_data, "summary") || {},
        processed_summary: data[:summary] || {},
        issues_count: data[:issues]&.count || 0
      }
      
      # Write to standard.json file
      File.write(STANDARD_JSON_FILE, JSON.pretty_generate(standard_data))
      Rails.logger.info("Saved StandardRB data to #{STANDARD_JSON_FILE}")
    rescue => e
      Rails.logger.error("Failed to save standard.json: #{e.message}")
    end

    def self.extract_json_from_output(output)
      # Look for JSON content - should start with { and end with }
      # Handle cases where debug info or other text appears before/after JSON
      
      return nil if output.nil? || output.strip.empty?
      
      # Split by lines and look for the line that starts with JSON
      lines = output.split("\n")
      json_lines = []
      json_started = false
      brace_count = 0
      
      lines.each do |line|
        # Skip debug lines that mention "Subprocess Debugger", "ruby-debug-ide", etc.
        next if line.include?("Subprocess Debugger") || 
                line.include?("ruby-debug-ide") || 
                line.include?("debase") ||
                line.include?("listens on")
        
        # Look for the start of JSON (line starting with {)
        if !json_started && line.strip.start_with?('{')
          json_started = true
        end
        
        if json_started
          json_lines << line
          
          # Count braces to know when JSON ends
          brace_count += line.count('{') - line.count('}')
          
          # If we've closed all braces, we've reached the end of JSON
          break if brace_count == 0
        end
      end
      
      return nil if json_lines.empty?
      
      json_content = json_lines.join("\n")
      
      # Validate that it looks like StandardRB JSON by checking for expected structure
      return nil unless json_content.include?('"metadata"') || 
                        json_content.include?('"files"') || 
                        json_content.include?('"summary"')
      
      json_content
    rescue => e
      Rails.logger.error("Error extracting JSON from StandardRB output: #{e.message}")
      Rails.logger.error("Raw output was: #{output}")
      nil
    end
  end
end
