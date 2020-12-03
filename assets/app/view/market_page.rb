# frozen_string_literal: true

require 'view/game/stock_market'

module View
  class MarketPage < Snabberb::Component
    needs :route

    ROUTE_FORMAT = %r{/market/([^/?]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1].gsub('%20', ' ')
      game = Engine::GAMES_BY_TITLE[game_title]

      return h(:p, "Bad game title: #{game_title}") unless game

      players = Engine.player_range(game).max.times.map { |n| "Player #{n + 1}" }
      h(Game::StockMarket, game: game.new(players), explain_colors: true)
    end
  end
end
