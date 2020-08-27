# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/part/city'
require 'view/game/runnable'

module View
  module Game
    module Part
      class TownRect < Base
        include Runnable

        needs :town
        needs :color, default: 'black'
        needs :width, default: 8

        SINGLE_STOP_TWO_EXIT_REGIONS = {
          straight: [CENTER] * 6,
          sharp: [
            [14, 15, 19, 20],
            [5, 7, 12, 14],
            [0, 1, 7, 8],
            [3, 4, 8, 9],
            [9, 11, 16, 18],
            [15, 16, 22, 23],
          ],
          gentle: [
            [14],
            [7],
            [8],
            [9],
            [16],
            [15],
          ],
        }.freeze

        MULTIPLE_STOP_TWO_EXIT_REGIONS = {
          straight: [
            [15],
            [14],
            [7],
            [8],
            [9],
            [16],
          ],
          sharp: [
            [15, 20, 21],
            [12, 13, 14],
            [0, 6, 7],
            [2, 3, 8],
            [9, 10, 11],
            [16, 17, 23],
          ],
          gentle: [
            [15, 12],
            [13, 14],
            [6, 7],
            [2, 8],
            [9, 10],
            [16, 17],
          ],
        }.freeze

        EDGE_TOWN_REGIONS = {
          0 => [21],
          0.5 => [13, 21],
          1 => [13],
          1.5 => [6, 13],
          2 => [6],
          2.5 => [2, 6],
          3 => [2],
          3.5 => [2, 10],
          4 => [10],
          4.5 => [10, 17],
          5 => [17],
          5.5 => [17, 21],
        }.freeze

        # absolute value of angle (in degrees) to tilt the town rectangle relative
        # to a straight line from edge_a to the opposite edge
        RECTANGLE_TILT = {
          sharp: 40,
          gentle: 15,
        }.freeze

        # from center of the hex, how many degrees of offset to apply to
        # positioning the town rectangle; this value will be added/subtracted to
        # (edge_a * 60)
        POSITIONAL_ANGLE = {
          sharp: 12.12,
          gentle: 6.11,
        }.freeze

        DOUBLE_DIT_REVENUE_ANGLES = [10, -130, 130, -10, 50, -50].freeze
        DOUBLE_DIT_REVENUE_REGIONS = City::OO_REVENUE_REGIONS

        # Returns the two edges plus min edge so that a is the edge to render close to, and
        # (a - b).abs is 1, 2 or 3.
        def self.normalized_edges(edge_a, exits)
          if edge_a && exits.size == 2
            edge_b = (exits - [edge_a]).first
            edges = [edge_a, edge_b]
            edges[edges.index(edges.min)] += 6 if (edge_a - edge_b).abs > 3
            edges.append(edges.min)
          else
            [edge_a, nil, nil]
          end
        end

        # Returns a symbol of :straight, :gentle or :sharp based on the absolute
        # difference of the normalized edges
        def self.track_type(edges)
          @@track_type ||= {}
          @@track_type[edges] ||=
            begin
              edge_a, edge_b, = edges
              [nil, :sharp, :gentle, :straight][(edge_a - edge_b).abs]
            end
        end

        # Returns a symbol of :left, :right, or :straight based on the direction
        # the track curves starting from edge_a
        def self.track_direction(edges)
          @track_direction ||= {}
          @track_direction[edges] ||=
            begin
              edge_a, edge_b, = edges

              if (edge_a - edge_b).abs == 3
                :straight
              elsif edge_a > edge_b
                :right
              elsif edge_a < edge_b
                :left
              end
            end
        end

        # Returns an array of options for track positions
        def self.track_location(tile, town, edges)
          edge_a, = edges

          loc = if town.exits.size == 2 && tile.stops.one?
                  SINGLE_STOP_TWO_EXIT_REGIONS[track_type(edges)][edges.last]
                elsif town.exits.size == 2
                  MULTIPLE_STOP_TWO_EXIT_REGIONS[track_type(edges)][edge_a % 6]
                elsif edge_a
                  EDGE_TOWN_REGIONS[edge_a]
                else
                  CENTER
                end
          [loc]
        end

        # Returns an array of rotation options for the town rectangle that
        # corresponds to the positions given from track_location
        def self.rotation_angles(tile, town, edges)
          edge_a, = edges

          if town.exits.size == 2 && tile.stops.one?
            case track_type(edges)
            when :straight
              [edges.last * 60]
            when :sharp
              [(edges.last + 2) * 60]
            when :gentle
              [(edges.last * 60) - 30]
            end
          elsif town.exits.size == 2
            tilt = RECTANGLE_TILT[track_type(edges)] || 0

            delta = case track_direction(edges)
                    when :straight
                      0
                    when :left
                      -tilt
                    when :right
                      tilt
                    end

            [(edge_a * 60) + delta]
          elsif edge_a
            [edge_a * 60]
          else
            # This town is in the center. Find the orientation of the town
            # by looking at the first path connected to it
            path = town.paths.first
            if !path.edges.empty?
              [path.edges.first.num * 60]
            else
              other_stop = (path.stops - [town]).first
              other_edge = tile.preferred_city_town_edges[other_stop] if other_stop
              if other_edge
                [other_edge * 60]
              else
                [0]
              end
            end
          end
        end

        # Returns an array of weights, location and rotations
        def self.position(tile, town, edges)
          edge_a, = edges

          if town.exits.size == 2 && tile.stops.one?
            angles, positions = case track_type(edges)
                                when :straight
                                  [[edge_a * 60], [0]]
                                when :sharp
                                  [[(edges.last + 0.5) * 60], [50]]
                                when :gentle
                                  [[(edges.last + 1) * 60], [23.2]]
                                end
          elsif town.exits.size == 2
            positional_angle = POSITIONAL_ANGLE[track_type(edges)] || 0

            delta = case track_direction(edges)
                    when :straight
                      0
                    when :left
                      positional_angle
                    when :right
                      -positional_angle
                    end

            angles = [(edge_a * 60) + delta]

            positions = case track_type(edges)
                        when :straight
                          [40]
                        when :sharp
                          [55.70]
                        when :gentle
                          [48.05]
                        end
          elsif edge_a
            angles = [edge_a * 60]
            positions = [50]
          else
            angles = [0]
            positions = [0]
          end

          radians = angles.map { |a| a / 180 * Math::PI }

          xs = positions.zip(radians).map { |p, r| -Math.sin(r) * p }
          ys = positions.zip(radians).map { |p, r| Math.cos(r) * p }

          track_location(tile, town, edges).zip(xs, ys, rotation_angles(tile, town, edges))
        end

        # Maps the position method into the required format for
        # preferred_render_locations
        def preferred_render_locations
          edges = TownRect.normalized_edges(@edge, @town.exits)
          TownRect.position(@tile, @town, edges).map do |weights, x, y, angle|
            {
              region_weights: weights,
              x: x,
              y: y,
              angle: angle,
            }
          end
        end

        def load_from_tile
          @tile = @town.tile
          @edge = @tile.preferred_city_town_edges[@town]
          @num_cts = @tile.cities.size + @tile.towns.size
        end

        def render_part
          height = @width.to_i / 2 + 4
          width = height * 4
          children = [h(:rect, attrs: {
            transform: "#{translate} #{rotation}",
            x: -width / 2,
            y: -height / 2,
            width: width,
            height: height,
            fill: @color,
            stroke: 'none',
          })]

          if (revenue = render_revenue)
            children << revenue
          end

          children << h(HitBox, click: -> { touch_node(@town) }, transform: translate) unless @town.solo?

          h(:g, children)
        end

        def render_revenue
          revenues = @town.uniq_revenues
          return if revenues.size > 1

          revenue = revenues.first
          return if revenue.zero?

          angle = 0
          displacement = 38
          x = render_location[:x]
          y = render_location[:y]
          reverse_side = false
          regions = []

          edges = TownRect.normalized_edges(@edge, @town.exits)

          if @town.exits.size == 2
            if @num_cts == 1
              angle = TownRect.rotation_angles(@tile, @town, edges)[0]
              reverse_side = TownRect.track_type(edges) == :sharp

              # for gentle and straight, exact regions vary, but it's always in
              # CENTER; close enough to always use CENTER and not worry about rotations
              regions = CENTER
            else
              angle = DOUBLE_DIT_REVENUE_ANGLES[@edge]
              displacement = 35
              regions = DOUBLE_DIT_REVENUE_REGIONS[@edge]
            end
          else
            angle = TownRect.rotation_angles(@tile, @town, edges)[0]
            if @edge
              displacement = 35
              # probably not accurate
              regions = EDGE_TOWN_REGIONS[@edge]
            else
              regions = CENTER
            end
          end

          increment_weight_for_regions(regions)

          angle += 180 if reverse_side

          h(:g, { attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
            h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
              h(:g, { attrs: { transform: "translate(#{displacement} 0) #{rotation_for_layout}" } }, [
                h(SingleRevenue,
                  revenue: revenue,
                  transform: "rotate(#{-angle})"),
              ]),
            ]),
          ])
        end
      end
    end
  end
end
