# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class SellShares < Snabberb::Component
      include Actionable

      needs :player
      needs :selected_corporation, default: nil, store: true

      def render
        buttons = @game.sellable_bundles(@player, @selected_corporation).map do |bundle|
          sell = lambda do
            process_action(Engine::Action::SellShares.new(
              @player,
              shares: bundle.shares,
              share_price: bundle.share_price,
              percent: bundle.percent,
            ))
          end

          num_shares = bundle.num_shares

          text = "Sell #{num_shares} (#{@game.format_currency(bundle.price)})"

          props = {
            style: {
              padding: '0.2rem 0',
              width: '6rem',
            },
            on: { click: sell },
          }
          h('button.sell_share', props, text)
        end

        h(:div, buttons.compact)
      end
    end
  end
end
