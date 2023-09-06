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

            super
          end
        end
      end
    end
  end
end
