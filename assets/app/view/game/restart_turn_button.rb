# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RestartTurnButton < Snabberb::Component
      include Actionable

      def render
        button_text = nil
        turn_start = nil
        if @game.turn_start != @game.last_game_action
          button_text = 'Restart Turn'
          turn_start = @game.turn_start
        else
          button_text = 'Restart Last Turn'
          turn_start = @game.last_turn_start
        end

        action = lambda do
          process_action(Engine::Action::Undo.new(@game.current_entity, action_id: turn_start))
        end

        h('button',
          { style: { marginTop: :inherit }, on: { click: action }, attrs: { disabled: button_disabled? } },
          button_text)
      end

      def button_disabled?
        !@game.undo_possible || !@game.turn_start
      end
    end
  end
end
