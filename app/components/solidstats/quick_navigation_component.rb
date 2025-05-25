# frozen_string_literal: true

module Solidstats
  class QuickNavigationComponent < BaseComponent
    def initialize
      super()
    end

    private

    def navigation_items
      [
        { href: "#overview", label: "Overview" },
        { href: "#security", label: "Security" },
        { href: "#code-quality", label: "Code Quality" },
        { href: "#gem-metadata", label: "Gem Metadata" },
        { href: "#tasks", label: "Tasks" }
      ]
    end
  end
end
