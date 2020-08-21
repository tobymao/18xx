# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18GA
      class Track < Track
        LABEL_INITS = {
          'D10' =>
            {
              color: :yellow,
              label: 'Aug',
            },
          'G13' =>
            {
              color: :yellow,
              label: 'S',
            },
          'I11' =>
            {
              color: :green,
              label: 'B',
            },
          'F6' =>
            {
              color: :green,
              label: 'M',
            },
          }.freeze

        def process_lay_tile(action)
          super

          label_init = LABEL_INITS[action.tile.hex.name]
          return if !label_init || label_init[:color] != action.tile.color

          # Change 4 city tiles to their restricted label line after a specific color laid.
          action.tile.label ||= label_init[:label]
        end
      end
    end
  end
end
