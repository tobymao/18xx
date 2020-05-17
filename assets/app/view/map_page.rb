# frozen_string_literal: true

require_tree 'engine'

require 'view/map'

module View
  class MapPage < Snabberb::Component
    needs :route

    ROUTE_FORMAT = %r{/map/([^/]*)/?}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT)[1]
      game_class = Engine::GAMES_BY_TITLE[game_title]

      return h(:p, "Bad game title: #{game_title}") unless game_class

      begin
        names = %w[p1 p2 p3 p4 p5]
        h(Map, game: game_class.new(names))
      rescue StandardError => e
        puts e
        h(:div, [
            h(:p, "Error rendering map for #{game_title}:"),
            h(:p, "#{e.class.name}: #{e.message}"),
          ])
      end
    end
  end
end
