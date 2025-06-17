# frozen_string_literal: true

module Solidstats
  module ProductivityHelper
    def todo_type_color(type)
      case type.to_s.downcase
      when 'todo' then 'primary'
      when 'fixme' then 'error'
      when 'hack' then 'warning'
      when 'note' then 'info'
      when 'bug' then 'error'
      else 'neutral'
      end
    end
    
    def todo_type_icon(type)
      case type.to_s.downcase
      when 'todo' then '📝'
      when 'fixme' then '🔧'
      when 'hack' then '⚠️'
      when 'note' then '📋'
      when 'bug' then '🐛'
      else '📌'
      end
    end
    
    def todo_priority_class(type)
      case type.to_s.downcase
      when 'bug' then 'priority-high'
      when 'fixme' then 'priority-high' 
      when 'hack' then 'priority-medium'
      when 'todo' then 'priority-low'
      when 'note' then 'priority-low'
      else 'priority-low'
      end
    end
  end
end
