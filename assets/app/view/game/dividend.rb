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
          h(:tr, [
            button,
            h('td.right', props, [@game.format_currency(corp_income)]),
            h('td.right', props, [@game.format_currency(option[:per_share])]),
            h(:td, [direction]),
          ])
        end

        div_props = {
          key: 'dividend',
          hook: {
            destroy: -> { cleanup },
          },
        }

        table_props = {
          style: {
            margin: '0.5rem 0 0 0',
            textAlign: 'left',
          },
        }
        share_props = { style: { width: '2.7rem' } }

        if corporation_interest_penalty?(entity)
          corporation_penalty = "#{entity.name} has " +
            @game.format_currency(@game.round.interest_penalty[entity]).to_s +
            ' deducted from its run for interest payments'
        end

        if player_interest_penalty?(entity)
          player_penalty = "#{entity.owner.name} paid " +
            @game.format_currency(@game.round.player_interest_penalty[entity]).to_s +
            ' to cover the remaining unpaid interest'
        end
        penalties = h(:span)
        penalties = h(:div, [
          h(:h3, 'Penalties'),
          h(:p, corporation_penalty),
          h(:p, player_penalty),
        ]) if corporation_interest_penalty?(entity) || player_interest_penalty?(entity)
        

        h(:div, div_props, [
          penalties,
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
        ])
        
      end

      def corporation_interest_penalty?(entity)
        @game.round.interest_penalty[entity] if @game.round.respond_to? :interest_penalty
      end

      def player_interest_penalty?(entity)
        @game.round.player_interest_penalty[entity] if @game.round.respond_to? :player_interest_penalty
      end

      def cleanup
        store(:routes, [], skip: true)
      end
    end
  end
end
