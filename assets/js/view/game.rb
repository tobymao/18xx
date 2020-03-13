# frozen_string_literal: true

require 'view/auction_round'
require 'view/entity_order'
require 'view/map'
require 'view/operating_round'
require 'view/player'
require 'view/stock_round'
require 'view/stock_market'

require 'engine/round/auction'
require 'engine/round/operating'
require 'engine/round/stock'

module View
  class Game < Snabberb::Component
    needs :game, store: true

    def render_round
      name = @round.class.name.split(':').last
      description = @round.operating? ? "#{@game.turn}.#{@round.round_num}" : @game.turn
      description = "#{description} - #{@round.description}"
      h(:div, "#{name} Round #{description}")
    end

    def render_action
      case @round
      when Engine::Round::Auction
        h(AuctionRound)
      when Engine::Round::Stock
        h(StockRound)
      when Engine::Round::Operating
        h(OperatingRound)
      end
    end

    def render_log
      reverse_scroll = lambda do |event|
        %x{
          var e = #{event}
          e.preventDefault()
          e.currentTarget.scrollTop -= e.deltaY
        }
      end

      props = {
        on: { wheel: reverse_scroll },
        style: {
          transform: 'scaleY(-1)',
          overflow: 'auto',
          height: '200px',
          margin: '5px 0',
          'background-color': 'lightgray',
        },
      }

      lines = @game.log.reverse.map do |line|
        h(:div, { style: { transform: 'scaleY(-1)' } }, line)
      end

      h(:div, props, lines)
    end

    def render
      @round = @game.round

      players = @game.players.map { |player| h(Player, player: player) }

      h(:div, { attrs: { id: 'game' } }, [
        render_round,
        render_log,
        h(EntityOrder, round: @round),
        render_action,
        *players,
        h(StockMarket, stock_market: @game.stock_market),
        h(Map),
      ])
    end
  end
end
