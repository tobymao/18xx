# frozen_string_literal: true

require_relative '../base'
require_relative '../track'

module Engine
  module Step
    module G1856
      class Track < Track

        def legal_tile_rotation?(entity, hex, tile)
          old_paths = hex.tile.paths
          old_ctedges = hex.tile.city_town_edges

          new_paths = tile.paths
          new_exits = tile.exits
          new_ctedges = tile.city_town_edges
          extra_cities = [0, new_ctedges.size - old_ctedges.size].max

          new_exits.all? { |edge| hex.neighbors[edge] } &&
            (new_exits & available_hex(entity, hex)).any? &&
            old_paths_are_preserved(old_paths, new_paths) &&
            # Count how many cities on the new tile that aren't included by any of the old tile.
            # Make sure this isn't more than the number of new cities added.
            # 1836jr30 D6 -> 54 adds more cities
            extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } }
        end

        def old_paths_are_preserved(old_paths, new_paths)
          # if gray phase, towns can be upgraded or downgraded
          # and there are no tiles mixed with towns and other things
          # so if it is gray phase, and the tile has towns, then we only need
          # to test that exits are preserved
          old_exits = {}
          new_exits = {}
          old_paths.each { |path| path.exits.each { |exit| old_exits[exit] = true } }
          new_paths.each { |path| path.exits.each { |exit| new_exits[exit] = true } }
          return old_exits.all? { |exit, exits| !exits || new_exits[exit] } if
            @game.gray_phase? && old_paths.any? { |old_path| path_has_town(old_path) }

          old_paths.all? { |path| new_paths.any? { |p| path <= p } }
        end

        def path_has_town(path)
          path.ends.any?(&:town?)
        end
      end
    end
  end
end
