# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class LocationName < Base
      needs :tile

      def preferred_render_locations
        unless @tile.offboards.empty?
          return [
            {
              regions: { ['half_corner2.5', 'half_edge3', 'half_corner3.5'] => 1,
                         %w[half_edge2 half_edge4] => 0.25 },
              transform: 'translate(0 -10)',
            },
            {
              regions: { ['half_corner5.5', 'half_edge0', 'half_corner0.5'] => 1,
                         %w[half_edge5 half_edge1] => 0.25 },
              transform: 'translate(0 10)',
            },
          ]
        end

        [
          {
            regions: ['center'],
            transform: 'translate(0 0)',
          },
          {
            regions: { ['half_corner2.5', 'half_edge3', 'half_corner3.5'] => 1,
                       %w[half_edge2 half_edge4] => 0.25 },
            transform: 'translate(0 -40)',
          },
          {
            regions: { ['half_corner5.5', 'half_edge0', 'half_corner0.5'] => 1,
                       %w[half_edge5 half_edge1] => 0.25 },
            transform: 'translate(0 40)',
          },
        ]
      end

      def parse_tile
        @name = @tile.location_name
      end

      def should_render?
        !@name.nil?
      end

      def render_part
        attrs = {
          class: 'location_name',
          fill: 'black',
          transform: "scale(1.1) #{transform}",
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
