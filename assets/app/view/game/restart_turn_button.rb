# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RestartTurnButton < Snabberb::Component
      include Actionable

      def render
        button_text = nil
        turn_start_action = nil
        if @game.turn_start_action != @game.last_game_action
          button_text = 'Restart Turn'
          turn_start_action = @game.turn_start_action
        else
          button_text = 'Restart Last Turn'
          turn_start_action = @game.last_turn_start_action
        end

        action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: turn_start_action))
        end

        h('button',
          { style: { marginTop: :inherit }, on: { click: action }, attrs: { disabled: button_disabled? } },
          button_text)
      end

      def button_disabled?
        !@game.undo_possible || !@game.turn_start_action
      end
    end
  end
end
