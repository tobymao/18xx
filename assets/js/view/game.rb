# frozen_string_literal: true

require 'component'
require 'view/auction_round'
require 'view/entity_order'
require 'view/player'
require 'view/stock_round'

require 'engine/round/auction'
require 'engine/round/stock'

module View
  class Game < Component
    def initialize(game:)
      @game = game
      @round = @game.round
    end

    def render_round
      h(:div, "Round: #{@round.class.name}")
    end

    def render_action
      case @round
      when Engine::Round::Auction
        c(AuctionRound, round: @round, handler: @game)
      when Engine::Round::Stock
        c(StockRound, round: @round, handler: @game)
      end
    end

    def render
      players = @game.players.map { |player| c(Player, player: player) }

      h(:div, [
        h(:div, 'Game test 1889'),
        c(EntityOrder, round: @round),
        render_round,
        render_action,
        *players,
      ])
    end
  end
end
