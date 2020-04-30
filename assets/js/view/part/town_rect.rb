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

      def normalized_edges
        @normalized_edges ||= begin
                                edge_a, edge_b = @edges
                                edge_a += 6 if (edge_b - edge_a).abs > 3
                                edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
                                [edge_a, edge_b]
                              end
      end

      def track_type
        @track_type ||= begin
                          edge_a, edge_b = normalized_edges

                          case edge_b - edge_a
                          when 3
                            :straight
                          when 2
                            :gentle
                          else
                            :sharp
                          end
                        end
      end

      def position_angle
        @position_angle ||= begin
                              edge_a, = normalized_edges
                              angle = case track_type
                                      when :sharp
                                        (edge_a + 0.5) * 60
                                      when :gentle
                                        (edge_a * 60) + 5
                                      else
                                        edge_a * 60
                                      end
                              radians = (angle / 180) * Math::PI

                              [angle, -Math.sin(radians), Math.cos(radians)]
                            end
      end

      def position
        @position ||= begin
                        edge_a, = normalized_edges
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

                        [-Math.sin(radians) * position,
                         Math.cos(radians) * position]
                      end
      end

      def track_location
        @track_location ||= begin
                              edge_a, = normalized_edges

                              case track_type
                              when :sharp
                                SHARP_TRACK_LOCATIONS[edge_a % 6]
                              else
                                EDGE_TRACK_LOCATIONS[edge_a % 6]
                              end
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
        @rotation_angle ||= begin
                              edge_a, = normalized_edges
                              case track_type
                              when :sharp
                                (edge_a + 2) * 60
                              when :gentle
                                (edge_a * 60) - 10
                              else
                                edge_a * 60
                              end
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
