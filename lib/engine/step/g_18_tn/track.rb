# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18TN
      class Track < Track
        # Nashville starts as a yellow hex with label N, upgraded to green N, but
        # from brown on only P tiles is allowed.
        NASHVILLE = 'F11'
        # Chattanooga starts as a yellow hex with label C, upgraded to green C, but
        # from brown on only P tiles is allowed.
        CHATTANOOGA = 'H15'

        TILES_TO_MODIFY = [NASHVILLE, CHATTANOOGA].freeze

        def process_lay_tile(action)
          super

          action.tile.label = 'P' if TILES_TO_MODIFY.include?(action.tile.hex.name) && action.tile.color == :green
        end
      end
    end
  end
end
