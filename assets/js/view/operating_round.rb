# frozen_string_literal: true

require 'view/buy_trains'
require 'view/dividend'
require 'view/pass_button'
require 'view/route_selector'

module View
  class OperatingRound < Snabberb::Component
    needs :game, store: true

    def render
      case @game.round.step
      when :track, :token
        h(PassButton)
      when :route
        h(RouteSelector)
      when :dividend
        h(Dividend)
      when :train
        h(BuyTrains)
      end
    end
  end
end
