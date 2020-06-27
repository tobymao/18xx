# frozen_string_literal: true

require_tree 'engine'
require 'view/game/map'

module View
  class MapPage < Snabberb::Component
    needs :route

    ROUTE_FORMAT = %r{/map/([^/?]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1]
      game = Engine::GAMES_BY_TITLE[game_title]

      return h(:p, "Bad game title: #{game_title}") unless game

      h(Game::Map, game: game.new(:max))
    end
  end
end
