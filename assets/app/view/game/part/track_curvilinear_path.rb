# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackCurvilinearPath < Base
        STOP = 0
        SHARP = 1
        GENTLE = 2
        STRAIGHT = 3

        REGIONS = {
          STOP => [15, 21],
          SHARP => [13, 14, 15, 21],
          GENTLE => [6, 7, 14, 15, 21],
          STRAIGHT => [2, 8, 15, 21],
        }.freeze

        SVG_PATH_STRINGS = {
          STOP => 'M 0 87 L 0 30',
          SHARP => 'M 0 87 '\
          'L 0 75 '\
          'A 43.30125 43.30125 0 0 0 -64.951875 37.5 '\
          'L -75 43.5',
          GENTLE => 'M 0 87 '\
          'L 0 75 '\
          'A 129.90375 129.90375 0 0 0 -64.951875 -37.5 '\
          'L -75 -43.5',
          STRAIGHT => 'M 0 87 '\
          'L 0 -87',
        }.freeze

        needs :path
        needs :color, default: 'black'
        needs :width, default: 8
        needs :dash, default: '0'

        # returns SHARP, GENTLE, or STRAIGHT
        def compute_curvilinear_type(edge_a, edge_b)
          return 0 unless edge_b

          edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
          diff = edge_b - edge_a
          diff = (edge_a - edge_b) % 6 if diff > 3
          diff
        end

        # degrees to rotate the svg path for this track path; e.g., a normal straight
        # is 0,3; for 1,4, rotate = 60
        def compute_track_rotation_degrees(edge_a, edge_b)
          return (60 * edge_a) unless edge_b

          edge_a, edge_b = edge_b, edge_a if edge_b < edge_a

          if (edge_b - edge_a) > 3
            60 * edge_b
          else
            60 * edge_a
          end
        end

        def load_from_tile
          edge_a, edge_b = @path.exits

          @curvilinear_type = compute_curvilinear_type(edge_a, edge_b)
          @rotation = compute_track_rotation_degrees(edge_a, edge_b)
        end

        def preferred_render_locations
          regions = REGIONS[@curvilinear_type].map do |region|
            rotate_region(region, degrees: @rotation)
          end

          [
            {
              region_weights: regions,
              x: 0,
              y: 0,
            },
          ]
        end

        def render_part
          props = {
            attrs: {
              transform: "rotate(#{@rotation})",
              d: SVG_PATH_STRINGS[@curvilinear_type],
              stroke: @color,
              'stroke-width': @width,
              'stroke-dasharray': @dash,
            },
          }

          h(:path, props)
        end
      end
    end
  end
end
