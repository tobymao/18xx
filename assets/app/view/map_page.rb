# frozen_string_literal: true

require 'view/game/map'

module View
  class MapPage < Snabberb::Component
    needs :route

    ROUTE_FORMAT = %r{/map/([^/?]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1]
      game_class = Engine::GAMES_BY_TITLE[game_title]

      return h(:p, "Bad game title: #{game_title}") unless game_class

      names = %w[p1 p2 p3 p4]
      h(Game::Map, game: game_class.new(names))
    end
  end
end
