# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18NewEngland
      module Step
        class Track < Engine::Step::Track
          def upgradeable_tiles(entity, ui_hex)
            tiles = super
            # don't allow 611 to be laid if 63 is a possibility
            #
            tiles.reject! { |t| t.name == '611' } if tiles.any? { |t| t.name == '63' }
            tiles
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.force_upgrade?(hex.tile, tile)

            # make sure new tile connects to same exits as old tile
            old_exits = hex.tile.exits
            new_exits = tile.exits

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_exits.all? { |ex| new_exits.include?(ex) }
          end
        end
      end
    end
  end
end
