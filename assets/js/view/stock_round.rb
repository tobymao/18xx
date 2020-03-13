# frozen_string_literal: true

require 'view/actionable'
require 'view/corporation'
require 'view/pass_button'

require 'engine/action/buy_share'
require 'engine/action/par'
require 'engine/action/sell_share'

module View
  class StockRound < Snabberb::Component
    include Actionable

    needs :selected_corporation, default: nil, store: true

    def render
      @round = @game.round
      @current_entity = @round.current_entity

      h(:div, [
        *render_corporations,
        render_input,
        h(PassButton),
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
end
