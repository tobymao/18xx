# frozen_string_literal: true

require 'view/actionable'

require 'engine/action/sell_shares'
require 'engine/share'

module View
  class SellShares < Snabberb::Component
    include Actionable

    needs :player
    needs :selected_corporation, default: nil, store: true

    def render
      shares = @player
        .shares_of(@selected_corporation)
        .sort_by(&:price)

      bundles = shares.flat_map.with_index do |share, index|
        bundle = shares.take(index + 1)
        percent = bundle.sum(&:percent)
        bundles = [Engine::ShareBundle.new(bundle, percent)]
        bundles.insert(0, Engine::ShareBundle.new(bundle, percent - 10)) if share.president
        bundles
      end

      buttons = bundles.map do |bundle|
        next unless @game.round.can_sell?(bundle)

        sell = lambda do
          process_action(Engine::Action::SellShares.new(@player, bundle.shares, bundle.percent))
        end

        num_shares = bundle.num_shares

        text = "Sell #{num_shares} share#{num_shares > 1 ? 's' : ''} "\
          "(#{@game.format_currency(bundle.price)})"

        h(:button, { on: { click: sell } }, text)
      end

      h(:div, { style: { 'margin-top': '1rem' } }, buttons.compact)
    end
  end
end
