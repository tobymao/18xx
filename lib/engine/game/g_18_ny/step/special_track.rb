# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G18NY
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include Engine::Step::AutomaticLoan

          def process_lay_tile(action)
            old_tile = action.hex.tile
            super
            @game.tile_lay(action.hex, old_tile, action.tile)
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            entity = Array(entity_or_entities).first

            legal = super
            legal &= upgrade_includes_water_terrain_cost?(hex, hex.tile, tile) if entity.id == 'AIW'
            legal
          end

          def upgrade_includes_water_terrain_cost?(hex, old_tile, tile)
            new_exits = tile.exits - old_tile.exits
            old_tile.terrain.include?(:water) || old_tile.borders.any? do |border|
              new_exits.include?(border.edge) &&
                (border.type == :water) &&
                hex.neighbors[border.edge].tile.exits.include?(hex.invert(border.edge))
            end
          end
        end
      end
    end
  end
end
