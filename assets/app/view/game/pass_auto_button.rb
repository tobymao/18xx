# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class PassAutoButton < Snabberb::Component
      include Actionable

      def render
        props = {
          on: {
            click: lambda do
              process_action(Engine::Action::ProgramSharePass.new(@game.current_entity))
            end,
          },
        }

        h(:button, props, 'Auto pass')
      end
    end
  end
end
