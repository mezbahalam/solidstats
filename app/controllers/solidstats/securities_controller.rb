# frozen_string_literal: true

module Solidstats
  class SecuritiesController < ApplicationController
    layout 'solidstats/dashboard'
    
    # Display bundler audit security vulnerabilities
    def bundler_audit
      @vulnerabilities_data = Solidstats::BundlerAuditService.fetch_vulnerabilities
      @vulnerabilities = @vulnerabilities_data.dig("output", "results") || []
      @summary = Solidstats::BundlerAuditService.summary
      @last_updated = @vulnerabilities_data.dig("output", "created_at")
      
      # Group vulnerabilities by severity for better display
      @vulnerabilities_by_severity = @vulnerabilities.group_by do |vuln|
        vuln.dig("advisory", "criticality") || "unknown"
      end
      
      render 'bundler_audit'
    end
    
    # Force refresh of bundler audit data
    def refresh_bundler_audit
      @vulnerabilities_data = Solidstats::BundlerAuditService.scan_and_cache
      redirect_to securities_bundler_audit_path, notice: 'Security vulnerabilities refreshed successfully.'
    rescue => e
      redirect_to securities_bundler_audit_path, alert: "Error refreshing vulnerabilities: #{e.message}"
    end

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
      redirect_to securities_style_patrol_path, notice: 'Code quality analysis refreshed successfully.'
    rescue => e
      redirect_to securities_style_patrol_path, alert: "Error refreshing analysis: #{e.message}"
    end
  end
end
