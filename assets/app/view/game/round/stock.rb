# frozen_string_literal: true

require 'view/game/actionable'
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
          @round = @game.round

          @current_entity = @round.current_entity
          if @last_player != @current_entity
            store(:selected_corporation, nil, skip: true)
            store(:last_player, @current_entity, skip: true)
          end

          children = [
            h(UndoAndPass, pass: !@round.must_sell?),
            *render_corporations,
          ]
          children << h(Players, game: @game)
          children << h(StockMarket, game: @game)

          h(:div, children)
        end

        def render_corporations
          props = {
            style: {
              display: 'inline-block',
              'vertical-align': 'top',
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
          h(:div, { style: { 'margin-top': '0.5rem', width: '320px' } }, [input].compact)
        end

        def buy_share(entity, share)
          process_action(Engine::Action::BuyShares.new(entity, shares: share))
        end

        def render_ipoed
          ipo_share = @selected_corporation.shares.first
          pool_share = @round.share_pool.shares_by_corporation[@selected_corporation]&.first

          buy_ipo = lambda do
            buy_share(@current_entity, ipo_share)
          end

          buy_pool = lambda do
            buy_share(@current_entity, pool_share)
          end

          children = []
          unless @round.must_sell?
            if @round.can_buy?(ipo_share)
              children << h('button.button.margined_half', { on: { click: buy_ipo } }, 'Buy IPO Share')
            end

            if @round.can_buy?(pool_share)
              children << h('button.button.margined_half', { on: { click: buy_pool } }, 'Buy Market Share')
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

                if ability.from.include?(:ipo) && @round.can_gain?(ipo_share, company.owner)
                  children << h('button.button', { on: { click: -> { buy_share(company, ipo_share) } } },
                                "#{prefix} an IPO share")
                end

                if ability.from.include?(:market) && @round.can_gain?(pool_share, company.owner)
                  children << h('button.button', { on: { click: -> { buy_share(company, pool_share) } } },
                                "#{prefix} a Market share")
                end
              end
            end

          end
          children << h(SellShares, player: @current_entity)

          h(:div, children)
        end

        def render_pre_ipo
          return if @round.must_sell?

          h(Par, corporation: @selected_corporation)
        end
      end
    end
  end
end
