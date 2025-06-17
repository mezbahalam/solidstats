# frozen_string_literal: true

module Solidstats
  class QualityController < ApplicationController
    layout 'solidstats/dashboard'
    
    # Display Standard gem code quality analysis
    def style_patrol
      @analysis_data = Solidstats::StylePatrolService.collect_data
      @summary = Solidstats::StylePatrolService.get_summary
      
      # Group issues by file for better display
      if @analysis_data[:issues].present?
        @issues_by_file = @analysis_data[:issues].group_by { |issue| issue[:file] }
        @issues_by_severity = @analysis_data[:issues].group_by { |issue| issue[:severity] }
      else
        @issues_by_file = {}
        @issues_by_severity = {}
      end
      
      render 'style_patrol'
    end
    
    # Force refresh of style patrol data
    def refresh_style_patrol
      @analysis_data = Solidstats::StylePatrolService.refresh_cache
      redirect_to quality_style_patrol_path, notice: 'Code quality analysis refreshed successfully.'
    rescue => e
      redirect_to quality_style_patrol_path, alert: "Error refreshing analysis: #{e.message}"
    end
    
    # Display SimpleCov code coverage analysis
    def coverage_compass
      # Get coverage data using the correct method
      @analysis_data = Solidstats::CoverageCompassService.collect_data
      
      # Handle different response types from service
      if @analysis_data
        if @analysis_data[:setup_required]
          @setup_instructions = @analysis_data[:instructions]
          @show_setup = true
          @analysis_data[:status] = 'setup_required'
        elsif @analysis_data[:stale_data]
          @stale_warning = true
          @data_age_hours = @analysis_data[:data_age_hours]
          @suggestions = @analysis_data[:suggestions]
          @analysis_data = @analysis_data[:last_coverage] || @analysis_data
          @analysis_data[:status] = 'stale'
        elsif @analysis_data[:error]
          @error_message = @analysis_data[:error]
          @analysis_data[:status] = 'error'
        else
          @analysis_data[:status] = 'success'
        end
        
        # Organize file coverage data for better display
        organize_coverage_data
      else
        set_error_state
        @analysis_data = { status: 'error' }
      end
      
      render 'coverage_compass'
    end
    
    # Force refresh of coverage compass data
    def refresh_coverage_compass
      Solidstats::CoverageCompassService.refresh_cache
      redirect_to quality_coverage_compass_path, notice: 'Code coverage analysis refreshed successfully.'
    rescue => e
      redirect_to quality_coverage_compass_path, alert: "Error refreshing coverage analysis: #{e.message}"
    end

    private

    def organize_coverage_data
      file_coverage_data = @analysis_data[:file_coverage]
      if file_coverage_data.present?
        @file_coverage = file_coverage_data.map do |path, data|
          {
            file_path: path,
            coverage_percent: data[:coverage_percentage] || 0,
            total_lines: data[:total_lines] || 0,
            covered_lines: data[:covered_lines] || 0,
            missed_lines: data[:missed_lines] || []
          }
        end
        
        # Group files by coverage ranges for better visualization
        @coverage_ranges = {
          excellent: @file_coverage.select { |f| f[:coverage_percent] >= 90 },
          good: @file_coverage.select { |f| f[:coverage_percent] >= 70 && f[:coverage_percent] < 90 },
          needs_improvement: @file_coverage.select { |f| f[:coverage_percent] >= 50 && f[:coverage_percent] < 70 },
          poor: @file_coverage.select { |f| f[:coverage_percent] < 50 }
        }
      else
        @file_coverage = []
        @coverage_ranges = { excellent: [], good: [], needs_improvement: [], poor: [] }
      end
      
      # Set summary data
      @summary = {
        overall_coverage: @analysis_data[:overall_coverage] || 0,
        coverage_percent: @analysis_data[:overall_coverage] || 0,
        total_lines: @analysis_data[:total_lines] || 0,
        covered_lines: @analysis_data[:covered_lines] || 0,
        missed_lines: (@analysis_data[:total_lines] || 0) - (@analysis_data[:covered_lines] || 0),
        total_files: @file_coverage.size,
        health_score: calculate_health_score(@analysis_data[:overall_coverage] || 0),
        coverage_grade: determine_coverage_grade(@analysis_data[:overall_coverage] || 0)
      }
    end

    def set_error_state
      @error_message = "Failed to retrieve coverage data"
      @file_coverage = []
      @coverage_ranges = { excellent: [], good: [], needs_improvement: [], poor: [] }
      @summary = { 
        overall_coverage: 0, 
        coverage_percent: 0,
        total_lines: 0, 
        covered_lines: 0, 
        missed_lines: 0,
        total_files: 0,
        health_score: 0,
        coverage_grade: 'F'
      }
    end

    def calculate_health_score(coverage_percent)
      case coverage_percent
      when 90..100 then 95
      when 80..89 then 85
      when 70..79 then 75
      when 60..69 then 65
      when 50..59 then 55
      else 25
      end
    end

    def determine_coverage_grade(coverage_percent)
      case coverage_percent
      when 90..100 then 'A+'
      when 80..89 then 'A'
      when 70..79 then 'B'
      when 60..69 then 'C'
      when 50..59 then 'D'
      else 'F'
      end
    end
  end
end
