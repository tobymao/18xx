# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RestartTurnButton < Snabberb::Component
      include Actionable

      def render
        button_text, turn_start_action_id =
          if @game.turn_start_action_id != @game.last_game_action_id
            ['Restart Turn', @game.turn_start_action_id]
          else
            ['Restart Last Turn', @game.last_turn_start_action_id]
          end

        action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: turn_start_action_id))
        end

        h('button',
          { style: { marginTop: :inherit }, on: { click: action }, attrs: { disabled: button_disabled? } },
          button_text)
      end

      def button_disabled?
        !@game.undo_possible || !@game.turn_start_action_id
      end
    end
  end
end
