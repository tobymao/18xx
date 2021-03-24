# frozen_string_literal: true

require 'view/game/stock_market'

module View
  class MarketPage < Snabberb::Component
    include GameClassLoader

    needs :route

    ROUTE_FORMAT = %r{/market/([^/?]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1]
      game = load_game_class(game_title)
      unless game
        return h(:div, [
                   h(:p, "Loading game: #{game_title}"),
                   h(:p, "If you're still reading this, the game data is loading"\
                         ' slowly or you emight have entered an invalid game title'),
                 ])
      end

      players = Array.new(game::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }
      h(Game::StockMarket, game: game.new(players), explain_colors: true)
    end
  end
end
