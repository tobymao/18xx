# frozen_string_literal: true

require 'view/auction_round'
require 'view/corporation'
require 'view/entity_order'
require 'view/log'
require 'view/map'
require 'view/operating_round'
require 'view/player'
require 'view/stock_round'
require 'view/stock_market'
require 'view/undo_button'

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
        h(AuctionRound, round: @round)
      when Engine::Round::Stock
        h(StockRound, round: @round)
      when Engine::Round::Operating
        h(OperatingRound, round: @round)
      end
    end

    def render
      @round = @game.round

      h(:div, { attrs: { id: 'game' } }, [
        render_round,
        h(Log),
        h(EntityOrder, round: @round),
        render_action,
        h(UndoButton),
        h(:div, 'Players'),
        *@game.players.map { |p| h(Player, player: p) },
        h(:div, 'Corporations'),
        *@game.corporations.map { |c| h(Corporation, corporation: c) },
        @round.operating? ? h(Map) : h(StockMarket, stock_market: @game.stock_market),
      ])
    end
  end
end
