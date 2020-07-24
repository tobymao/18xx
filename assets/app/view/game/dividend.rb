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
          button = h(:td, [h('button.margined', { on: { click: click } }, text)])
          direction = "#{option[:share_times]} #{option[:share_direction]}"

          h(:tr, [
            button,
            h(:td, [@game.format_currency(option[:company])]),
            h(:td, [@game.format_currency(option[:per_share])]),
            h(:td, [direction]),
            ])
        end

        table_props = {
          style: {
            marginTop: '0.5rem',
            textAlign: 'left',
          },
        }

        h(:table, table_props, [
          h(:thead, [
            h(:tr, [
              h(:th, 'Dividend'),
              h(:th, 'Company'),
              h(:th, 'Per Share'),
              h(:th, 'Stock Movement'),
            ]),
          ]),
          h(:tbody, payout_options),
        ])
      end
    end
  end
end
