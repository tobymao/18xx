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

        ABILITIES = %i[tile_lay teleport assign_hexes assign_corporation token].freeze

        def render
          round = @game.round
          @step = round.active_step
          @current_actions = @step.current_actions
          action = [h(UndoAndPass, pass: @current_actions.include?('pass'))]

          action << h(RouteSelector) if @current_actions.include?('run_routes')
          action << h(Dividend) if @current_actions.include?('dividend')
          action << h(BuyTrains) if @current_actions.include?('buy_train')
          action << h(IssueShares) if @current_actions.include?('buy_shares')

          left = action
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
          right << h(:div, div_props, [h(BuyCompanies, limit_width: true)]) if @game.can_buy_any_company?

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
