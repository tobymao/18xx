# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Convert < Snabberb::Component
      include Actionable

      def render
        click = lambda do
          process_action(Engine::Action::Convert.new(@game.current_entity))
        end

        props = {
          style: {
            padding: '0.2rem 0.2rem',
          },
          on: { click: click },
        }

        h(:div, [h('button', props, @game.round.active_step.description)])
      end
    end
  end
end
