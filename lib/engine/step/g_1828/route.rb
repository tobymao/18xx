# frozen_string_literal: true

require_relative '../route'

module Engine
  module Step
    module G1828
      class Route < Route
        def process_run_routes(action)
          if route_includes_coalfields?(action.routes) && !@game.coal_marker?(action.entity)
            @game.game_error('Cannot run to Virginia Coalfields without a Coal Marker')
          end

          if action.entity.id == 'C&P' && !route_uses_tile_lay(action.routes)
            @game.game_error("#{action.entity.name} must use laid tile in route")
          end

          super
        end

        def route_includes_coalfields?(routes)
          routes.flat_map(&:connection_hexes).flatten.include?(Engine::Game::G1828::VA_COALFIELDS_HEX)
        end

        def route_uses_tile_lay(routes)
          tile_used = false
          stops = routes.first.visited_stops
          tile = @round.last_tile_lay

          if tile.nodes.any?
            tile_used = (stops & tile.nodes).any?
          else
            tile.paths.each do |path|
              path.walk { |p| tile_used ||= (stops & p.nodes).any? }
            end
          end

          tile_used
        end
      end
    end
  end
end
