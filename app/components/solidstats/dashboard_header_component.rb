# frozen_string_literal: true

module Solidstats
  class DashboardHeaderComponent < BaseComponent
    def initialize(audit_output:)
      @audit_output = audit_output
      super()
    end

    private

    attr_reader :audit_output

    def last_updated_date
      created_at = audit_output.dig("created_at")
      if created_at
        DateTime.parse(created_at).strftime("%B %d, %Y at %H:%M")
      else
        Time.now.strftime("%B %d, %Y at %H:%M")
      end
    end

    def navigation_items
      [
        { id: "overview", label: "Overview", href: "#overview", active: true },
        { id: "security", label: "Security", href: "#security" },
        { id: "code-quality", label: "Code Quality", href: "#code-quality" },
        { id: "tasks", label: "Tasks", href: "#tasks" },
        { id: "gem-metadata", label: "Gem Metadata", href: "#gem-metadata" }
      ]
    end
  end
end
