# frozen_string_literal: true

module Solidstats
  module Previews
    # Preview for StatusBadgeComponent
    class StatusBadgeComponentPreview < ViewComponent::Preview
      # Default status badge
      def default
        render(Solidstats::Ui::StatusBadgeComponent.new(status: :ok, text: "All Good"))
      end

      # Different status variants
      def statuses
        render_with_template(locals: {
          statuses: [
            { status: :ok, text: "Secure" },
            { status: :warning, text: "Minor Issues" },
            { status: :error, text: "Vulnerabilities Found" },
            { status: :info, text: "Info Available" },
            { status: :critical, text: "Critical Issues" }
          ]
        })
      end

      # Different sizes
      def sizes
        render_with_template(locals: {
          sizes: [
            { size: :small, status: :ok, text: "Small" },
            { size: :medium, status: :warning, text: "Medium" },
            { size: :large, status: :error, text: "Large" }
          ]
        })
      end

      # With icons
      def with_icons
        render_with_template(locals: {
          badges: [
            { status: :ok, text: "Secure", icon: "✓" },
            { status: :warning, text: "Warning", icon: "⚠" },
            { status: :error, text: "Error", icon: "✗" },
            { status: :info, text: "Info", icon: "ℹ" }
          ]
        })
      end
    end
  end
end
