# frozen_string_literal: true

require "find"
require "json"

module Solidstats
  # Enhanced TODO service for comprehensive project scanning
  class MyTodoService
    CACHE_FILE = Rails.root.join("solidstats", "todos.json")
    CACHE_DURATION = 24.hours

    TODO_PATTERNS = [
      /TODO:?\s*(.+)/i,
      /FIXME:?\s*(.+)/i,
      /HACK:?\s*(.+)/i,
      /NOTE:?\s*(.+)/i,
      /BUG:?\s*(.+)/i
    ].freeze

    SCAN_EXTENSIONS = %w[.rb .js .html .erb .yml .yaml .json .css .scss .vue .jsx .tsx .ts].freeze
    EXCLUDE_DIRS = %w[node_modules vendor tmp log public/assets .git coverage pkg app/assets/builds solidstats].freeze

    def self.collect_todos(force_refresh: false)
      return cached_todos unless force_refresh || cache_expired?

      todos = scan_project_files
      cache_todos(todos)
      update_summary_json(todos)
      todos
    end

    def self.get_summary
      todos = collect_todos
      {
        total_count: todos.length,
        by_type: todos.group_by { |t| t[:type] }.transform_values(&:count),
        by_file: todos.group_by { |t| t[:file] }.transform_values(&:count),
        top_files: todos.group_by { |t| t[:file] }
                       .transform_values(&:count)
                       .sort_by { |_, count| -count }
                       .first(5)
                       .to_h,
        status: determine_status(todos),
        last_updated: Time.current.iso8601
      }
    end

    private

    def self.scan_project_files
      todos = []
      exclude_patterns = load_gitignore_patterns

      Find.find(Rails.root) do |path|
        if File.directory?(path)
          Find.prune if should_exclude_directory?(path, exclude_patterns)
          next
        end

        next unless should_scan_file?(path)
        next if excluded_by_gitignore?(path, exclude_patterns)

        scan_file_for_todos(path, todos)
      end

      todos.sort_by { |todo| [ todo[:file], todo[:line_number] ] }
    end

    def self.scan_file_for_todos(file_path, todos)
      relative_path = file_path.sub("#{Rails.root}/", "")

      File.readlines(file_path, chomp: true).each_with_index do |line, index|
        TODO_PATTERNS.each do |pattern|
          if match = line.match(pattern)
            todos << {
              file: relative_path,
              line_number: index + 1,
              content: match[1]&.strip || line.strip,
              type: extract_todo_type(line),
              full_line: line.strip,
              created_at: Time.current
            }
            break # Only match first pattern per line
          end
        end
      end
    rescue => e
      Rails.logger.warn "Error scanning file #{file_path}: #{e.message}"
    end

    def self.extract_todo_type(line)
      case line.upcase
      when /TODO/ then "todo"
      when /FIXME/ then "fixme"
      when /HACK/ then "hack"
      when /NOTE/ then "note"
      when /BUG/ then "bug"
      else "todo"
      end
    end

    def self.should_exclude_directory?(path, exclude_patterns)
      relative_path = path.sub("#{Rails.root}/", "")

      # Check standard exclude directories
      EXCLUDE_DIRS.each do |dir|
        # Check if this directory or any parent directory matches
        path_parts = relative_path.split("/")
        return true if path_parts.include?(dir)
        return true if relative_path == dir
        return true if relative_path.start_with?("#{dir}/")
      end

      # Check gitignore patterns
      return true if exclude_patterns.any? { |pattern| File.fnmatch(pattern, relative_path, File::FNM_PATHNAME) }

      false
    end

    def self.should_scan_file?(path)
      SCAN_EXTENSIONS.any? { |ext| path.end_with?(ext) }
    end

    def self.excluded_by_gitignore?(file_path, exclude_patterns)
      relative_path = file_path.sub("#{Rails.root}/", "")
      exclude_patterns.any? { |pattern| File.fnmatch(pattern, relative_path, File::FNM_PATHNAME) }
    end

    def self.load_gitignore_patterns
      gitignore_path = Rails.root.join(".gitignore")
      return [] unless File.exist?(gitignore_path)

      patterns = []
      File.readlines(gitignore_path, chomp: true).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        # Convert gitignore patterns to fnmatch patterns
        pattern = line.gsub(/\*\*/, "*")
        pattern = pattern.chomp("/")
        patterns << pattern
        patterns << "#{pattern}/*" if !pattern.include?("*")
      end

      patterns
    end

    def self.cached_todos
      return [] unless File.exist?(CACHE_FILE)

      JSON.parse(File.read(CACHE_FILE), symbolize_names: true)
    rescue JSON::ParserError
      []
    end

    def self.cache_todos(todos)
      FileUtils.mkdir_p(File.dirname(CACHE_FILE))
      File.write(CACHE_FILE, todos.to_json)
    end

    def self.cache_expired?
      return true unless File.exist?(CACHE_FILE)

      File.mtime(CACHE_FILE) < CACHE_DURATION.ago
    end

    def self.update_summary_json(todos)
      summary_file_path = Rails.root.join("solidstats", "summary.json")

      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(summary_file_path))

      # Read existing summary or create new one
      begin
        existing_summary = File.exist?(summary_file_path) ? JSON.parse(File.read(summary_file_path)) : {}
      rescue JSON::ParserError
        existing_summary = {}
      end

      # Calculate TODO statistics
      todo_count = todos.length
      status = determine_status(todos)
      type_counts = todos.group_by { |t| t[:type] }.transform_values(&:count)

      # Create badges based on TODO types and counts
      badges = []
      badges << { "text" => "#{todo_count} Items", "color" => "info" }

      %w[todo fixme hack note bug].each do |type|
        count = type_counts[type] || 0
        if count > 0
          color = case type
          when "fixme" then "warning"
          when "hack", "bug" then "error"
          else "info"
          end
          badges << { "text" => "#{type.upcase}: #{count}", "color" => color }
        end
      end

      # Update the TODO items entry
      existing_summary["TODO Items"] = {
        "icon" => "list-todo",
        "status" => status,
        "value" => generate_message(todo_count),
        "last_updated" => Time.current.iso8601,
        "url" => "/solidstats/productivity/my_todos",
        "badges" => badges
      }

      # Write updated summary
      File.write(summary_file_path, JSON.pretty_generate(existing_summary))
      Rails.logger.info("Updated summary.json with TODO items")
    rescue => e
      Rails.logger.error("Failed to update summary.json: #{e.message}")
    end

    def self.determine_status(todos)
      return "success" if todos.empty?

      fixme_count = todos.count { |t| t[:type] == "fixme" }
      hack_count = todos.count { |t| t[:type] == "hack" }
      bug_count = todos.count { |t| t[:type] == "bug" }

      if bug_count > 0 || hack_count > 0
        "error"
      elsif fixme_count > 0 || todos.length > 20
        "warning"
      else
        "success"
      end
    end

    def self.generate_message(count)
      case count
      when 0 then "No items found"
      when 1 then "1 item found"
      else "#{count} items found"
      end
    end
  end
end
