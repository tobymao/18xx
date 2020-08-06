# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class Dividend < Snabberb::Component
      include Actionable

      def render
        @step = @game.active_step

        options = @step.dividend_options(@step.current_entity)

        payout_options = @step.dividend_types.map do |type|
          option = options[type]
          text =
            case type
            when :payout
              'Payout'
            when :withhold
              'Withhold'
            when :half
              'Half Pay'
            else
              type
            end

          click = lambda do
            process_action(Engine::Action::Dividend.new(@step.current_entity, kind: type))
          end
          button = h('td.no_padding', [h(:button, { style: { margin: '0.2rem 0' }, on: { click: click } }, text)])
          direction =
            if option[:share_direction]
              "#{option[:share_times]} #{option[:share_direction]}"
            else
              'None'
            end

          props = { style: { paddingRight: '1rem' } }
          h(:tr, [
            button,
            h('td.right', props, [@game.format_currency(option[:company])]),
            h('td.right', props, [@game.format_currency(option[:per_share])]),
            h(:td, [direction]),
          ])
        end

        table_props = {
          style: {
            margin: '0.5rem 0 0 0',
            textAlign: 'left',
          },
        }
        share_props = { style: { width: '2.7rem' } }

        h(:table, table_props, [
          h(:thead, [
            h(:tr, [
              h('th.no_padding', 'Dividend'),
              h(:th, 'Treasury'),
              h(:th, share_props, 'Per Share'),
              h(:th, 'Stock Moves'),
            ]),
          ]),
          h(:tbody, payout_options),
        ])
      end
    end
  end
end
