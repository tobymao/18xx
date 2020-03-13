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
      props = {
        props: { id: 'log' },
        style: {
          display: 'flex',
          'flex-direction' => 'column-reverse',
          'overflow-y' => 'scroll',
          'background-color': 'lightgray',
          height: '200px',
          margin: '5px 0',
        },
      }

      h(:div, props, @game.log.reverse.map { |line| h(:div, line) })
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
