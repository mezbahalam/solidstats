# frozen_string_literal: true

module Solidstats
  module Ui
    # Tab navigation component for switching between related content sections
    class TabNavigationComponent < Solidstats::BaseComponent
      def initialize(tabs:, current_tab: nil, section_id: nil, **options)
        @tabs = tabs
        @current_tab = current_tab || tabs.first&.dig(:id)
        @section_id = section_id
        @options = options
      end

      private

      attr_reader :tabs, :current_tab, :section_id, :options

      def tabs_classes
        css_classes("tab-navigation", options[:class])
      end

      def tabs_attributes
        attrs = { class: tabs_classes }
        attrs["data-section"] = section_id if section_id
        attrs.merge(options.except(:class))
      end

      def tab_active?(tab)
        tab[:id] == current_tab
      end

      def tab_classes(tab)
        css_classes(
          "tab-item",
          tab_active?(tab) ? "active" : nil,
          tab[:disabled] ? "disabled" : nil
        )
      end

      def tab_attributes(tab)
        attrs = {
          class: tab_classes(tab),
          "data-tab": tab[:id]
        }

        if tab[:disabled]
          attrs[:disabled] = true
          attrs[:title] = tab[:disabled_reason] if tab[:disabled_reason]
        else
          attrs[:href] = tab[:href] || "##{section_id}-#{tab[:id]}"
        end

        attrs.compact
      end

      def tab_count_badge(tab)
        return unless tab[:count]

        count_classes = css_classes(
          "tab-count",
          tab[:count] > 0 ? "has-items" : "empty"
        )

        content_tag(:span, tab[:count], class: count_classes)
      end

      def tab_status_indicator(tab)
        return unless tab[:status]

        status_classes = css_classes(
          "tab-status",
          "tab-status--#{tab[:status]}"
        )

        content_tag(:span, "", class: status_classes, title: tab[:status_text])
      end
    end
  end
end
