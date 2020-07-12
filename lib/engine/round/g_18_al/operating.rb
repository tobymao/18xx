# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G18AL
      class Operating < Operating
        def process_lay_tile(action)
          super

          # Change Montgomery to use M tiles after first tile
          # placed there. From beginning Montgomery is a regular
          # city, but from "green" phase it has its own tiles.
          action.tile.label = 'M' if action.tile.hex.name == 'L5'
        end
      end
    end
  end
end
