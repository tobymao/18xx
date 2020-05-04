# frozen_string_literal: true

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

      # Returns the two edges so that a < b and b - a is 1, 2 or 3.
      def normalized_edges
        @normalized_edges ||= begin
                                edge_a, edge_b = @edges
                                edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
                                edge_a += 6 if (edge_b - edge_a).abs > 3
                                edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
                                [edge_a, edge_b]
                              end
      end

      # Takes the difference in normalized edges and returns a symbol of
      # :straight, :gentle or :sharp
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

      # Returns the angle that the town rect needs to be based on the rotation
      # of the tile
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

      # Returns an array of options for track positions
      def track_location
        @track_location ||= begin
                              edge_a, edge_b = normalized_edges

                              case track_type
                              when :sharp
                                [SHARP_TRACK_LOCATIONS[edge_a % 6]]
                              else
                                [CENTER,
                                 EDGE_TRACK_LOCATIONS[edge_a % 6],
                                 EDGE_TRACK_LOCATIONS[edge_b % 6]]
                              end
                            end
      end

      # Returns an array of rotation options for the town rectangle that
      # corresponds to the positions given from track_location
      def rotation_angles
        @rotation_angles ||= begin
                               edge_a, = normalized_edges
                               case track_type
                               when :sharp
                                 [(edge_a + 2) * 60]
                               when :gentle
                                 [(edge_a * 60) - 30,
                                  (edge_a * 60) - 10,
                                  (edge_a * 60) - 50]
                               else
                                 [edge_a * 60] * 3
                               end
                             end
      end

      # Returns an array of weights, location and rotations
      def position
        @position ||= begin
                        edge_a, edge_b = normalized_edges
                        angles = case track_type
                                 when :sharp
                                   [(edge_a + 0.5) * 60]
                                 when :gentle
                                   [(edge_a + 1) * 60,
                                    (edge_a * 60) + 2,
                                    (edge_b * 60) - 2]
                                 else
                                   [edge_a * 60] * 3
                                 end
                        radians = angles.map { |a| a / 180 * Math::PI }

                        positions = case track_type
                                    when :sharp
                                      [43.5]
                                    when :gentle
                                      [20, 53.375, 53.375]
                                    else
                                      [0, 40, -40]
                                    end

                        xs = positions.zip(radians).map { |p, r| -Math.sin(r) * p }
                        ys = positions.zip(radians).map { |p, r| Math.cos(r) * p }

                        track_location.zip(xs, ys, rotation_angles)
                      end
      end

      # Maps the position method into the required format for
      # preferred_render_locations
      def preferred_render_locations
        position.map do |weights, x, y, angle|
          {
            region_weights: weights,
            x: x,
            y: y,
            angle: angle
          }
        end
      end

      def render
        attrs = {
          class: 'town_rect',
          transform: "#{translate} #{rotation}",
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
