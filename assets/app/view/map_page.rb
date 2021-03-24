# frozen_string_literal: true

require 'view/game/map'
require_relative '../game_class_loader'

module View
  class MapPage < Snabberb::Component
    include GameClassLoader

    needs :route

    ROUTE_FORMAT = %r{/map/([^/?]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1]
      game = load_game_class(game_title)
      unless game
        return h(:div, [
                   h(:p, "Loading game: #{game_title}"),
                   h(:p,
                     "If you're still reading this, the game is loading slowly or might have entered a bad game title"),
                 ])
      end

      players = Array.new(game::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }

      h(:div, [
          h(:h2, game.full_title),
          h(Game::Map, game: game.new(players), opacity: 1.0),
        ])
    end
  end
end
