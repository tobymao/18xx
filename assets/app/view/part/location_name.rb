# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class LocationName < Base
      def preferred_render_locations
        if @tile.offboards.any?
          return [
            {
              region_weights: CENTER,
              x: 0,
              y: 0,
            },
            {
              region_weights: TOP_MIDDLE_ROW,
              x: 0,
              y: -24,
            },
            {
              region_weights: BOTTOM_MIDDLE_ROW,
              x: 0,
              y: 24,
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
            region_weights_in: { TRACK_TO_EDGE_3 => 1,
                                 UPPER_CENTER => 1,
                                 [6, 10] => 0.25,
                                 TOP_ROW => 0.1 },
            region_weights_out: { UPPER_CENTER => 1,
                                  [6, 10] => 0.25 },
            x: 0,
            y: -40,
          },
          {
            region_weights_in: { TRACK_TO_EDGE_0 => 1,
                                 LOWER_CENTER => 1,
                                 [13, 17] => 0.25,
                                 BOTTOM_ROW => 0.1 },
            region_weights_out: { LOWER_CENTER => 1,
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
