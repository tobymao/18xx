# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'lay_tile_with_chattanooga_check'

module Engine
  module Game
    module G18MS
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include LayTileWithChattanoogaCheck
        end
      end
    end
  end
end
