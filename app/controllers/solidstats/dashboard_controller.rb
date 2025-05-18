module Solidstats
  class DashboardController < ApplicationController
    def index
      @audit_output = `bundle audit check --update`
      @rubocop_output = JSON.parse(`rubocop --format json`)
      @todo_count = `grep -r -E \"TODO|FIXME|HACK\" app lib | wc -l`.to_i
      @coverage = read_coverage_percent
    end

    private

    def read_coverage_percent
      file = Rails.root.join("coverage", ".last_run.json")
      return 0 unless File.exist?(file)

      data = JSON.parse(File.read(file))
      data.dig("result", "covered_percent").to_f.round(2)
    end
  end
end