# frozen_string_literal: true

module Solidstats
  class ProductivityController < ApplicationController
    layout 'solidstats/dashboard'
    
    def my_todos
      @todos = MyTodoService.collect_todos
      @summary = MyTodoService.get_summary
      
      # Group todos by type for display
      @todos_by_type = @todos.group_by { |todo| todo[:type] }
      
      # Recent todos (first 10 for quick view)
      @recent_todos = @todos.first(10)
      
      # Stats for dashboard
      @stats = {
        total: @todos.length,
        by_type: @todos_by_type.transform_values(&:count),
        files_with_todos: @todos.map { |t| t[:file] }.uniq.length
      }
      
      respond_to do |format|
        format.html
        format.json { render json: { todos: @todos, summary: @summary, stats: @stats } }
      end
    end
    
    def refresh_todos
      @todos = MyTodoService.collect_todos(force_refresh: true)
      
      respond_to do |format|
        format.html { redirect_to my_todos_productivity_path, notice: 'TODOs refreshed successfully!' }
        format.json { render json: { status: 'success', message: 'TODOs refreshed', count: @todos.length } }
      end
    end
  end
end
