# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class SellShares < Snabberb::Component
      include Actionable

      needs :player
      needs :corporation

      def render
        buttons = @game.sellable_bundles(@player, @corporation).map do |bundle|
          sell = lambda do
            process_action(Engine::Action::SellShares.new(
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
          h('button.sell_share', props, "Sell #{share_presentation(bundle)} (#{@game.format_currency(bundle.price)})")
        end

        h(:div, buttons.compact)
      end

      private

      def share_presentation(bundle)
        num_shares = bundle.num_shares
        num_shares == 1 && bundle.percent != @corporation.share_percent ? "a #{bundle.percent}%" : num_shares.to_s
      end
    end
  end
end
