# frozen_string_literal: true

module Solidstats
  module Ui
    # Reusable action button component with consistent styling
    class ActionButtonComponent < Solidstats::BaseComponent
      def initialize(text:, variant: :primary, size: :md, icon: nil, href: nil, **options)
        @text = text
        @variant = variant
        @size = size
        @icon = icon
        @href = href
        @options = options
        super()
      end
      
      private
      
      attr_reader :text, :variant, :size, :icon, :href, :options
      
      def button_classes
        css_classes(
          "action-button",
          variant_class,
          size_class,
          icon ? "action-button--with-icon" : nil
        )
      end
      
      def variant_class
        case variant
        when :secondary
          "action-button--secondary"
        when :danger
          "action-button--danger"
        when :ghost
          "action-button--ghost"
        else
          "action-button--primary"
        end
      end
      
      def size_class
        case size
        when :sm
          "action-button--sm"
        when :lg
          "action-button--lg"
        else
          "action-button--md"
        end
      end
      
      def tag_name
        href ? :a : :button
      end
      
      def tag_attributes
        base_attrs = { class: button_classes }
        
        if href
          base_attrs[:href] = href
        else
          base_attrs[:type] = options[:type] || "button"
        end
        
        base_attrs.merge(options.except(:type))
      end
    end
  end
end
