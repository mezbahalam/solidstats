# frozen_string_literal: true

require "test_helper"

module Solidstats
  module Ui
    class ActionButtonComponentTest < ViewComponent::TestCase
      def test_renders_as_link_with_href
        render_inline(ActionButtonComponent.new(
          text: "Click Me", 
          href: "/test",
          variant: :primary
        ))
        
        assert_selector "a.action-button.action-button--primary[href='/test']", text: "Click Me"
      end

      def test_renders_as_button_without_href
        render_inline(ActionButtonComponent.new(
          text: "Submit",
          variant: :primary,
          type: "submit"
        ))
        
        assert_selector "button.action-button.action-button--primary[type='submit']", text: "Submit"
      end

      def test_renders_different_variants
        variants = [:primary, :secondary, :outline, :ghost, :danger]
        
        variants.each do |variant|
          render_inline(ActionButtonComponent.new(
            text: "Test", 
            variant: variant,
            href: "#"
          ))
          assert_selector ".action-button--#{variant}"
        end
      end

      def test_renders_different_sizes
        sizes = [:small, :medium, :large]
        
        sizes.each do |size|
          render_inline(ActionButtonComponent.new(
            text: "Test", 
            variant: :primary,
            size: size,
            href: "#"
          ))
          assert_selector ".action-button--#{size}"
        end
      end

      def test_renders_with_icon
        icon = "⬇"
        render_inline(ActionButtonComponent.new(
          text: "Download",
          variant: :primary,
          icon: icon,
          href: "#"
        ))
        
        assert_selector ".action-button__icon", text: icon
        assert_selector ".action-button__text", text: "Download"
      end

      def test_renders_without_icon
        render_inline(ActionButtonComponent.new(
          text: "Click Me",
          variant: :primary,
          href: "#"
        ))
        
        assert_no_selector ".action-button__icon"
        assert_selector ".action-button__text", text: "Click Me"
      end

      def test_applies_custom_classes
        render_inline(ActionButtonComponent.new(
          text: "Test",
          variant: :primary,
          href: "#",
          class: "custom-class"
        ))
        
        assert_selector ".action-button.custom-class"
      end

      def test_applies_data_attributes
        render_inline(ActionButtonComponent.new(
          text: "Test",
          variant: :primary,
          href: "#",
          data: { testid: "action-button" }
        ))
        
        assert_selector "[data-testid='action-button']"
      end
    end
  end
end
