# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18TN
      class Track < Track
        def process_lay_tile(action)
          super

          # Change Nashville to use M tiles after yellow tile
          # placed there. From beginning Nashville is a regular
          # city, but th green upgrade has label N.
          action.tile.label ||= 'N' if action.tile.hex.name == 'F11' && action.tile.color == :yellow
        end
      end
    end
  end
end
