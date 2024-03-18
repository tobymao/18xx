# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Track < Engine::Step::Track
          MINOR_TILE_COLORS = %w[yellow green].freeze

          def potential_tiles(entity, hex)
            colors = @game.phase.tiles
            colors &= MINOR_TILE_COLORS if entity.type == :minor
            @game.tiles
                 .select { |tile| colors.include?(tile.color) }
                 .uniq(&:name)
                 .select { |tile| @game.upgrades_to?(hex.tile, tile) }
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            # Special case for the Ruhr green tile, which loses a town.
            return tile.rotation.zero? if hex.name == 'B16' && tile.name == 'X11'

            # Special case for the green Dunkerque tile. This must connect to
            # the second port exit (to hex F2).
            return super && tile.exits.include?(2) if hex.name == 'G3' && tile.color == :green

            super
          end

          def process_lay_tile(action)
            super
            @game.after_lay_tile(action.hex, action.tile, action.entity)
          end
        end
      end
    end
  end
end
