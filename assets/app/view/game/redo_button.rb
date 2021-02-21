# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RedoButton < Snabberb::Component
      include Actionable

      def render
        h('button#redo',
          {
            attrs: {
              disabled: !@game.redo_possible,
              title: 'Redo – shortcut: ctrl+y',
            },
            on: {
              click: -> { process_action(Engine::Action::Redo.new(@game.current_entity)) },
            },
            style: {
              marginTop: 'inherit',
            },
          },
          'Redo')
      end
    end
  end
end
