# frozen_string_literal: true

namespace :solidstats do
  namespace :load_lens do
    desc "Parse development log and extract LoadLens performance metrics"
    task parse_logs: :environment do
      result = Solidstats::LoadLensService.parse_log_and_save
      
      if result[:success]
        puts "Successfully parsed #{result[:processed]} requests for LoadLens"
      else
        puts "Error parsing logs for LoadLens: #{result[:error]}"
        exit 1
      end
    end

    desc "Refresh LoadLens performance data cache"
    task refresh: :environment do
      puts "Refreshing LoadLens performance data..."
      Solidstats::LoadLensService.refresh_data
      puts "LoadLens performance data refreshed successfully!"
    end

    desc "Show LoadLens performance data summary"
    task summary: :environment do
      data = Solidstats::LoadLensService.get_performance_data
      summary = data[:summary]
      
      puts "\n=== LoadLens Performance Summary ==="
      puts "Total Requests: #{summary[:total_requests]}"
      puts "Average Response Time: #{summary[:avg_response_time]}ms"
      puts "Average View Time: #{summary[:avg_view_time]}ms"
      puts "Average DB Time: #{summary[:avg_db_time]}ms"
      puts "Slow Requests (>1000ms): #{summary[:slow_requests]}"
      puts "Error Rate: #{summary[:error_rate]}%"
      puts "Status: #{summary[:status]}"
      puts "Last Updated: #{summary[:last_updated]}"
      puts "===================================="
    end

    desc "Clean old LoadLens performance data files"
    task clean_old_data: :environment do
      data_dir = Rails.root.join('tmp', 'solidstats')
      cutoff_date = 7.days.ago.to_date
      deleted_count = 0
      
      Dir.glob(data_dir.join('perf_*.json')).each do |file|
        if match = File.basename(file).match(/perf_(\d{4}-\d{2}-\d{2})\.json/)
          file_date = Date.parse(match[1])
          if file_date < cutoff_date
            File.delete(file)
            deleted_count += 1
            puts "Deleted #{File.basename(file)}"
          end
        end
      end
      
      puts "Cleaned #{deleted_count} old LoadLens performance data files"
    end
  end
  
  # Keep performance namespace for backward compatibility
  namespace :performance do
    desc "Parse development log and extract performance metrics (alias for load_lens:parse_logs)"
    task parse_logs: :environment do
      Rake::Task["solidstats:load_lens:parse_logs"].invoke
    end

    desc "Refresh performance data cache (alias for load_lens:refresh)"
    task refresh: :environment do
      Rake::Task["solidstats:load_lens:refresh"].invoke
    end

    desc "Show performance data summary (alias for load_lens:summary)"
    task summary: :environment do
      Rake::Task["solidstats:load_lens:summary"].invoke
    end

    desc "Clean old performance data files (alias for load_lens:clean_old_data)"
    task clean_old_data: :environment do
      Rake::Task["solidstats:load_lens:clean_old_data"].invoke
    end
  end
end
