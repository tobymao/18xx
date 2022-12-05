# frozen_string_literal: true

module Engine
  module Game
    module G1822PNW
      module BuilderCubes
        def max_builder_cubes(tile)
          ((total_terrain_cost(tile).to_f + (can_place_river(tile) ? 75.0 : 0.0)) / 40.0).ceil
        end

        def current_builder_cubes(tile)
          tile.icons.count { |i| i.name.start_with?('block') }
        end

        def can_hold_builder_cubes?(tile)
          current_builder_cubes(tile) < max_builder_cubes(tile)
        end

        def cube_tile
          @cube_tile ||= tile_by_id('BC-0')
        end
      end
    end
  end
end
