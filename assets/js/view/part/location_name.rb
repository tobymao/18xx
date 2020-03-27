# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class LocationName < Base
      def preferred_render_locations
        if @tile.offboards.any?
          return [
            {
              region_weights: { [7, 8, 9] => 1,
                                [6, 7, 9, 10] => 0.25 },
              x: 0,
              y: -10,
            },
            {
              region_weights: { [14, 15, 16] => 1,
                                [13, 14, 16, 17] => 0.25 },
              x: 0,
              y: 10,
            },
          ]
        end

        [
          {
            region_weights: CENTER,
            x: 0,
            y: 0,
          },
          {
            region_weights_in: { [2, 8] => 1,
                                 [7, 8, 9] => 1,
                                 [6, 10] => 0.25,
                                 [0, 1, 2, 3, 4] => 0.1 },
            region_weights_out: { [7, 8, 9] => 1,
                                  [6, 10] => 0.25 },
            x: 0,
            y: -40,
          },
          {
            region_weights_in: { [15, 21] => 1,
                                 [14, 15, 16] => 1,
                                 [13, 17] => 0.25,
                                 [19, 20, 21, 22, 23] => 0.1 },
            region_weights_out: { [14, 15, 16] => 1,
                                  [13, 14, 16, 17] => 0.25 },
            x: 0,
            y: 40,
          },
        ]
      end

      def load_from_tile
        @name = @tile.location_name
      end

      def render_part
        attrs = {
          class: 'location_name',
          fill: 'black',
          transform: "scale(1.1) #{translate}",
          'text-anchor': 'middle',
          'stroke-width': 0.5,
          'alignment-baseline': 'middle',
          'dominant-baseline': 'middle',
        }
        h(:text, { attrs: attrs }, @name)
      end
    end
  end
end
