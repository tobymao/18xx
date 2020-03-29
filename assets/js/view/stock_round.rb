# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/pass_button'
require 'view/sell_shares'

require 'engine/action/buy_share'
require 'engine/action/par'
require 'engine/share'

module View
  class StockRound < Snabberb::Component
    include Actionable

    needs :selected_corporation, default: nil, store: true

    def render
      @round = @game.round
      @current_entity = @round.current_entity

      children = render_corporations
      children << render_input if @selected_corporation
      children << h(PassButton)

      h(:div, children)
    end

    def render_corporations
      @game.share_pool.corporations.map do |corporation|
        h(Corporation, corporation: corporation)
      end
    end

    def render_input
      @selected_corporation.ipoed ? render_ipoed : render_pre_ipo
    end

    def render_ipoed
      selected_share = @selected_corporation.shares.first

      buy = lambda do
        process_action(Engine::Action::BuyShare.new(@current_entity, selected_share))
      end

      children = []
      children << h(:button, { on: { click: buy } }, 'Buy Share') if @round.can_buy?(selected_share)
      children << h(SellShares, player: @current_entity)

      h(:div, children)
    end

    def render_pre_ipo
      style = {
        cursor: 'pointer',
        border: 'solid 1px rgba(0,0,0,0.2)',
        display: 'inline-block',
      }

      par_values = @game.stock_market.par_prices.map do |share_price|
        par = lambda do
          process_action(Engine::Action::Par.new(@current_entity, @selected_corporation, share_price))
        end

        h(:div, { style: style, on: { click: par } }, share_price.price)
      end

      h(:div, ['Choose a par price', *par_values])
    end
  end
end
