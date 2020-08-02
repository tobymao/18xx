# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/bank'
require 'view/game/corporation'
require 'view/game/par'
require 'view/game/players'
require 'view/game/sell_shares'
require 'view/game/stock_market'
require 'view/game/undo_and_pass'

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

          @current_entity = @step.current_entity
          if @last_player != @current_entity
            store(:selected_corporation, nil, skip: true)
            store(:last_player, @current_entity, skip: true)
          end

          children = []
          if @step.respond_to?(:must_sell?) && @step.must_sell?(@current_entity)
            children << if @current_entity.num_certs > @game.cert_limit
                          h('div.margined', 'Must sell stock: above certificate limit')
                        else
                          h('div.margined', 'Must sell stock: above 60% limit in corporation(s)')
                        end
          end
          children += render_corporations
          children << h(Players, game: @game)
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

          @game.corporations.map do |corporation|
            children = [h(Corporation, corporation: corporation)]
            children << render_input if @selected_corporation == corporation
            h(:div, props, children)
          end
        end

        def render_input
          input = @selected_corporation.ipoed ? render_ipoed : render_pre_ipo
          h('div.margined_bottom', { style: { width: '20rem' } }, [input].compact)
        end

        def buy_share(entity, share)
          process_action(Engine::Action::BuyShares.new(entity, shares: share))
        end

        def render_ipoed
          ipo_share = @selected_corporation.shares.first
          pool_share = @game.share_pool.shares_by_corporation[@selected_corporation]&.first

          buy_ipo = lambda do
            buy_share(@current_entity, ipo_share)
          end

          buy_pool = lambda do
            buy_share(@current_entity, pool_share)
          end

          children = []
          if @current_actions.include?('buy_shares')
            if @step.can_buy?(@current_entity, ipo_share)
              children << h(
                :button,
                { on: { click: buy_ipo } },
                "Buy #{@game.class::IPO_NAME} Share"
              )
            end

            if @step.can_buy?(@current_entity, pool_share)
              children << h(:button, { on: { click: buy_pool } }, 'Buy Market Share')
            end

            # Allow privates to be exchanged for shares
            @game.companies.each do |company|
              company.abilities(:exchange) do |ability|
                next unless ability.corporation == @selected_corporation.name

                prefix =
                  if company.owner == @current_entity
                    "Exchange #{company.sym} for "
                  else
                    "#{company.owner&.name} exchanges #{company.sym} for"
                  end

                if ability.from.include?(:ipo) && @step.can_gain?(company.owner, ipo_share)
                  children << h(:button, { on: { click: -> { buy_share(company, ipo_share) } } },
                                "#{prefix} an #{@game.class::IPO_NAME} share")
                end

                if ability.from.include?(:market) && @step.can_gain?(company.owner, pool_share)
                  children << h(:button, { on: { click: -> { buy_share(company, pool_share) } } },
                                "#{prefix} a Market share")
                end
              end
            end

          end
          children << h(SellShares, player: @current_entity)

          h(:div, children)
        end

        def render_pre_ipo
          return unless @current_actions.include?('par')

          h(Par, corporation: @selected_corporation)
        end
      end
    end
  end
end
