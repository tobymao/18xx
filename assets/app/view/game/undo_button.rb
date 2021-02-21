# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class UndoButton < Snabberb::Component
      include Actionable

      def render
        h('button#undo',
          {
            attrs: {
              disabled: !@game.undo_possible,
              title: 'Undo – shortcut: ctrl+z',
            },
            on: {
              click: -> { process_action(Engine::Action::Undo.new(@game.current_entity)) },
            },
            style: {
              marginTop: 'inherit',
            },
          },
          'Undo')
      end
    end
  end
end
