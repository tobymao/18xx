# frozen_string_literal: true

require_relative '../special_track'
require_relative 'lay_tile_with_chattanooga_check'

module Engine
  module Step
    module G18MS
      class SpecialTrack < SpecialTrack
        include LayTileWithChattanoogaCheck
      end
    end
  end
end
