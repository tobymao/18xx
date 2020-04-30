# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/base'

module View
  module Part
    class TownRect < Base
      needs :edges
      needs :color, default: 'black'

      HEIGHT = 8
      WIDTH = 32

      EDGE_TRACK_LOCATIONS = [
        TRACK_TO_EDGE_0,
        TRACK_TO_EDGE_1,
        TRACK_TO_EDGE_2,
        TRACK_TO_EDGE_3,
        TRACK_TO_EDGE_4,
        TRACK_TO_EDGE_5,
      ].freeze

      SHARP_TRACK_LOCATIONS = [
        [13, 14, 15, 19, 20, 21],
        [5, 6, 7, 12, 13, 14],
        [0, 1, 2, 6, 7, 8],
        [2, 3, 4, 8, 9, 10],
        [9, 10, 11, 16, 17, 18],
        [15, 16, 17, 21, 22, 23],
      ].freeze

      def noramlized_edges
        return @noramlized_edges if defined? @noramlized_edges

        edge_a, edge_b = @edges
        edge_a += 6 if (edge_b - edge_a).abs > 3
        edge_a, edge_b = edge_b, edge_a if edge_b < edge_a

        @noramlized_edges = [edge_a, edge_b]
      end

      def track_type
        return @track_type if defined? @track_type

        edge_a, edge_b = noramlized_edges

        @track_type = case edge_b - edge_a
                      when 3
                        :straight
                      when 2
                        :gentle
                      else
                        :sharp
                      end
      end

      def position_angle
        return @position_angle if defined? @position_angle

        edge_a, = noramlized_edges
        angle = case track_type
                when :sharp
                  (edge_a + 0.5) * 60
                when :gentle
                  (edge_a * 60) + 5
                else
                  edge_a * 60
                end
        radians = (angle / 180) * Math::PI

        @position_angle = [angle, -Math.sin(radians), Math.cos(radians)]
      end

      def position
        return @position if defined? @position

        edge_a, = noramlized_edges
        angle = case track_type
                when :sharp
                  (edge_a + 0.5) * 60
                when :gentle
                  (edge_a * 60) + 2
                else
                  edge_a * 60
                end
        radians = (angle / 180) * Math::PI

        position = case track_type
                   when :sharp
                     43.5
                   when :gentle
                     53.375
                   else
                     40
                   end

        @position = [-Math.sin(radians) * position,
                     Math.cos(radians) * position]
      end

      def track_location
        return @track_location if defined? @track_location

        edge_a, = noramlized_edges

        @track_location = case track_type
                          when :sharp
                            SHARP_TRACK_LOCATIONS[edge_a % 6]
                          else
                            EDGE_TRACK_LOCATIONS[edge_a % 6]
                          end
      end

      def preferred_render_locations
        [
          {
            region_weights: track_location,
            x: position[0],
            y: position[1],
          },
        ]
      end

      def rotation_angle
        return @rotation_angle if defined? @rotation_angle

        edge_a, = noramlized_edges
        @rotation_angle = case track_type
                          when :sharp
                            (edge_a + 2) * 60
                          when :gentle
                            (edge_a * 60) - 10
                          else
                            edge_a * 60
                          end
      end

      def render
        attrs = {
          class: 'town_rect',
          transform: "#{translate} rotate(#{rotation_angle})",
          x: -WIDTH / 2,
          y: -HEIGHT / 2,
          height: HEIGHT,
          width: WIDTH,
          fill: @color,
          stroke: 'none'
        }

        h(:rect, attrs: attrs)
      end
    end
  end
end
