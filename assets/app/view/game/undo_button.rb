# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class UndoButton < Snabberb::Component
      include Actionable

      def render
        action = -> { process_action(Engine::Action::Undo.new(@game.current_entity)) }
        h(:button,
          { style: { marginTop: :inherit }, on: { click: action }, attrs: { disabled: !@game.undo_possible } },
          'Undo')
      end
    end
  end
end
