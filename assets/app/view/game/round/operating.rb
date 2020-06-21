# frozen_string_literal: true

require 'view/game/buy_companies'
require 'view/game/buy_trains'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/dividend'
require 'view/game/issue_shares'
require 'view/game/map'
require 'view/game/undo_and_pass'
require 'view/game/route_selector'

module View
  module Game
    module Round
      class Operating < Snabberb::Component
        needs :game

        def render
          round = @game.round
          children = []

          action =
            case round.step
            when :home_token
              h(UndoAndPass, pass: false)
            when :company, :track, :token, :token_or_track, :reposition_token
              h(UndoAndPass)
            when :route
              h(RouteSelector)
            when :dividend
              h(Dividend)
            when :train
              h(BuyTrains)
            when :issue
              h(IssueShares)
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
  end
end
