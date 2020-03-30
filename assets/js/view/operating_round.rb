# frozen_string_literal: true

require 'view/buy_companies'
require 'view/buy_trains'
require 'view/dividend'
require 'view/pass_button'
require 'view/route_selector'

module View
  class OperatingRound < Snabberb::Component
    needs :round

    def render
      children = []
      children << h(BuyCompanies) if @round.can_buy_companies?

      action =
        case @round.step
        when :track, :token
          h(PassButton)
        when :route
          h(RouteSelector)
        when :dividend
          h(Dividend)
        when :train
          h(BuyTrains)
        end

      children << action

      h(:div, children)
    end
  end
end
