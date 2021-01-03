# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RedoButton < Snabberb::Component
      include Actionable

      def render
        action = -> { process_action(Engine::Action::Redo.new(@game.current_entity)) }
        h(:button,
          { style: { marginTop: :inherit }, on: { click: action }, attrs: { disabled: !@game.redo_possible } },
          'Redo')
      end
    end
  end
end
