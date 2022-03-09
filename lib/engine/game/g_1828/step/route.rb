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

            if @game.route_includes_coalfields?(action.routes) && !@game.coal_marker?(action.entity)
              raise GameError, 'Cannot run to Virginia Coalfields without a Coal Marker'
            end

            # C&P route must include the tile it laid this turn
            return unless action.entity.id == 'C&P' && !route_uses_tile_lay(action.routes)

            raise GameError, "#{action.entity.name} must use laid tile in route"
          end

          def route_uses_tile_lay(routes)
            stops = routes.first.visited_stops
            tile = @round.laid_hexes.first&.tile

            return !(stops & tile.nodes).empty? unless tile.nodes.empty?

            tile.paths.each do |path|
              path.walk { |p| return true unless (stops & p.nodes).empty? }
            end

            false
          end

          def available_hex(entity, hex)
            return @game.coal_marker?(entity) if hex.id == Engine::Game::G1828::Game::VA_COALFIELDS_HEX

            super
          end
        end
      end
    end
  end
end
