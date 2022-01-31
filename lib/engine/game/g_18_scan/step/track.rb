# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Scan
      module Step
        class Track < Engine::Step::Track
          def old_exits_are_preserved(old_paths, new_paths)
            old_exits = old_paths.flat_map(&:exits).uniq
            new_exits = new_paths.flat_map(&:exits).uniq

            (old_exits - new_exits).empty?
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.copenhagen_dit_upgrade(hex.tile, tile)

            # simplified version of super
            old_paths = hex.tile.paths

            new_paths = tile.paths
            new_exits = tile.exits

            # substituted path check: allow dit/city -> city/city upgrade
            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_exits_are_preserved(old_paths, new_paths)
          end
        end
      end
    end
  end
end
