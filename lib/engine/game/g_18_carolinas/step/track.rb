# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Track < Engine::Step::Track
          LAY_ACTIONS = %w[lay_tile pass].freeze
          ALL_ACTIONS = %w[lay_tile choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.corporation? && entity.receivership?
            return [] if entity.company? || !can_lay_tile?(entity) && !conversion_available?

            conversion_available? ? ALL_ACTIONS : LAY_ACTIONS
          end

          def conversion_available?
            @game.phase.available?('5') && @round.num_laid_track.zero?
          end

          def round_state
            super.merge(
              {
                convert_mode: nil,
              }
            )
          end

          def setup
            super
            @round.convert_mode = nil
          end

          def update_tile_lists(tile, old_tile)
            @game.update_tile_lists!(tile, old_tile)
          end

          def choice_name
            'Switch to'
          end

          def choices
            {
              conversion: 'Track Conversion Mode',
            }
          end

          def process_choose(_action)
            @round.convert_mode = true
            @log << 'Switching to Track Conversion Mode'
            pass!
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
