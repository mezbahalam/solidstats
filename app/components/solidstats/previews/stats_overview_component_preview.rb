# frozen_string_literal: true

module Solidstats
  module Previews
    # Preview for StatsOverviewComponent
    class StatsOverviewComponentPreview < ViewComponent::Preview
      # Default metrics overview
      def default
        render(Solidstats::Ui::StatsOverviewComponent.new(
          metrics: sample_metrics
        ))
      end

      # Metrics with different statuses
      def different_statuses
        metrics = [
          { label: "Secure Gems", value: 95, icon: "🔒", status: :ok },
          { label: "Vulnerabilities", value: 3, icon: "⚠️", status: :warning },
          { label: "Critical Issues", value: 1, icon: "🚨", status: :error },
          { label: "Outdated Gems", value: 12, icon: "📅", status: :info }
        ]

        render(Solidstats::Ui::StatsOverviewComponent.new(metrics: metrics))
      end

      # Clickable metrics
      def clickable_metrics
        metrics = [
          {
            label: "Security Issues",
            value: 3,
            icon: "🔒",
            section: "security",
            tab: "vulnerabilities"
          },
          {
            label: "TODO Items",
            value: 15,
            icon: "📝",
            section: "tasks",
            href: "#tasks"
          }
        ]

        render(Solidstats::Ui::StatsOverviewComponent.new(metrics: metrics))
      end

      # Various value formats
      def value_formats
        metrics = [
          { label: "Test Coverage", value: "94%", icon: "🧪", status: :ok },
          { label: "Build Time", value: "2.3s", icon: "⏱️", status: :ok },
          { label: "Bundle Size", value: "1.2MB", icon: "📦", status: :warning },
          { label: "Dependencies", value: 127, icon: "💎", status: :info }
        ]

        render(Solidstats::Ui::StatsOverviewComponent.new(metrics: metrics))
      end

      private

      def sample_metrics
        [
          {
            label: "Security Issues",
            value: 0,
            icon: "🔒",
            zero_is_good: true,
            section: "security"
          },
          {
            label: "Gem Dependencies",
            value: 127,
            icon: "💎",
            status: :info
          },
          {
            label: "TODO Items",
            value: 8,
            icon: "📝",
            section: "tasks",
            tab: "todos"
          },
          {
            label: "Test Coverage",
            value: "94%",
            icon: "🧪",
            thresholds: { excellent: 90, good: 80, warning: 60 }
          },
          {
            label: "Log Files Size",
            value: "2.3MB",
            icon: "📊",
            status: :ok
          }
        ]
      end
    end
  end
end
