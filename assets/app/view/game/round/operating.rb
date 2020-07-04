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

        ABILITIES = %i[tile_lay teleport assign_hexes token].freeze

        def render
          round = @game.round

          action =
            case round.step
            when :home_token
              h(UndoAndPass, pass: false)
            when :company, :track, :token, :token_or_track
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

          action = h(UndoAndPass, pass: false) if round.ambiguous_token

          left = [action]
          corporation = round.current_entity
          left << h(Corporation, corporation: corporation)
          corporation.owner.companies.each do |c|
            next if (c.all_abilities.map(&:type) & ABILITIES).empty?

            left << h(Company, display: 'block', company: c, game: @game)
          end

          div_props = {
            style: {
              display: 'flex',
            },
          }
          right = [h(Map, game: @game)]
          right << h(:div, div_props, [h(BuyCompanies, limit_width: true)]) if round.can_buy_companies?

          left_props = {
            style: {
              overflow: 'hidden',
              verticalAlign: 'top',
            },
          }

          right_props = {
            style: {
              maxWidth: '100%',
              width: 'max-content',
            },
          }

          children = [
            h('div#left.inline-block', left_props, left),
            h('div#right.inline-block', right_props, right),
          ]

          h(:div, children)
        end
      end
    end
  end
end
