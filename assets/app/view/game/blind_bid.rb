# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class BlindBid < Snabberb::Component
      include Actionable

      def render
        @round = @game.round
        @current_entity = @round.current_entity
        @step = @round.active_step
        @current_actions = @step.current_actions

        choices = @step.blind_choices(@current_entity)
        @count = choices.size
        max = @step.blind_max(@current_entity)

        input = {}
        rows = choices.map.with_index do |entity, idx|
          label = @step.blind_label(entity)

          input[idx] = h('input.no_margin',
                         style: {
                           height: '1.6rem',
                           width: '4rem',
                           padding: '0 0 0 0.2rem',
                           margin: '0',
                         },
                         attrs: {
                           type: 'number',
                           min: 0,
                           max: max,
                           value: 0,
                           size: max.to_s.size + 2,
                         })
          h(:tr, [
            h(:td, [label]),
            h(:td, [input[idx]]),
          ])
        end

        click = lambda do
          amounts = input.keys.map { |k| input[k].JS['elm'].JS['value'].to_i }
          process_action(Engine::Action::BlindBid.new(
                           @game.current_entity,
                           bids: amounts,
                         ))
        end

        button = h('button', { style: { padding: '0.2rem 0.2rem' }, on: { click: click } }, 'Enter Bid')

        table_props = {
          style: {
            color: 'black',
            border: '1px solid',
          },
        }

        h(:div, [
          h(:table, table_props, [h(:tbody, rows)]),
          button,
        ])
      end
    end
  end
end
