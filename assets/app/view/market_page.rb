# frozen_string_literal: true

require 'view/game/stock_market'

module View
  class MarketPage < Snabberb::Component
    include GameClassLoader

    needs :route

    ROUTE_FORMAT = %r{/market/([^/?]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1].gsub('%20', ' ')
      game = load_game_class(game_title)
      unless game
        return h(:div, [
                   h(:p, "Loading game: #{game_title}"),
                   h(:p, "If you're still reading this, the game data is loading"\
                         ' slowly or you emight have entered an invalid game title'),
                 ])
      end

      players = Engine.player_range(game).max.times.map { |n| "Player #{n + 1}" }
      h(Game::StockMarket, game: game.new(players), explain_colors: true)
    end
  end
end
