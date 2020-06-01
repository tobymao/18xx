# frozen_string_literal: true

require 'view/part/track_curvilinear_path'
require 'view/part/base'

module View
  module Part
    class TrackCurvilinearHalfPath < TrackCurvilinearPath
      needs :exits

      REGIONS = {
        [STOP, :none] => [15, 21],
        [SHARP, :left] => [15, 21],
        [SHARP, :right] => [13, 14],
        [GENTLE, :left] => [14, 15, 21],
        [GENTLE, :right] => [6, 7, 14],
        [STRAIGHT, :left] => [2, 8],
        [STRAIGHT, :right] => [15, 21],
      }.freeze

      SVG_PATH_STRINGS = {
        [STOP, :none] => 'M 0 87 L 0 30',
        [SHARP, :left] => 'M 0 87 '\
                          'L 0 75 '\
                          'A 43.30125 43.30125 0 0 0 -21.575 37.5405',
        [SHARP, :right] => 'M -75 43.5 '\
                           'L -64.951875 37.5 '\
                           'A 43.30125 43.30125 0 0 1 -21.575 37.5405',
        [GENTLE, :left] => 'M 0 87 '\
                           'L 0 75 '\
                           'A 129.90375 129.90375 0 0 0 -17.375 10.0775',
        [GENTLE, :right] => 'M -75 -43.5 '\
                            'L -64.951875 -37.5 '\
                            'A 129.90375 129.90375 0 0 1 -17.375 10.0775',
        [STRAIGHT, :left] => 'M 0 87 '\
                             'L 0 0',
        [STRAIGHT, :right] => 'M 0 -87 '\
                              'L 0 0',
      }.freeze

      def preferred_render_locations
        regions = REGIONS[[@curvilinear_type, @direction]].map do |region|
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

      def load_from_tile
        puts 'WARNING: expected @path to have exactly one exit' unless @path.exits.one?
        @this_exit = @path.exits.first
        other_exits = @exits.reject { |e| e == @this_exit }
        # Commenting this warning for now, this happens on OO tiles
        # puts "WARNING: expected exactly one other exit; found #{other_exits}" unless other_exits.one?
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

        return :none if !other_exit || !this_exit

        if (this_exit + curvilinear_type) % 6 == other_exit
          :left
        elsif (other_exit + curvilinear_type) % 6 == this_exit
          :right
        end
      end

      def render_part
        props = {
          attrs: {
            transform: "rotate(#{@rotation})",
            d: SVG_PATH_STRINGS[[@curvilinear_type, @direction]],
            stroke: @color,
            'stroke-width' => 8,
          },
        }

        h(:path, props)
      end
    end
  end
end
