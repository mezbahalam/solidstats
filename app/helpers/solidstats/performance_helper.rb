# frozen_string_literal: true

module Solidstats
  # LoadLens Performance Helper
  # Provides view helpers for displaying performance metrics
  module PerformanceHelper
    def load_lens_status_class(avg_response_time, error_rate)
      return 'text-error' if error_rate > 10
      return 'text-warning' if avg_response_time > 1000
      'text-success'
    end

    def load_lens_status_icon(avg_response_time, error_rate)
      return 'alert-circle' if error_rate > 10
      return 'alert-triangle' if avg_response_time > 1000
      'check-circle'
    end

    def format_response_time(time_ms)
      return "0ms" if time_ms.nil? || time_ms == 0
      "#{time_ms.round(1)}ms"
    end

    def format_percentage(value)
      return "0%" if value.nil? || value == 0
      "#{value.round(1)}%"
    end

    def request_status_badge_class(status)
      case status.to_i
      when 200..299
        'badge-success'
      when 300..399
        'badge-info'
      when 400..499
        'badge-warning'
      when 500..599
        'badge-error'
      else
        'badge-neutral'
      end
    end

    def response_time_color_class(time_ms)
      return 'text-base-content' if time_ms.nil? || time_ms == 0
      
      case time_ms.to_f
      when 0..100
        'text-success'
      when 100..500
        'text-info'
      when 500..1000
        'text-warning'
      else
        'text-error'
      end
    end

    def performance_trend_indicator(current, previous)
      return '' if current.nil? || previous.nil? || previous == 0
      
      percentage_change = ((current - previous) / previous.to_f) * 100
      
      if percentage_change > 5
        content_tag(:span, '↑', class: 'text-error', title: "#{percentage_change.round(1)}% slower")
      elsif percentage_change < -5
        content_tag(:span, '↓', class: 'text-success', title: "#{percentage_change.abs.round(1)}% faster")
      else
        content_tag(:span, '→', class: 'text-info', title: 'Similar performance')
      end
    end

    def load_lens_metric_badge(value, threshold_warning, threshold_error, unit = 'ms')
      formatted_value = "#{value}#{unit}"
      
      badge_class = if value > threshold_error
                     'badge-error'
                   elsif value > threshold_warning
                     'badge-warning'
                   else
                     'badge-success'
                   end
      
      content_tag(:span, formatted_value, class: "badge #{badge_class}")
    end
  end
end
