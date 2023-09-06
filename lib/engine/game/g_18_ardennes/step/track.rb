# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Track < Engine::Step::Track
          def legal_tile_rotation?(entity_or_entities, hex, tile)
            # Special case for the Ruhr green tile, which loses a town.
            return tile.rotation.zero? if hex.name == 'B16' && tile.name == 'X11'

            # Special case for the green Dunkerque tile. This must connect to
            # the second port exit (to hex F2).
            if hex.name == 'G3' && tile.color == :green
              return super && tile.exits.include?(2)
            end

            super
          end

          def process_lay_tile(action)
            super
            @game.after_lay_tile(action.hex, action.tile)
          end
        end
      end
    end
  end
end
