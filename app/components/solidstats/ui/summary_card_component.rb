# frozen_string_literal: true

module Solidstats
  module Ui
    # Reusable summary card component for dashboard metrics
    class SummaryCardComponent < Solidstats::BaseComponent
      def initialize(title:, value:, status: :ok, icon: nil, section: nil, tab: nil, href: nil, **options)
        @title = title
        @value = value
        @status = status
        @icon = icon
        @section = section
        @tab = tab
        @href = href
        @options = options
      end

      private

      attr_reader :title, :value, :status, :icon, :section, :tab, :href, :options

      def card_classes
        css_classes(
          "summary-card",
          status.to_s,
          href ? "summary-card--clickable" : nil
        )
      end

      def card_attributes
        attrs = {
          class: card_classes,
          data: {
            section: section,
            tab: tab
          }.compact
        }.compact

        attrs.merge(options)
      end

      def formatted_value
        format_number(value)
      end

      def card_icon
        icon || status_icon(status)
      end

      def wrapper_tag
        href ? :a : :div
      end

      def wrapper_attributes
        if href
          { href: href }
        else
          {}
        end
      end
    end
  end
end
