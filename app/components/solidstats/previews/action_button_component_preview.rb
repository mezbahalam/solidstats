# frozen_string_literal: true

module Solidstats
  module Previews
    # Preview for ActionButtonComponent
    class ActionButtonComponentPreview < ViewComponent::Preview
      # Default action button
      def default
        render(Solidstats::Ui::ActionButtonComponent.new(
          text: "Click Me", 
          href: "#", 
          variant: :primary
        ))
      end

      # Different variants
      def variants
        render_with_template(locals: {
          buttons: [
            { text: "Primary", href: "#", variant: :primary },
            { text: "Secondary", href: "#", variant: :secondary },
            { text: "Outline", href: "#", variant: :outline },
            { text: "Ghost", href: "#", variant: :ghost },
            { text: "Danger", href: "#", variant: :danger }
          ]
        })
      end

      # Different sizes
      def sizes
        render_with_template(locals: {
          buttons: [
            { text: "Small", href: "#", variant: :primary, size: :small },
            { text: "Medium", href: "#", variant: :primary, size: :medium },
            { text: "Large", href: "#", variant: :primary, size: :large }
          ]
        })
      end

      # With icons
      def with_icons
        render_with_template(locals: {
          buttons: [
            { text: "Download", href: "#", variant: :primary, icon: "⬇" },
            { text: "Edit", href: "#", variant: :secondary, icon: "✏" },
            { text: "Delete", href: "#", variant: :danger, icon: "🗑" },
            { text: "Refresh", href: "#", variant: :outline, icon: "🔄" }
          ]
        })
      end

      # As buttons vs links
      def button_vs_link
        render_with_template(locals: {
          elements: [
            { text: "Link Button", href: "#", variant: :primary },
            { text: "Submit Button", variant: :primary, type: "submit" },
            { text: "Regular Button", variant: :secondary, type: "button" }
          ]
        })
      end
    end
  end
end
