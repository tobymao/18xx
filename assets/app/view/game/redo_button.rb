# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class RedoButton < Snabberb::Component
      include Actionable

      def render
        h(:button, { on: { click: -> { process_action(Engine::Action::Redo.new(@game.current_entity)) } } }, 'Redo')
      end
    end
  end
end
