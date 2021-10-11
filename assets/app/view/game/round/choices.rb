# frozen_string_literal: true

module View
  module Game
    module Round
      class Choices < Snabberb::Component
        needs :game

        def render
          round = @game.round
          @step = round.active_step
          entity = @step.current_entity
          @current_actions = round.actions_for(entity)

          children = []
          children << h(Choose) if @current_actions.include?('choose')

          div_props = {
            style: {
              display: 'flex',
              maxWidth: '100%',
              width: 'max-content',
            },
          }

          h(:div, div_props, children)
        end
      end
    end
  end
end
