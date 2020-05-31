# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/par'
require 'view/players'
require 'view/sell_shares'
require 'view/stock_market'
require 'view/undo_and_pass'

module View
  class StockRound < Snabberb::Component
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
      children << h(View::Players, game: @game)
      children << h(View::StockMarket, game: @game)

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

    def render_ipoed
      ipo_share = @selected_corporation.shares.first
      pool_share = @round.share_pool.shares_by_corporation[@selected_corporation]&.first

      buy_ipo = lambda do
        process_action(Engine::Action::BuyShare.new(@current_entity, ipo_share))
      end

      buy_pool = lambda do
        process_action(Engine::Action::BuyShare.new(@current_entity, pool_share))
      end

      children = []
      unless @round.must_sell?
        children << h('button.margined_half', { on: { click: buy_ipo } }, 'Buy IPO Share') if @round.can_buy?(ipo_share)

        if @round.can_buy?(pool_share)
          children << h('button.margined_half', { on: { click: buy_pool } }, 'Buy Market Share')
        end

        # Allow privates to be exchanged for shares
        exchangable = @game.companies.select do |n|
          n.abilities(:exchange)&.fetch(:corporation)&.to_s == @selected_corporation.name &&
          @round.can_gain?(ipo_share, n.owner)
        end
        exchangable.each do |company|
          exchange = lambda do
            process_action(Engine::Action::BuyShare.new(company, ipo_share))
          end
          children << if company.owner == @current_entity
                        h(:button, { on: { click: exchange } },
                          "Exchange #{company.name} for Share")
                      else
                        # This can be done outside of a players turn, but make it clear who owns it
                        h(:button, { on: { click: exchange } },
                          "#{company.owner.name} exchanges #{company.name} for Share")
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
