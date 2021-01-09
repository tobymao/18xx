# frozen_string_literal: true

require_relative '../track'
require_relative 'lay_tile_with_chattanooga_check'

module Engine
  module Step
    module G18MS
      class Track < Track
        include LayTileWithChattanoogaCheck
      end
    end
  end
end
