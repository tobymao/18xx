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

          num_shares = bundle.num_shares

          text = num_shares == 1 && bundle.percent != 10 ? "a #{bundle.percent}%" : num_shares.to_s

          props = {
            style: {
              padding: '0.2rem 0',
              width: '6rem',
            },
            on: { click: sell },
          }
          h('button.sell_share', props, "Sell #{text} (#{@game.format_currency(bundle.price)})")
        end

        h(:div, buttons.compact)
      end
    end
  end
end
