# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class Dividend < Snabberb::Component
      include Actionable

      needs :routes, store: true, default: []

      def render
        @step = @game.active_step

        entity = @step.current_entity
        options = @step.dividend_options(entity)

        store(:routes, @step.routes, skip: true)

        payout_options = @step.dividend_types.map do |type|
          option = options[type]
          text =
            case type
            when :payout
              'Pay Out'
            when :withhold
              'Withhold'
            when :half
              'Half Pay'
            else
              type
            end

          corp_income = option[:corporation] + option[:divs_to_corporation]
          new_share = entity.share_price

          direction =
            if option[:share_direction]
              moves = Array(option[:share_times]).zip(Array(option[:share_direction]))

              moves.map do |times, dir|
                times.times { new_share = @game.stock_market.find_relative_share_price(new_share, dir) }

                "#{times} #{dir}"
              end.join(', ')
            else
              'None'
            end

          if entity.loans.any? && !@game.can_pay_interest?(entity, corp_income)
            text += ' (Liquidate)'
          elsif new_share.acquisition?
            text += ' (Acquisition)'
          end

          click = lambda do
            process_action(Engine::Action::Dividend.new(@step.current_entity, kind: type))
            cleanup
          end
          button = h('td.no_padding', [h(:button, { style: { margin: '0.2rem 0' }, on: { click: click } }, text)])

          props = { style: { paddingRight: '1rem' } }
          columns = [
            button,
            h('td.right', props, [@game.format_currency(corp_income)]),
            h('td.right', props, [@game.format_currency(option[:per_share])]),
            h(:td, [direction]),
          ]
          if @game.class::PENALTY_TYPE
            columns.insert(2, h('td.right', props, [@game.format_currency(option[:penalty])]))
          end
          h(:tr, columns)
        end

        table_props = {
          style: {
            margin: '0.5rem 0 0 0',
            textAlign: 'left',
          },
          key: 'dividend',
          hook: {
            destroy: -> { cleanup },
          },
        }
        share_props = { style: { width: '2.7rem' } }
        columns = [
          h('th.no_padding', 'Dividend'),
          h(:th, 'Treasury'),
          h(:th, share_props, 'Per Share'),
          h(:th, 'Stock Moves'),
        ]
        if @game.class::PENALTY_TYPE
          columns.insert(2, h(:th, @game.class::PENALTY_TYPE))
        end
        h(:table, table_props, [
          h(:thead, [
            h(:tr, columns),
          ]),
          h(:tbody, payout_options),
        ])
      end

      def cleanup
        store(:routes, [], skip: true)
      end
    end
  end
end
