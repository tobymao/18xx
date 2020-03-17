# frozen_string_literal: true

require 'view/actionable'

module View
  class UndoButton < Snabberb::Component
    include Actionable

    def render
      props = {
        on: {
          click: -> { rollback }
        },
      }

      h(:button, props, 'Undo')
    end
  end
end
