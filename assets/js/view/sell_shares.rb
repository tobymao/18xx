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

      buttons = shares.size.times.map do |n|
        bundle = shares.take(n + 1)
        next unless @game.round.can_sell?(bundle)

        num = bundle.size
        percent = bundle.sum(&:percent)
        sell = -> { process_action(Engine::Action::SellShares.new(@player, bundle)) }
        text = "Sell #{num} share#{num > 1 ? 's' : ''} (#{percent}% - "\
               "#{@game.format_currency(Engine::Share.price(bundle))})"
        h(:button, { on: { click: sell } }, text)
      end

      h(:div, buttons.compact)
    end
  end
end
