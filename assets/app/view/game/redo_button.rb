# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RedoButton < Snabberb::Component
      include Actionable

      def render
        props = {
          on: {
            click: -> { process_action(Engine::Action::Redo.new(@game.current_entity)) },
          },
          style: {
            marginRight: '1em',
          },
        }

        h(:button, props, 'Redo')
      end
    end
  end
end
