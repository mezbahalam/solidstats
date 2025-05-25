# frozen_string_literal: true

module Solidstats
  # Base component class for all Solidstats ViewComponents
  # Provides common functionality and conventions for the component system
  class BaseComponent < ViewComponent::Base
    # Common helper methods available to all Solidstats components
    
    # Standard status classes for consistent styling
    def status_class(status)
      case status&.to_sym
      when :good, :ok
        "status-good"
      when :warning
        "status-warning"
      when :critical, :danger
        "status-critical"
      when :info
        "status-info"
      else
        "status-unknown"
      end
    end
    
    # Standard status icons
    def status_icon(status)
      case status&.to_sym
      when :good, :ok
        "✅"
      when :warning
        "⚠️"
      when :critical, :danger
        "❌"
      when :info
        "ℹ️"
      else
        "❓"
      end
    end
    
    # Standard status text
    def status_text(status)
      case status&.to_sym
      when :good, :ok
        "Good"
      when :warning
        "Warning"
      when :critical, :danger
        "Critical"
      when :info
        "Info"
      else
        "Unknown"
      end
    end
    
    # Helper for formatting numbers with delimiters
    def format_number(number)
      return "0" if number.nil?
      
      case number
      when Numeric
        number_with_delimiter(number)
      else
        number.to_s
      end
    end
    
    # Helper for safe data access with fallbacks
    def safe_get(data, key, fallback = nil)
      return fallback if data.nil?
      
      data.is_a?(Hash) ? data[key] || data[key.to_s] || fallback : fallback
    end
    
    # CSS class helper for dynamic classes
    def css_classes(*classes)
      classes.compact.reject(&:empty?).join(" ")
    end
    
    private
    
    # Access to Rails number helpers
    def number_with_delimiter(number, options = {})
      ActionController::Base.helpers.number_with_delimiter(number, options)
    end
  end
end
