# frozen_string_literal: true

require "test_helper"

module Solidstats
  module Ui
    class SummaryCardComponentTest < ViewComponent::TestCase
      def test_renders_basic_card
        render_inline(SummaryCardComponent.new(
          title: "Total Gems",
          value: 127,
          status: :ok
        ))

        assert_selector ".summary-card.summary-card--ok"
        assert_selector ".summary-card__title", text: "Total Gems"
        assert_selector ".summary-card__value", text: "127"
      end

      def test_renders_different_statuses
        statuses = [ :ok, :warning, :error, :info, :critical ]

        statuses.each do |status|
          render_inline(SummaryCardComponent.new(
            title: "Test",
            value: 100,
            status: status
          ))
          assert_selector ".summary-card--#{status}"
        end
      end

      def test_renders_as_clickable_link
        render_inline(SummaryCardComponent.new(
          title: "Security Issues",
          value: 3,
          status: :error,
          href: "/security"
        ))

        assert_selector "a.summary-card--clickable[href='/security']"
        assert_selector ".summary-card__title", text: "Security Issues"
        assert_selector ".summary-card__value", text: "3"
      end

      def test_renders_as_div_without_href
        render_inline(SummaryCardComponent.new(
          title: "Test Card",
          value: 42,
          status: :ok
        ))

        assert_selector "div .summary-card"
        assert_no_selector "a.summary-card"
      end

      def test_renders_with_icon
        icon = "🔒"
        render_inline(SummaryCardComponent.new(
          title: "Secure Gems",
          value: 95,
          status: :ok,
          icon: icon
        ))

        assert_selector ".summary-card__icon", text: icon
      end

      def test_renders_with_status_icon_when_no_icon_provided
        render_inline(SummaryCardComponent.new(
          title: "Warning Items",
          value: 5,
          status: :warning
        ))

        # Should render status icon from BaseComponent
        assert_selector ".summary-card__icon"
      end

      def test_formats_numeric_values
        render_inline(SummaryCardComponent.new(
          title: "Large Number",
          value: 1234567,
          status: :ok
        ))

        # Should format using BaseComponent's format_number method
        assert_selector ".summary-card__value", text: "1,234,567"
      end

      def test_renders_string_values_as_is
        render_inline(SummaryCardComponent.new(
          title: "Coverage",
          value: "94%",
          status: :ok
        ))

        assert_selector ".summary-card__value", text: "94%"
      end

      def test_applies_section_data_attribute
        render_inline(SummaryCardComponent.new(
          title: "Test",
          value: 100,
          status: :ok,
          section: "security"
        ))

        assert_selector "[data-section='security']"
      end

      def test_applies_custom_classes
        render_inline(SummaryCardComponent.new(
          title: "Test",
          value: 100,
          status: :ok,
          class: "custom-class"
        ))

        assert_selector ".summary-card.custom-class"
      end

      def test_applies_data_attributes
        render_inline(SummaryCardComponent.new(
          title: "Test",
          value: 100,
          status: :ok,
          data: { testid: "summary-card" }
        ))

        assert_selector "[data-testid='summary-card']"
      end

      def test_renders_content_block
        component = SummaryCardComponent.new(
          title: "Test",
          value: 100,
          status: :ok
        )

        render_inline(component) do
          "Additional description content"
        end

        assert_selector ".summary-card__description", text: "Additional description content"
      end
    end
  end
end
