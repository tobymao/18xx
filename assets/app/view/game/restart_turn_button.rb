# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RestartTurnButton < Snabberb::Component
      include Actionable

      def render
        undo = -> { process_action(Engine::Action::Undo.new(@game.current_entity, action_id: @game.round.turn_start)) }
        h(:button, { on: { click: undo } }, 'Restart Turn')
      end
    end
  end
end
