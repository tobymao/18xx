# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Split < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        entity = @game.current_entity

        # Split handler
        handler = lambda do
          process_action(Engine::Action::Split.new(entity, corporation: @corporation))
        end

        # Split button properties
        props = {
          style: {
            width: 'calc(17.5rem/6)',
            padding: '0.2rem',
          },
          on: { click: handler },
        }

        # Split button
        h('button.small', props, 'Split')
      end
    end
  end
end
