# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    class Dividend < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :routes, store: true, default: []

      def render
        @step = @game.active_step

        entity = @step.current_entity
        return render_variable(entity) if @step.dividend_types.include?(:variable)

        options = @step.dividend_options(entity)

        store(:routes, @step.routes, skip: true)

        payout_options = options.keys.map do |type|
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
              @step.respond_to?(:dividend_name) ? @step.dividend_name(type) : type
            end

          corp_income = option[:corporation] + option[:divs_to_corporation]

          direction =
            if (new_share_price = entity.share_price) && option[:share_direction]
              moves = Array(option[:share_times]).zip(Array(option[:share_direction]))

              movement_str =
                moves.map do |times, dir|
                  real_moves = 0
                  times.times do
                    prev_price = new_share_price
                    new_share_price = @game.stock_market.find_relative_share_price(new_share_price, dir)
                    break if prev_price == new_share_price

                    real_moves += 1
                  end
                  next if real_moves.zero?

                  "#{real_moves} #{dir}"
                end.compact.join(', ')

              movement_str.empty? ? 'None' : movement_str
            else
              'None'
            end

          if entity.loans.any? && !@game.can_pay_interest?(entity, corp_income) && @game.cannot_pay_interest_str
            text += " #{@game.cannot_pay_interest_str}"
          elsif new_share_price&.acquisition?
            text += ' (Acquisition)'
          end

          click = lambda do
            process_action(Engine::Action::Dividend.new(@step.current_entity, kind: type))
            cleanup
          end
          button = h('td.no_padding', [h(:button, { style: { margin: '0.2rem 0' }, on: { click: click } }, text)])

          h(:tr, [
            button,
            h('td.padded_number', [@game.format_currency(corp_income)]),
            h('td.padded_number', [@game.format_currency(option[:per_share])]),
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
        if corporation_interest_penalty?(entity) || player_interest_penalty?(entity)
          penalties = h(:div, [
            h(:h3, 'Penalties'),
            h(:p, corporation_penalty),
            h(:p, player_penalty),
          ])
        end

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
          ]),
        ])
      end

      def corporation_interest_penalty?(entity)
        @game.round.interest_penalty[entity] if @game.round.respond_to?(:interest_penalty)
      end

      def player_interest_penalty?(entity)
        @game.round.player_interest_penalty[entity] if @game.round.respond_to?(:player_interest_penalty)
      end

      def cleanup
        store(:routes, [], skip: true)
      end

      def render_variable(entity)
        max = (@step.variable_max(entity) / @step.variable_share_multiplier(entity)).to_i

        input = h(:input,
                  props: {
                    value: max,
                    min: 0,
                    max: max,
                    type: 'number',
                    size: max.to_s.size + 2,
                    step: @step.variable_input_step,
                  })

        h(:div,
          [
            h(:h3, { style: { margin: '0.5rem 0 0.2rem 0' } }, 'Pay Dividends'),
            @step.help_str(max),
            h(:div, [
              input,
              h(:button, { on: { click: -> { create_dividend(input) } } }, 'Pay Dividend'),
            ]),
            dividend_chart,
        ])
      end

      def create_dividend(input)
        amount = input.JS['elm'].JS['value'].to_i * @step.variable_share_multiplier(@step.current_entity)
        process_action(Engine::Action::Dividend.new(@step.current_entity, kind: 'variable', amount: amount))
      end

      def dividend_chart
        header, *chart = @step.chart

        rows = chart.map do |r|
          h(:tr, r.map { |ri| h('td.padded_number', ri) })
        end

        table_props = {
          style: {
            margin: '0.5rem 0 0.5rem 0',
          },
        }

        h(:table, table_props, [
          h(:thead, [
            h(:tr, header.map { |hi| h(:th, hi) }),
          ]),
          h(:tbody, rows),
        ])
      end
    end
  end
end
