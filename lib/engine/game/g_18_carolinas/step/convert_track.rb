# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Carolinas
      module Step
        class ConvertTrack < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.corporation? && entity.receivership?
            return [] unless @round.convert_mode

            %w[run_routes pass]
          end

          def description
            'Convert Track'
          end

          def skip!
            pass!
          end

          def instructions
            'Click revenue centers, again to cycle paths. Must be from city/offboard to city/offboard'
          end

          def total_str(active_routes)
            raise GameError, 'No routes' if active_routes.empty?

            _rev = @game.routes_revenue(active_routes) # force check
            'Convert Segment'
          end

          def revenue_fail
            'Invalid Segment'
          end

          def process_run_routes(action)
            hexes = action.routes[0].connection_hexes.flatten.uniq.map { |h| @game.hex_by_id(h) }
            hexes_to_flip = hexes.select { |h| h.tile.paths.any? { |p| p.track != :broad } }
            raise GameError, 'No tiles with Southern Track submitted' if hexes_to_flip.empty?

            hexes_to_flip.each { |h| @game.flip_tile!(h) }
            pass!
          end

          def conversion?
            true
          end

          def available_hex(entity, hex)
            @game.graph_for_entity(entity).reachable_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
