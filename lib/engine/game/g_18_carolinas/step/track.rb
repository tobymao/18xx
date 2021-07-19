# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Track < Engine::Step::Track
          LAY_ACTIONS = %w[lay_tile pass].freeze
          ALL_ACTIONS = %w[lay_tile run_routes pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.corporation? && entity.receivership?
            return [] if entity.company? || !can_lay_tile?(entity) && !@game.phase.available?('5')

            @game.phase.available?('5') ? ALL_ACTIONS : LAY_ACTIONS
          end

          def setup
            @mode = 'lay_tile'
            super
          end

          def update_tile_lists(tile, old_tile)
            @game.update_tile_lists!(tile, old_tile)
          end

          def mode_enabled?
            return false if @round.num_laid_track.positive?

            @game.phase.available?('5')
          end

          def mode_text
            @mode == 'lay_tile' ? 'Track Conversion Mode' : 'Tile Lay/Upgrade Mode'
          end

          def change_mode
            return 'lay_tile' unless @game.phase.available?('5')
            return 'lay_tile' if @round.num_laid_track.positive?

            @mode = @mode == 'lay_tile' ? 'run_routes' : 'lay_tile'
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
            @mode == 'run_routes'
          end

          def available_hex(entity, hex)
            return super if @mode == 'lay_tile'

            @game.graph_for_entity(entity).reachable_hexes(entity)[hex]
          end

          def legal_tile_rotation?(entity, hex, tile)
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            old_paths = hex.tile.paths
            old_ctedges = hex.tile.city_town_edges

            new_paths = tile.paths
            new_exits = tile.exits
            new_ctedges = tile.city_town_edges
            extra_cities = [0, new_ctedges.size - old_ctedges.size].max
            multi_city_upgrade = new_ctedges.size > 1 && old_ctedges.size > 1

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_paths.all? { |path| new_paths.any? { |p| @game.path_subset?(path, p) } } &&
              # Count how many cities on the new tile that aren't included by any of the old tile.
              # Make sure this isn't more than the number of new cities added.
              # 1836jr30 D6 -> 54 adds more cities
              extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } } &&
              # 1867: Does every old city correspond to exactly one new city?
              (!multi_city_upgrade || old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
          end
        end
      end
    end
  end
end
