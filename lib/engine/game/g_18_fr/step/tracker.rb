# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18FR
      module Tracker
        include Engine::Step::Tracker
        def legal_tile_rotation?(entity_or_entities, hex, tile)
          # The town is removed from the yllow B tile, so the normal path upgrade rules are not followed
          return true if tile.name == @game.class::GREEN_B_TILE_NAME && tile.rotation == hex.tile.rotation

          super
        end
      end
    end
  end
end
