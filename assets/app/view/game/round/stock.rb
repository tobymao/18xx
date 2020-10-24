# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/bank'
require 'view/game/buy_sell_shares'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/par'
require 'view/game/players'
require 'view/game/sell_shares'
require 'view/game/stock_market'
require 'view/game/undo_and_pass'
require 'view/game/bid'

module View
  module Game
    module Round
      class Stock < Snabberb::Component
        include Actionable
        needs :selected_corporation, default: nil, store: true
        needs :last_player, default: nil, store: true

        def render
          @step = @game.round.active_step
          @current_actions = @step.current_actions
          @auctioning_corporation = @step.auctioning_corporation if @step.respond_to?(:auctioning_corporation)
          @selected_corporation ||= @auctioning_corporation

          @current_entity = @step.current_entity
          if @last_player != @current_entity && !@auctioning_corporation
            store(:selected_corporation, nil, skip: true)
            store(:last_player, @current_entity, skip: true)
          end

          children = []
          if @step.respond_to?(:must_sell?) && @step.must_sell?(@current_entity)
            children << if @game.num_certs(@current_entity) > @game.cert_limit
                          h('div.margined', 'Must sell stock: above certificate limit')
                        else
                          h('div.margined', 'Must sell stock: above 60% limit in corporation(s)')
                        end
          end

          children.concat(render_corporations)
          children << h(Players, game: @game)
          children << h(BuyCompanyFromOtherPlayer, game: @game) if @step.purchasable_companies(@current_entity).any?
          children << h(StockMarket, game: @game)

          h(:div, children)
        end

        def render_corporations
          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @game.sorted_corporations.reject(&:closed?).map do |corporation|
            next if @auctioning_corporation && @auctioning_corporation != corporation

            children = []
            children.concat(render_subsidiaries)
            children << h(Corporation, corporation: corporation)
            children << render_input if @selected_corporation == corporation
            children << h(Choose) if @current_actions.include?('choose')
            h(:div, props, children)
          end.compact
        end

        def render_input
          inputs = [
            @selected_corporation.ipoed ? h(BuySellShares, corporation: @selected_corporation) : render_pre_ipo,
            render_loan,
            render_buy_tokens,
          ]
          if @step.actions(@selected_corporation).include?('buy_shares')
            inputs << h(IssueShares, entity: @selected_corporation)
          end
          h('div.margined_bottom', { style: { width: '20rem' } }, inputs.compact)
        end

        def render_pre_ipo
          return h(Par, corporation: @selected_corporation) if @current_actions.include?('par')
          return h(Bid, entity: @current_entity, corporation: @selected_corporation) if @current_actions.include?('bid')

          nil
        end

        def render_subsidiaries
          return [] unless @current_actions.include?('assign')

          @step.available_subsidiaries.map do |company|
            h(Company, company: company)
          end
        end

        def render_loan
          return unless @step.actions(@selected_corporation).include?('take_loan')

          take_loan = lambda do
            process_action(Engine::Action::TakeLoan.new(
              @selected_corporation,
              loan: @game.loans[0],
            ))
          end

          h(:button, { on: { click: take_loan } }, 'Take Loan')
        end

        def render_buy_tokens
          return unless @step.actions(@selected_corporation).include?('buy_tokens')

          buy_tokens = lambda do
            process_action(Engine::Action::BuyTokens.new(
              @selected_corporation
            ))
          end

          h(:button, { on: { click: buy_tokens } }, 'Buy Tokens')
        end
      end
    end
  end
end
