# frozen_string_literal: true

module Solidstats
  # Service to collect and process TODO items from codebase
  class TodoService < DataCollectorService
    # Initialize with default cache settings for TODO items
    def initialize
      super(Rails.root.join("tmp", "solidstats_todos.json"))
    end

    # Generate a summary for the dashboard display
    # @return [Hash] Summary information with counts and status
    def summary
      todos = fetch
      return { count: 0, status: "success", message: "No TODO items found" } if todos.nil? || todos.empty?

      stats = calculate_stats(todos)
      
      {
        count: todos.count,
        status: determine_status(todos),
        message: generate_message(todos.count),
        by_type: stats[:by_type],
        hotspots: stats[:hotspots]
      }
    end

    private

    # Calculate statistics for the TODO items
    # @param todos [Array] List of TODO items
    # @return [Hash] Statistics about the TODO items
    def calculate_stats(todos)
      stats = {
        by_type: {
          "TODO" => todos.count { |t| t[:type] == "TODO" },
          "FIXME" => todos.count { |t| t[:type] == "FIXME" },
          "HACK" => todos.count { |t| t[:type] == "HACK" }
        },
        by_file: {}
      }

      # Group by file path
      todos.each do |todo|
        file_path = todo[:file]
        stats[:by_file][file_path] ||= 0
        stats[:by_file][file_path] += 1
      end

      # Find files with most TODOs (top 5)
      stats[:hotspots] = stats[:by_file].sort_by { |_, count| -count }
                                       .first(5)
                                       .to_h

      stats
    end

    # Determine the status indicator based on TODO items
    # @param todos [Array] List of TODO items
    # @return [String] Status indicator (success, warning, or danger)
    def determine_status(todos)
      fixme_count = todos.count { |t| t[:type] == "FIXME" }
      hack_count = todos.count { |t| t[:type] == "HACK" }
      
      if hack_count > 0
        "danger"
      elsif fixme_count > 0
        "warning"
      elsif todos.count > 10
        "warning"
      else
        "success"
      end
    end

    # Generate a status message based on TODO count
    # @param count [Integer] Number of TODOs
    # @return [String] Human-readable status message
    def generate_message(count)
      "#{count} #{count == 1 ? 'item' : 'items'} found"
    end

    # Collect fresh TODO data by scanning the codebase
    # @return [Array] List of TODO items found
    def collect_data
      todos = []
      raw_output = `grep -r -n -E "(TODO|FIXME|HACK|todo|fixme|hack)" app lib`.split("\n")

      raw_output.each do |line|
        if line =~ /^(.+):(\d+):(.+)$/
          file = $1
          line_num = $2
          content = $3

          # Match only exact lowercase or uppercase variants
          type_match = content.match(/(TODO|FIXME|HACK|todo|fixme|hack)/)
          if type_match
            # Convert to uppercase for consistency
            type = type_match.to_s.upcase

            todos << {
              file: file,
              line: line_num.to_i,
              content: content.strip,
              type: type
            }
          end
        end
      end

      todos
    end
  end
end
