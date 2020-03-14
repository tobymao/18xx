# frozen_string_literal: true

require 'view/auction_round'
require 'view/entity_order'
require 'view/log'
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

    def render
      @round = @game.round

      players = @game.players.map { |player| h(Player, player: player) }

      h(:div, { attrs: { id: 'game' } }, [
        render_round,
        h(Log),
        h(EntityOrder, round: @round),
        render_action,
        *players,
        @round.operating? ? h(Map) : h(StockMarket, stock_market: @game.stock_market),
      ])
    end
  end
end
