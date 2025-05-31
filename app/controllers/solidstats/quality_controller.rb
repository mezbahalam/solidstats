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
  end
end
