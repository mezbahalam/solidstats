# frozen_string_literal: true

module Solidstats
  module Ui
    # Navigation component for dashboard sections
    class NavigationComponent < Solidstats::BaseComponent
      def initialize(current_section: "overview", sections: [], actions: [], **options)
        @current_section = current_section
        @sections = sections
        @actions = actions
        @options = options
      end

      private

      attr_reader :current_section, :sections, :actions, :options

      def nav_classes
        css_classes("dashboard-nav", options[:class])
      end

      def nav_attributes
        { class: nav_classes }.merge(options.except(:class))
      end

      def section_active?(section)
        section[:id] == current_section
      end

      def section_classes(section)
        css_classes(
          "nav-item",
          section_active?(section) ? "active" : nil
        )
      end

      def section_attributes(section)
        {
          href: section[:href] || "##{section[:id]}",
          class: section_classes(section),
          "data-section": section[:id]
        }.compact
      end

      def action_classes(action)
        css_classes(
          "action-button",
          action[:disabled] ? "action-button--disabled" : nil
        )
      end

      def action_attributes(action)
        attrs = {
          class: action_classes(action),
          href: action[:href]
        }

        if action[:onclick]
          attrs[:onclick] = action[:onclick]
        end

        if action[:disabled]
          attrs[:disabled] = true
          attrs[:title] = action[:disabled_reason] if action[:disabled_reason]
          attrs[:style] = "cursor: not-allowed;"
        end

        attrs.compact
      end
    end
  end
end
