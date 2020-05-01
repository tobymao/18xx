# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/players'
require 'view/sell_shares'
require 'view/stock_market'
require 'view/undo_and_pass'

require 'engine/action/buy_share'
require 'engine/action/par'
require 'engine/share'

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
        }
      }

      @round.share_pool.corporations.map do |corporation|
        children = [h(Corporation, corporation: corporation)]
        children << render_input if @selected_corporation == corporation
        h(:div, props, children)
      end
    end

    def render_input
      input = @selected_corporation.ipoed ? render_ipoed : render_pre_ipo
      h(:div, { style: { 'margin-top': '0.5rem' } }, [input].compact)
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
        children << h(:button, { on: { click: buy_ipo } }, 'Buy IPO Share') if @round.can_buy?(ipo_share)
        children << h(:button, { on: { click: buy_pool } }, 'Buy Market Share') if @round.can_buy?(pool_share)
      end
      children << h(SellShares, player: @current_entity)

      h(:div, children)
    end

    def render_pre_ipo
      return if @round.must_sell?

      style = {
        cursor: 'pointer',
        border: 'solid 1px gainsboro',
        display: 'inline-block',
        padding: '0.5rem',
        margin: '0.5rem 0.5rem 0.5rem 0',
      }

      par_values = @round.stock_market.par_prices.map do |share_price|
        par = lambda do
          process_action(Engine::Action::Par.new(@current_entity, @selected_corporation, share_price))
        end

        h(:div, { style: style, on: { click: par } }, @game.format_currency(share_price.price))
      end

      h(:div, [
        h(:div, 'Par Price:'),
        *par_values,
      ])
    end
  end
end
