# frozen_string_literal: true

require 'view/game/buy_companies'
require 'view/game/buy_trains'
require 'view/game/corporation'
require 'view/game/player'
require 'view/game/dividend'
require 'view/game/issue_shares'
require 'view/game/map'
require 'view/game/route_selector'
require 'view/game/cash_crisis'

module View
  module Game
    module Round
      class Operating < Snabberb::Component
        needs :game

        def render
          round = @game.round
          @step = round.active_step
          entity = @step.current_entity
          @current_actions = round.actions_for(entity)
          entity = entity.owner if entity.company?

          left = []
          left << h(RouteSelector) if @current_actions.include?('run_routes')
          left << h(Dividend) if @current_actions.include?('dividend')

          if @current_actions.include?('buy_train')
            left << h(IssueShares) if @current_actions.include?('sell_shares')
            left << h(BuyTrains)
          elsif @current_actions.include?('sell_shares') && entity.player?
            left << h(CashCrisis)
          end
          left << h(IssueShares) if @current_actions.include?('buy_shares')
          left << h(Loans, corporation: entity) if (%w[take_loan payoff_loan] & @current_actions).any?
          left << if entity.player?
                    h(Player, player: entity, game: @game)
                  else
                    h(Corporation, corporation: entity)
                  end

          div_props = {
            style: {
              display: 'flex',
            },
          }
          right = [h(Map, game: @game)]
          right << h(:div, div_props, [h(BuyCompanies, limit_width: true)]) if @current_actions.include?('buy_company')

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
