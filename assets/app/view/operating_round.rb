# frozen_string_literal: true

require 'view/buy_companies'
require 'view/buy_trains'
require 'view/company'
require 'view/corporation'
require 'view/dividend'
require 'view/map'
require 'view/undo_and_pass'
require 'view/route_selector'

module View
  class OperatingRound < Snabberb::Component
    needs :game

    def render
      round = @game.round
      children = []

      action =
        case round.step
        when :company, :track, :token
          h(UndoAndPass)
        when :route
          h(RouteSelector)
        when :dividend
          h(Dividend)
        when :train
          h(BuyTrains)
        end

      children << action
      corporation = round.current_entity
      children << h(Corporation, corporation: corporation)
      (corporation.companies + corporation.owner.companies).each do |c|
        children << h(Company, company: c) if c.abilities(:tile_lay) || c.abilities(:teleport)
      end
      children << h(Map, game: @game)
      children << h(BuyCompanies) if round.can_buy_companies?

      h(:div, children)
    end
  end
end
