# frozen_string_literal: true

module Solidstats
  module Previews
    # Preview for SummaryCardComponent
    class SummaryCardComponentPreview < ViewComponent::Preview
      # Default summary card
      def default
        render(Solidstats::Ui::SummaryCardComponent.new(
          title: "Total Gems",
          value: 127,
          status: :ok
        ))
      end

      # Different statuses
      def statuses
        render_with_template(locals: {
          cards: [
            { title: "Secure Gems", value: 95, status: :ok, icon: "🔒" },
            { title: "Minor Issues", value: 12, status: :warning, icon: "⚠" },
            { title: "Vulnerabilities", value: 3, status: :error, icon: "🚨" },
            { title: "Outdated", value: 8, status: :info, icon: "📅" },
            { title: "Critical Issues", value: 1, status: :critical, icon: "💥" }
          ]
        })
      end

      # Clickable cards
      def clickable
        render_with_template(locals: {
          cards: [
            { title: "Security Issues", value: 3, status: :error, href: "/security", section: "security" },
            { title: "Code Quality", value: 85, status: :ok, href: "/quality", section: "quality" },
            { title: "Dependencies", value: 127, status: :warning, href: "/deps", section: "dependencies" }
          ]
        })
      end

      # With different value formats
      def value_formats
        render_with_template(locals: {
          cards: [
            { title: "Lines of Code", value: 15420, status: :info },
            { title: "Test Coverage", value: "92%", status: :ok },
            { title: "Build Time", value: "2.3s", status: :ok },
            { title: "Bundle Size", value: "1.2MB", status: :warning }
          ]
        })
      end

      # Dashboard layout example
      def dashboard_layout
        render_with_template(locals: {
          metrics: [
            { title: "Total Gems", value: 127, status: :ok, icon: "💎" },
            { title: "Vulnerabilities", value: 0, status: :ok, icon: "🔒" },
            { title: "Outdated", value: 8, status: :warning, icon: "📅" },
            { title: "Code Quality", value: "A+", status: :ok, icon: "⭐" },
            { title: "Test Coverage", value: "94%", status: :ok, icon: "🧪" },
            { title: "Build Status", value: "Passing", status: :ok, icon: "✅" }
          ]
        })
      end
    end
  end
end
