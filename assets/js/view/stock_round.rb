# frozen_string_literal: true

require 'view/corporation'
require 'view/round'

require 'engine/action/buy_share'
require 'engine/action/float'
require 'engine/action/sell_share'

module View
  class StockRound < Round
    needs :selected_corporation, default: nil, store: true

    def render
      @round = @game.round
      @current_entity = @round.current_entity

      h(:div, [
        *render_corporations,
        render_input,
        render_shares,
      ])
    end

    def render_corporations
      @game.share_pool.corporations.map do |corporation|
        h(Corporation, corporation: corporation)
      end
    end

    def render_shares
      div = @current_entity.shares_by_corporation.map do |corporation, shares|
        h(:div, "#{corporation.name} - Shares #{shares.size}")
      end
      h(:div, div)
    end

    def render_input
      return '' unless @selected_corporation

      if @selected_corporation.ipoed
        buy = lambda do
          process_action(Engine::Action::BuyShare.new(@current_entity, @selected_corporation.shares.first))
        end
        input = [
          h(:button, { on: { click: buy } }, 'Buy Share'),
        ]
      else
        style = {
          cursor: 'pointer',
          border: 'solid 1px rgba(0,0,0,0.2)',
          display: 'inline-block',
        }

        input = @game.stock_market.par_prices.map do |share_price|
          float = lambda do
            process_action(Engine::Action::Float.new(@current_entity, @selected_corporation, share_price))
          end

          h(:div, { style: style, on: { click: float } }, share_price.price)
        end
      end

      h(:div, 'Choose a par price', input)
    end
  end
end
