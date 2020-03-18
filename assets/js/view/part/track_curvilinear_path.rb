# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackCurvilinearPath < Base
      SHARP = 1
      GENTLE = 2
      STRAIGHT = 3

      needs :path
      needs :color, default: 'black'

      # returns SHARP, GENTLE, or STRAIGHT
      def compute_curvilinear_type(edge_a, edge_b)
        edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
        diff = edge_b - edge_a
        diff = (edge_a - edge_b) % 6 if diff > 3
        diff
      end

      # degrees to rotate the svg path for this track path; e.g., a normal straight
      # is 0,3; for 1,4, rotate = 60
      def compute_track_rotation_degrees(edge_a, edge_b)
        edge_a, edge_b = edge_b, edge_a if edge_b < edge_a

        if (edge_b - edge_a) > 3
          60 * edge_b
        else
          60 * edge_a
        end
      end

      def parse_tile
        @exits = @path.exits
      end

      def preferred_render_locations
        [
          {
            region_weights: {},
            x: 0,
            y: 0,
          }
        ]
      end

      def render_part
        edge_a, edge_b = @exits

        curvilinear_type = compute_curvilinear_type(edge_a, edge_b)
        rotation = compute_track_rotation_degrees(edge_a, edge_b)

        d =
          case curvilinear_type
          when SHARP
            'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5'
          when GENTLE
            'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5'
          when STRAIGHT
            'm 0 87 L 0 -87'
          else
            raise
          end

        props = {
          attrs: {
            class: 'curvilinear_path',
            transform: "rotate(#{rotation})",
            d: d,
            stroke: @color,
            'stroke-width' => 8
          }
        }

        h(:path, props)
      end
    end
  end
end
