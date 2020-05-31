# frozen_string_literal: true

require 'view/actionable'

module View
  class UndoButton < Snabberb::Component
    include Actionable

    def render
      props = {
        on: {
          click: -> { process_action(Engine::Action::Undo.new(@game.current_entity)) },
        },
        style: {
          'margin-right': '1em',
        },
      }

      h('button.button', props, 'Undo')
    end
  end
end
