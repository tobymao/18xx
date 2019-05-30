# frozen_string_literal: true

require 'component'
require 'view/corporation'

require 'engine/action/buy_share'
require 'engine/action/float'
require 'engine/action/sell_share'

module View
  class StockRound < Component
    def initialize(round:, handler:)
      @round = round
      @handler = handler
      @current_entity = @round.current_entity
    end

    def render_corporations
      @round.share_pool.corporations.map do |corporation|
        c(Corporation, corporation: corporation)
      end
    end

    def render_shares
      div = @current_entity.shares_by_corporation.map do |corporation, shares|
        h(:div, "#{corporation.name} - Shares #{shares.size}")
      end
      h(:div, div)
    end

    def render_input
      selected_corporation = state(:selected_corporation, :scope_corporation)

      return '' unless selected_corporation

      if selected_corporation.ipoed
        buy = lambda do
          @handler.process_action(Engine::Action::BuyShare.new(@current_entity, selected_corporation.shares.first))
          update
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

        input = @round.stock_market.par_prices.map do |share_price|
          float = lambda do
            @handler.process_action(Engine::Action::Float.new(@current_entity, selected_corporation, share_price))
            update
          end

          h(:div, { style: style, on: { click: float } }, share_price.price)
        end
      end

      h(:div, 'Choose a par price', input)
    end

    def render
      h(:div, [
        *render_corporations,
        render_input,
        render_shares,
      ])
    end
  end
end
