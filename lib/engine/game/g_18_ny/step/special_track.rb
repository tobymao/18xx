# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18NY
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            old_tile = action.hex.tile
            super
            @game.tile_lay(action.hex, old_tile, action.tile)
          end
        end
      end
    end
  end
end
