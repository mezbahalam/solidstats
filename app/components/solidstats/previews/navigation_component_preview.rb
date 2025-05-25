# frozen_string_literal: true

module Solidstats
  module Previews
    # Preview for NavigationComponent
    class NavigationComponentPreview < ViewComponent::Preview
      # Default navigation
      def default
        render(Solidstats::Ui::NavigationComponent.new(
          current_section: "overview",
          sections: default_sections,
          actions: default_actions
        ))
      end

      # Navigation with different current section
      def different_current_section
        render(Solidstats::Ui::NavigationComponent.new(
          current_section: "security",
          sections: default_sections,
          actions: default_actions
        ))
      end

      # Navigation without actions
      def sections_only
        render(Solidstats::Ui::NavigationComponent.new(
          current_section: "overview",
          sections: default_sections,
          actions: []
        ))
      end

      # Custom sections and actions
      def custom_configuration
        custom_sections = [
          { id: "home", label: "Home", href: "/" },
          { id: "settings", label: "Settings", href: "/settings" },
          { id: "help", label: "Help", href: "/help" }
        ]

        custom_actions = [
          { label: "Save", icon: "💾", href: "#", onclick: "save(); return false;" },
          { label: "Reset", icon: "🔄", href: "#", onclick: "reset(); return false;" }
        ]

        render(Solidstats::Ui::NavigationComponent.new(
          current_section: "home",
          sections: custom_sections,
          actions: custom_actions
        ))
      end

      private

      def default_sections
        [
          { id: "overview", label: "Overview" },
          { id: "security", label: "Security" },
          { id: "code-quality", label: "Code Quality" },
          { id: "tasks", label: "Tasks" },
          { id: "gem-metadata", label: "Gem Metadata", href: "#gem-metadata" }
        ]
      end

      def default_actions
        [
          { label: "Refresh", icon: "↻", href: "#", onclick: "refresh(); return false;" },
          { label: "Export", icon: "↓", disabled: true, disabled_reason: "Export disabled" }
        ]
      end
    end
  end
end
