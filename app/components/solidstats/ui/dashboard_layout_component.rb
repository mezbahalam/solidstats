# frozen_string_literal: true

module Solidstats
  module Ui
    # Main dashboard layout component
    class DashboardLayoutComponent < Solidstats::BaseComponent
      def initialize(title:, subtitle: nil, navigation: {}, **options)
        @title = title
        @subtitle = subtitle
        @navigation = navigation
        @options = options
      end

      private

      attr_reader :title, :subtitle, :navigation, :options

      def dashboard_classes
        css_classes("solidstats-dashboard", options[:class])
      end

      def dashboard_attributes
        { class: dashboard_classes }.merge(options.except(:class))
      end

      def header_classes
        css_classes("dashboard-header")
      end

      def title_with_icon
        if title.include?("🚥")
          title
        else
          "🚥 #{title}"
        end
      end

      def formatted_subtitle
        return subtitle if subtitle

        # Default subtitle with current time
        "Last updated: #{Time.now.strftime('%B %d, %Y at %H:%M')}"
      end

      def navigation_sections
        navigation[:sections] || default_sections
      end

      def navigation_actions
        navigation[:actions] || default_actions
      end

      def current_section
        navigation[:current_section] || "overview"
      end

      def default_sections
        [
          { id: "overview", label: "Overview", href: "#overview" },
          { id: "security", label: "Security", href: "#security" },
          { id: "code-quality", label: "Code Quality", href: "#code-quality" },
          { id: "tasks", label: "Tasks", href: "#tasks" },
          { id: "gem-metadata", label: "Gem Metadata", href: "#gem-metadata" }
        ]
      end

      def default_actions
        [
          {
            label: "Refresh",
            icon: "↻",
            href: "#",
            onclick: "refreshAudit(); return false;"
          },
          {
            label: "Export",
            icon: "↓",
            disabled: true,
            disabled_reason: "Export is currently disabled"
          }
        ]
      end
    end
  end
end
