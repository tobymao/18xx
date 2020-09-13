# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class PassButton < Snabberb::Component
      include Actionable

      needs :before_process_pass, default: -> {}, store: true

      def render
        props = {
          on: {
            click: lambda do
              @before_process_pass.call
              process_action(Engine::Action::Pass.new(@game.current_entity))
            end,
          },
        }

        h(:button, props, @game.round.pass_description)
      end
    end
  end
end
