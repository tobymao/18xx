# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class UndoButton < Snabberb::Component
      include Actionable

      def render
        h(:button, { on: { click: -> { process_action(Engine::Action::Undo.new(@game.current_entity)) } } }, 'Undo')
      end
    end
  end
end
