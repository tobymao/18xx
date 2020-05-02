# frozen_string_literal: true

require 'view/actionable'

module View
  class UndoButton < Snabberb::Component
    include Actionable

    def render
      props = {
        on: {
          click: -> { rollback },
        },
        style: {
          'margin-right': '1em',
        },
      }

      h(:button, props, 'Undo')
    end
  end
end
