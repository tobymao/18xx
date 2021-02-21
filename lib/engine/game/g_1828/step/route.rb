# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1828
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super
            return if @game.loading

            if route_includes_coalfields?(action.routes) && !@game.coal_marker?(action.entity)
              raise GameError, 'Cannot run to Virginia Coalfields without a Coal Marker'
            end

            # C&P route must include the tile it laid this turn
            return unless action.entity.id == 'C&P' && !route_uses_tile_lay(action.routes)

            raise GameError, "#{action.entity.name} must use laid tile in route"
          end

          def route_includes_coalfields?(routes)
            routes.flat_map(&:connection_hexes).flatten.include?(Engine::Game::G1828::Game::VA_COALFIELDS_HEX)
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
end
