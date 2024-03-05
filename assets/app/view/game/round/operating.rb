# frozen_string_literal: true

require 'view/game/acquire_companies'
require 'view/game/buy_companies'
require 'view/game/special_buy'
require 'view/game/buy_trains'
require 'view/game/borrow_train'
require 'view/game/convert'
require 'view/game/switch_trains'
require 'view/game/reassign_trains'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/player'
require 'view/game/dividend'
require 'view/game/issue_shares'
require 'view/game/corporate_buy_shares'
require 'view/game/map'
require 'view/game/buy_corporation'
require 'view/game/route_selector'
require 'view/game/cash_crisis'
require 'view/game/double_head_trains'
require 'view/game/combined_trains'
require 'view/game/buy_token'
require 'view/game/corporate_buy_companies'
require 'view/game/corporate_sell_companies'

module View
  module Game
    module Round
      class Operating < Snabberb::Component
        needs :game
        needs :selected_company, default: nil, store: true

        def render
          round = @game.round
          @step = round.active_step
          entity = @step.current_entity
          @current_actions = round.actions_for(entity)

          entity = entity.owner if entity.company? && !round.active_entities.one?

          if !entity.company? &&
             @game.purchasable_companies(entity).empty? &&
             !@game.abilities(@selected_company)
            store(:selected_company, nil, skip: true)
          end

          convert_track = @step.respond_to?(:conversion?) && @step.conversion?

          left = []
          right = []
          left << h(SpecialBuy) if @current_actions.include?('special_buy')
          left << h(RouteSelector) if @current_actions.include?('run_routes') && !convert_track
          left << h(TrackConversion) if @current_actions.include?('run_routes') && convert_track
          left << h(Dividend) if @current_actions.include?('dividend')
          left << h(Convert) if @current_actions.include?('convert')
          left << h(SwitchTrains) if @current_actions.include?('switch_trains')
          left << h(ReassignTrains) if @current_actions.include?('reassign_trains')
          left << h(DoubleHeadTrains) if @current_actions.include?('double_head_trains')
          left << h(CombinedTrains) if @current_actions.include?('combined_trains')
          left << h(Choose) if @current_actions.include?('choose')
          left << h(BuyToken, entity: entity) if @current_actions.include?('buy_token')

          if @current_actions.include?('buy_train') || @current_actions.include?('sell_train')
            left << h(IssueShares) if @current_actions.include?('sell_shares') || @current_actions.include?('buy_shares')
            left << h(BuyTrains)
          elsif @current_actions.include?('buy_power')
            left << h(IssueShares) if @current_actions.include?('sell_shares')
            left << h(BuyPower)
          elsif @current_actions.include?('borrow_train')
            left << h(BorrowTrain)
          elsif @step.respond_to?(:cash_crisis?) && @step.cash_crisis?
            left << h(CashCrisis)
            loans_rendered = true if (%w[take_loan payoff_loan] & @current_actions).any?
          elsif @current_actions.include?('buy_shares') || @current_actions.include?('sell_shares') ||
            @current_actions.include?('par')
            if @step.respond_to?(:price_protection) && (price_protection = @step.price_protection)
              left << h(Corporation, corporation: price_protection.corporation)
              left << h(BuySellShares, corporation: price_protection.corporation)
            elsif @game.corporations_can_ipo?
              right << h(CorporateBuySellShares)
            else
              left << h(IssueShares)
            end
          elsif @current_actions.include?('corporate_buy_shares')
            left << h(CorporateBuyShares)
          elsif @current_actions.include?('corporate_sell_shares')
            left << h(CorporateSellShares)
          elsif @current_actions.include?('swap_train')
            left << h(SwapTrain)
          elsif @current_actions.include?('buy_corporation')
            left << h(BuyCorporation)
          end
          left << h(ScrapTrains) if @current_actions.include?('scrap_train')
          left << h(Loans, corporation: entity) if !loans_rendered && (%w[take_loan payoff_loan] & @current_actions).any?
          left << h(ViewMergeOptions, corporation: entity) if @current_actions.include?('view_merge_options')

          if entity.player?
            left << h(Player, player: entity, game: @game)
          elsif entity.operator? && entity.floated?
            left << h(Corporation, corporation: entity)
            if @step.respond_to?(:show_other) && @step.show_other
              Array(@step.show_other).each { |other_corporation| left << h(Corporation, corporation: other_corporation) }
            end
          elsif (company = entity).company?
            left << h(Company, company: company)

            # render combos if blocking for a private company with
            # must_lay_together=true
            left << h(Game::Abilities, user: @user, game: @game, combos_only: true)

            if @game.abilities(company, :assign_corporation)
              props = {
                style: {
                  display: 'inline-block',
                  verticalAlign: 'top',
                },
              }

              @step.assignable_corporations(company).each do |corporation|
                component = View::Game::Corporation.new(@root, corporation: corporation, selected_company: company)
                store(:selected_company, company, skip: true)
                left << h(:div, props, [component.render])
              end
            end
          end

          div_props = {
            style: {
              display: 'flex',
            },
          }

          aquire_company_action = @current_actions.include?('acquire_company')
          corporate_stock_round = @step.respond_to?(:corporate_stock_round?) && @step.corporate_stock_round?
          hide_map = aquire_company_action || corporate_stock_round

          left << h(MapLegend, game: @game) if @game.show_map_legend? && @game.show_map_legend_on_left?
          right << h(Map, game: @game) unless hide_map
          right << h(:div, div_props, [h(BuyCompanies, limit_width: true)]) if @current_actions.include?('buy_company')
          right << h(:div, div_props, [h(AcquireCompanies)]) if aquire_company_action
          right << h(:div, div_props, [h(CorporateSellCompanies)]) if @current_actions.include?('corporate_sell_company')
          right << h(:div, div_props, [h(CorporateBuyCompanies)]) if @current_actions.include?('corporate_buy_company')

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
