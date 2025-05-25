# frozen_string_literal: true

require "test_helper"

module Solidstats
  module Ui
    class StatusBadgeComponentTest < ViewComponent::TestCase
      def test_renders_with_default_status
        render_inline(StatusBadgeComponent.new(status: :ok, text: "All Good"))
        
        assert_selector ".status-badge.status-badge--ok", text: "All Good"
      end

      def test_renders_different_statuses
        statuses = [:ok, :warning, :error, :info, :critical]
        
        statuses.each do |status|
          render_inline(StatusBadgeComponent.new(status: status, text: "Test"))
          assert_selector ".status-badge--#{status}"
        end
      end

      def test_renders_different_sizes
        sizes = [:small, :medium, :large]
        
        sizes.each do |size|
          render_inline(StatusBadgeComponent.new(status: :ok, text: "Test", size: size))
          assert_selector ".status-badge--#{size}"
        end
      end

      def test_renders_with_icon
        icon = "✓"
        render_inline(StatusBadgeComponent.new(status: :ok, text: "Test", icon: icon))
        
        assert_selector ".status-badge__icon", text: icon
        assert_selector ".status-badge__text", text: "Test"
      end

      def test_renders_without_icon
        render_inline(StatusBadgeComponent.new(status: :ok, text: "Test"))
        
        assert_no_selector ".status-badge__icon"
        assert_selector ".status-badge__text", text: "Test"
      end

      def test_applies_custom_classes
        render_inline(StatusBadgeComponent.new(
          status: :ok, 
          text: "Test", 
          class: "custom-class"
        ))
        
        assert_selector ".status-badge.custom-class"
      end

      def test_applies_data_attributes
        render_inline(StatusBadgeComponent.new(
          status: :ok, 
          text: "Test", 
          data: { testid: "status-badge" }
        ))
        
        assert_selector "[data-testid='status-badge']"
      end
    end
  end
end
