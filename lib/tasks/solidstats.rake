# frozen_string_literal: true

require "rails/generators"

namespace :solidstats do
  desc "Install Solidstats in your Rails application"
  task install: :environment do
    puts "🚀 Running Solidstats installer..."
    Rails::Generators.invoke("solidstats:install")
  end

  namespace :prime do
    desc "Prime data for all Solidstats services"
    task all: [
      :log_size,
      :bundler_audit,
      :todos,
      :style_patrol,
      :coverage,
      :load_lens
    ] do
      puts "✅ All Solidstats data has been primed."
    end

    desc "Prime data for LogSizeMonitorService"
    task log_size: :environment do
      puts "Priming data for Log Size Monitor..."
      Solidstats::LogSizeMonitorService.scan_and_cache
      puts "-> Log Size Monitor data primed."
    end

    desc "Prime data for BundlerAuditService"
    task bundler_audit: :environment do
      puts "Priming data for Bundler Audit..."
      Solidstats::BundlerAuditService.scan_and_cache
      puts "-> Bundler Audit data primed."
    end

    desc "Prime data for MyTodoService"
    task todos: :environment do
      puts "Priming data for My Todos..."
      Solidstats::MyTodoService.collect_todos
      puts "-> My Todos data primed."
    end

    desc "Prime data for StylePatrolService"
    task style_patrol: :environment do
      puts "Priming data for Style Patrol..."
      Solidstats::StylePatrolService.refresh_cache
      puts "-> Style Patrol data primed."
    end

    desc "Prime data for CoverageCompassService"
    task coverage: :environment do
      puts "Priming data for Coverage Compass..."
      Solidstats::CoverageCompassService.refresh_cache
      puts "-> Coverage Compass data primed."
    end

    desc "Prime data for LoadLensService"
    task load_lens: :environment do
      puts "Priming data for Load Lens..."
      Solidstats::LoadLensService.scan_and_cache
      puts "-> Load Lens data primed."
    end
  end
end
