# frozen_string_literal: true

require 'view/auction_round'
require 'view/entity_order'
require 'view/map'
require 'view/player'
require 'view/stock_round'

require 'engine/round/auction'
require 'engine/round/stock'

module View
  class Game < Snabberb::Component
    needs :game

    def render_round
      h(:div, "Round: #{@round.class.name}")
    end

    def render_action
      case @round
      when Engine::Round::Auction
        h(AuctionRound, game: @game)
      when Engine::Round::Stock
        h(StockRound, game: @game)
      end
    end

    def render
      @round = @game.round

      players = @game.players.map { |player| h(Player, player: player) }

      h(:div, { attrs: { id: 'game' } }, [
        h(:div, 'Game test 1889'),
        h(EntityOrder, round: @round),
        render_round,
        render_action,
        h(Map, game: @game),
        *players,
      ])
    end
  end
end
