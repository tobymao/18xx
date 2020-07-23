# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18AL
      class Track < Track
        def process_lay_tile(action)
          super

          # Change Montgomery to use M tiles after first tile
          # placed there. From beginning Montgomery is a regular
          # city, but from "green" phase it has its own tiles.
          action.tile.label ||= 'M' if action.tile.hex.name == 'L5'
        end
      end
    end
  end
end
