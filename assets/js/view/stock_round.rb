# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'

require 'engine/action/buy_share'
require 'engine/action/float'
require 'engine/action/pass'
require 'engine/action/sell_share'

module View
  class StockRound < Snabberb::Component
    include Actionable

    needs :selected_corporation, default: nil, store: true

    def render
      @round = @game.round
      @current_entity = @round.current_entity

      pass = lambda do
        process_action(Engine::Action::Pass.new(@current_entity))
      end

      h(:div, [
        *render_corporations,
        render_input,
        h(:button, { on: { click: pass } }, 'Pass')
      ])
    end

    def render_corporations
      @game.share_pool.corporations.map do |corporation|
        h(Corporation, corporation: corporation)
      end
    end

    def render_input
      return '' unless @selected_corporation

      if @selected_corporation.ipoed
        buy = lambda do
          process_action(Engine::Action::BuyShare.new(@current_entity, @selected_corporation.shares.first))
        end

        h(:div, [h(:button, { on: { click: buy } }, 'Buy Share')])
      else
        style = {
          cursor: 'pointer',
          border: 'solid 1px rgba(0,0,0,0.2)',
          display: 'inline-block',
        }

        float_values = @game.stock_market.par_prices.map do |share_price|
          float = lambda do
            process_action(Engine::Action::Float.new(@current_entity, @selected_corporation, share_price))
          end

          h(:div, { style: style, on: { click: float } }, share_price.price)
        end

        h(:div, ['Choose a par price', *float_values])
      end
    end
  end
end
