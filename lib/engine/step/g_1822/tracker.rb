# frozen_string_literal: true

require_relative '../tracker'

module Engine
  module Step
    module G1822
      module Tracker
        include Step::Tracker

        def legal_tile_rotation?(entity, hex, tile)
          # We will remove a town from the white S tile, this meaning we will not follow the normal path upgrade rules
          if hex.name == @game.class::UPGRADABLE_S_HEX_NAME &&
            tile.name == @game.class::UPGRADABLE_S_YELLOW_CITY_TILE &&
            @game.class::UPGRADABLE_S_YELLOW_CITY_TILE_ROTATIONS.include?(tile.rotation)
            return true
          end

          super
        end
      end
    end
  end
end
