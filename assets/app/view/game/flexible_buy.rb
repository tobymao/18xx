# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/button/buy_share'

module View
  module Game
    class FlexibleBuy < Snabberb::Component
      include Actionable

      needs :flexible_player, default: nil, store: true
      needs :flexible_corporation, default: nil, store: true

      def render
        @step = @game.round.active_step
        @current_entity = @step.current_entity

        children = []

        bundles = @step.flexible_bundles(@current_entity, @flexible_player, @flexible_corporation)
        children << render_flexible_bundles(bundles) unless bundles.empty?

        h(:div, children)
      end

      def render_flexible_bundles(bundles)
        lines = []
        lines << h(:h3, "#{@flexible_corporation.name} shares owned by #{@flexible_player.name}:")

        header = h(:thead, [h(:tr, [
            h(:th, 'Percent'),
            h(:th, 'Value'),
            h(:th, 'Price'),
            h(:th, 'Buy'),
          ])])

        rows = bundles.map.with_index do |bundle, _idx|
          input_props = {
            style: {
              height: '1.5rem',
              width: '3rem',
              padding: '0 0 0 0.2rem',
              margin: '0',
            },
            attrs: {
              type: 'number',
              min: 1,
              max: @current_entity.cash,
              value: 1,
              size: @current_entity.cash.to_s.size + 2,
            },
          }
          input = h('input.no_margin', input_props)

          buy_shares_click = lambda do
            price = input.JS['elm'].JS['value'].to_i
            price_percent = bundle.corporation.type == :major ? 10 : 20
            share_price = (price * price_percent / bundle.percent).to_i
            next '' unless @step.flexible_can_buy_shares?(@current_entity, bundle.shares, price)

            buy_shares = lambda do
              process_action(
                Engine::Action::BuyShares.new(
                  @current_entity,
                  shares: bundle.shares,
                  percent: bundle.percent,
                  share_price: share_price,
                  total_price: price
                )
              )
            end
            check_consent(@current_entity, @flexible_player, buy_shares)
          end

          button = h('button.no_margin', { on: { click: buy_shares_click } }, 'Buy')

          h(:tr, [
            h(:td, "#{bundle.percent}%"),
            h(:td, @game.format_currency(bundle.price)),
            h(:td, [input]),
            h(:td, [button]),
          ])
        end

        table_props = {
          style: {
            color: 'black',
            border: '1px solid',
          },
        }

        lines << h(:table, table_props, [header, h(:tbody, rows)])
        h(:div, lines)
      end
    end
  end
end
