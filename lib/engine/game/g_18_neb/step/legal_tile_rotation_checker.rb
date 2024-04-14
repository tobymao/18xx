# frozen_string_literal: true

module Engine
  module Game
    module G18Neb
      module Step
        module LegalTileRotationChecker
          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            if @game.town_to_city_upgrade?(old_tile, tile) || @game.omaha_green_upgrade?(old_tile, tile)
              return (old_tile.exits & tile.exits) == old_tile.exits && tile.exits.all? { |edge| hex.neighbors[edge] }
            end

            super
          end
        end
      end
    end
  end
end
