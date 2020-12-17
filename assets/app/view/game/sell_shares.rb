# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class SellShares < Snabberb::Component
      include Actionable

      needs :player
      needs :corporation
      needs :action, default: Engine::Action::SellShares

      def render
        buttons = @game.sellable_bundles(@player, @corporation).map do |bundle|
          sell = lambda do
            process_action(@action.new(
              @player,
              shares: bundle.shares,
              share_price: bundle.share_price,
              percent: bundle.percent,
            ))
          end
          props = {
            style: {
              padding: '0.2rem 0',
              width: '6rem',
            },
            on: { click: sell },
          }
          h(
            'button.sell_share',
            props,
            "Sell #{share_presentation(bundle)} (#{@game.format_currency(bundle.price)})"
          )
        end

        step = @game.round.active_step
        @game.bundles_for_corporation(@player, @corporation).map do |bundle|
          pool_shares = @game.share_pool.shares_by_corporation[@corporation].group_by(&:percent).values.map(&:first)
          pool_shares.each do |pool_share|
            next unless (swap_sell = step.swap_sell(@player, @corporation, bundle, pool_share))

            buttons << sell_with_swap(@player, bundle, swap_sell)
          end
        end

        h(:div, buttons.compact)
      end

      private

      def share_presentation(bundle)
        num_shares = bundle.num_shares
        num_shares == 1 && bundle.percent != @corporation.share_percent ? "a #{bundle.percent}%" : num_shares.to_s
      end

      def sell_with_swap(player, bundle, swap_sell)
        reduced_price = @game.format_currency(bundle.price - swap_sell.price)
        swap = lambda do
          process_action(@action.new(
            player,
            shares: bundle.shares,
            share_price: bundle.share_price,
            percent: bundle.percent,
            swap: swap_sell,
          ))
        end
        props = {
          style: {
            padding: '0.2rem 0',
            width: '6rem',
          },
          on: { click: swap },
        }
        h('button.swap_share',
          props,
          "Sell #{share_presentation(bundle)} (#{reduced_price} + #{swap_sell.percent}% Share)")
      end

      def sell_bundle(player, bundle, swap: nil)
        process_action(@action.new(
          player,
          shares: bundle.shares,
          share_price: bundle.share_price,
          percent: bundle.percent,
          swap: swap,
        ))
      end
    end
  end
end
