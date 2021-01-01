# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RestartTurnButton < Snabberb::Component
      include Actionable

      def render
        action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: @game.round.turn_start))
        end
        h('button', { on: { click: action }, attrs: { disabled: button_disabled? } }, 'Restart Turn')
      end

      def button_disabled?
        !@game.undo_possible || !@game.round.turn_start || @game.round.turn_start == @game.last_game_action
      end
    end
  end
end
