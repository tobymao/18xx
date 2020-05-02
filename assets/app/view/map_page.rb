# frozen_string_literal: true

require_tree 'engine'

require 'view/map'

module View
  class MapPage < Snabberb::Component
    needs :route

    ROUTE_FORMAT = %r{/map/(.*)}.freeze

    def render
      game_title = @route.match(ROUTE_FORMAT).captures.first

      game_class = Engine::GAMES_BY_TITLE[game_title]

      return h(:p, "Bad game title: #{game_title}") if game_class.nil?

      begin
        names = %w[p1 p2 p3 p4 p5]
        h(Map, game: game_class.new(names), opacity: 1.0)
      rescue Engine::GameError => e
        puts e
        h(:div, [
            h(:p, "Error rendering map for #{game_title}:"),
            h(:p, "#{e.class.name}: #{e.message}"),
          ])
      end
    end
  end
end
