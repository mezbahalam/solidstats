# frozen_string_literal: true

module Solidstats
  module Ui
    # Reusable status badge component for consistent status indicators
    class StatusBadgeComponent < Solidstats::BaseComponent
      def initialize(status:, text: nil, size: :md, show_icon: true)
        @status = status
        @text = text
        @size = size
        @show_icon = show_icon
      end
      
      private
      
      attr_reader :status, :text, :size, :show_icon
      
      def badge_text
        text || status_text(status)
      end
      
      def badge_classes
        css_classes(
          "status-badge",
          status_class(status),
          size_class
        )
      end
      
      def size_class
        case size
        when :sm
          "status-badge--sm"
        when :lg
          "status-badge--lg"
        else
          "status-badge--md"
        end
      end
    end
  end
end
