module Solidstats
  module ApplicationHelper
    def time_ago_in_words(from_time)
      return "just now" if from_time.nil?
      
      distance_in_seconds = (Time.current - from_time).to_i
      
      case distance_in_seconds
      when 0..29
        "just now"
      when 30..59
        "#{distance_in_seconds} seconds"
      when 60..3599
        minutes = distance_in_seconds / 60
        "#{minutes} minute#{'s' if minutes != 1}"
      when 3600..86399
        hours = distance_in_seconds / 3600
        "#{hours} hour#{'s' if hours != 1}"
      else
        days = distance_in_seconds / 86400
        "#{days} day#{'s' if days != 1}"
      end
    end

    def quick_actions
      [
        { icon: 'refresh-ccw', label: 'Refresh All', color: 'blue' },
        { icon: 'download', label: 'Export Data', color: 'green' },
        { icon: 'bar-chart-2', label: 'View Reports', color: 'purple' },
        { icon: 'tool', label: 'Settings', color: 'orange' }
      ]
    end
  end
end
