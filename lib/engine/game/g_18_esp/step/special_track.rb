# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'lay_tile_check'

module Engine
  module Game
    module G18ESP
      module Step
        # No destination check needed: all TileLay abilities are bound to MINE_HEXES which cannot complete a destination route.
        class SpecialTrack < Engine::Step::SpecialTrack
          include LayTileCheck
        end
      end
    end
  end
end
