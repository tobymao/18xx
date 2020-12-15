# frozen_string_literal: true

require 'view/game/buy_companies'
require 'view/game/buy_special'
require 'view/game/buy_trains'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/player'
require 'view/game/dividend'
require 'view/game/issue_shares'
require 'view/game/corporate_buy_shares'
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

          entity = entity.owner if entity.company? && !round.active_entities.one?

          left = []
          left << h(BuySpecial) if @current_actions.include?('buy_special')
          left << h(RouteSelector) if @current_actions.include?('run_routes')
          left << h(Dividend) if @current_actions.include?('dividend')

          if @current_actions.include?('buy_train')
            left << h(IssueShares) if @current_actions.include?('sell_shares')
            left << h(BuyTrains)
          elsif @current_actions.include?('sell_shares') && entity.player?
            left << h(CashCrisis)
          elsif @current_actions.include?('buy_shares') || @current_actions.include?('sell_shares')
            left << h(IssueShares)
          elsif @current_actions.include?('corporate_buy_shares')
            left << h(CorporateBuyShares)
          elsif @current_actions.include?('corporate_sell_shares')
            left << h(CorporateSellShares)
          elsif @current_actions.include?('choose')
            left << h(Choose)
          end
          left << h(Loans, corporation: entity) if (%w[take_loan payoff_loan] & @current_actions).any?

          if entity.player?
            left << h(Player, player: entity, game: @game)
          elsif entity.operator? && entity.floated?
            left << h(Corporation, corporation: entity)
          elsif (company = entity).company?
            left << h(Company, company: company)

            if company.abilities(:assign_corporation)
              props = {
                style: {
                  display: 'inline-block',
                  verticalAlign: 'top',
                },
              }

              @step.assignable_corporations(company).each do |corporation|
                component = View::Game::Corporation.new(@root, corporation: corporation, selected_company: company)
                component.store(:selected_company, company, skip: true)
                left << h(:div, props, [component.render])
              end
            end
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
