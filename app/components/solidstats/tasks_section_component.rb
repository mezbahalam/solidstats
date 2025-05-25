# frozen_string_literal: true

module Solidstats
  class TasksSectionComponent < BaseComponent
    def initialize(todo_items: [])
      @todo_items = todo_items
      super()
    end

    private

    attr_reader :todo_items

    def tab_items
      [
        { id: "todos", label: "TODO Items", active: true },
        { id: "fixmes", label: "FIXMEs" },
        { id: "hacks", label: "HACKs" }
      ]
    end
  end
end
