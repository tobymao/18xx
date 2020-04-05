# frozen_string_literal: true

require 'view/part/track_curvilinear_path'
require 'view/part/base'

module View
  module Part
    class TrackCurvilinearHalfPath < TrackCurvilinearPath
      needs :exits

      def preferred_render_locations
        regions =
          case [@curvilinear_type, @direction]
          when [SHARP, :left]
            [15, 21]
          when [SHARP, :right]
            [13, 14]
          when [GENTLE, :left]
            [14, 15, 21]
          when [GENTLE, :right]
            [6, 7, 14]
          when [STRAIGHT, :left]
            [2, 8]
          when [STRAIGHT, :right]
            [15, 21]
          end

        regions = regions.map do |region|
          rotate_region(region, degrees: @rotation)
        end

        [
          {
            region_weights: regions,
            x: 0,
            y: 0,
          }
        ]
      end

      def load_from_tile
        puts 'WARNING: expected @path to have exactly one exit' unless @path.exits.one?
        @this_exit = @path.exits.first
        other_exits = @exits.reject { |e| e == @this_exit }
        puts "WARNING: expected exactly one other exit; found #{other_exits}" unless other_exits.one?
        @other_exit = other_exits.first

        @curvilinear_type = compute_curvilinear_type(@this_exit, @other_exit)
        @rotation = compute_track_rotation_degrees(@this_exit, @other_exit)
        @direction = compute_direction(@this_exit, @other_exit, @curvilinear_type)
      end

      # returns :left or :right; if the edge that this path starts from is
      # treated as the bottom, which way does the path curve?
      def compute_direction(this_exit, other_exit, curvilinear_type)
        if curvilinear_type == STRAIGHT
          # no curve but we still need a direction, and we need to ensure both
          # "half paths" have different directions
          return this_exit < other_exit ? :left : :right
        end

        if (this_exit + curvilinear_type) % 6 == other_exit
          :left
        elsif (other_exit + curvilinear_type) % 6 == this_exit
          :right
        end
      end

      def render_part
        d =
          case @curvilinear_type
          when SHARP
            midpoint = '-21.575 37.5405'
            radius = 43.30125
            {
              left: 'M 0 87 '\
                    'L 0 75 '\
                    "A #{radius} #{radius} 0 0 0 #{midpoint}",
              right: 'M -75 43.5 '\
                     'L -64.951875 37.5 '\
                     "A #{radius} #{radius} 0 0 1 #{midpoint}",
            }
          when GENTLE
            midpoint = '-17.375 10.0775'
            radius = 129.90375
            {
              left: 'M 0 87 '\
                    'L 0 75 '\
                    "A #{radius} #{radius} 0 0 0 #{midpoint}",
              right: 'M -75 -43.5 '\
                     'L -64.951875 -37.5 '\
                     "A #{radius} #{radius} 0 0 1 #{midpoint}",
            }
          when STRAIGHT
            {
              left: 'M 0 87 '\
                    'L 0 0',
              right: 'M 0 -87 '\
                     'L 0 0',
            }
          else
            raise
          end
        d = d[@direction]

        props = {
          attrs: {
            class: 'curvilinear_path',
            transform: "rotate(#{@rotation})",
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
