# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18FR
      module Tracker
        include Engine::Step::Tracker
        def legal_tile_rotation?(entity_or_entities, hex, tile)
          # We will remove a town from the yellow B tile, so we will not follow the normal path upgrade rules
          return true if tile.name == @game.class::GREEN_B_TILE_NAME && tile.rotation == hex.tile.rotation

          super
        end
      end
    end
  end
end
