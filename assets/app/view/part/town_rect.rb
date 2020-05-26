# frozen_string_literal: true

require 'view/hit_box'
require 'view/part/base'
require 'view/part/city'
require 'view/runnable'

module View
  module Part
    class TownRect < Base
      include Runnable

      needs :town
      needs :color, default: 'black'
      needs :tile

      HEIGHT = 8
      WIDTH = 32

      SINGLE_TOWN_REGIONS = {
        straight: [CENTER] * 6,
        sharp: [
          [14, 15],
          [7, 14],
          [7, 8],
          [8, 9],
          [9, 16],
          [15, 16]
        ],
        gentle: [
          [14],
          [7],
          [8],
          [9],
          [16],
          [15]
        ],
      }.freeze

      EDGE_TOWN_REGIONS = {
        straight: View::Part::City::EDGE_CITY_REGIONS,
        sharp: View::Part::City::EDGE_CITY_REGIONS,
        gentle: View::Part::City::EDGE_CITY_REGIONS,
      }.freeze

      # absolute value of angle (in degrees) to tilt the town rectangle relative
      # to a straight line from edge_a to the opposite edge
      RECTANGLE_TILT = {
        sharp: 10,
        gentle: 10,
      }.freeze

      # from center of the hex, how many degrees of offset to apply to
      # positioning the town rectangle; this value will be added/subtracted to
      # (edge_a * 60)
      POSITIONAL_ANGLE = {
        sharp: 2,
        gentle: 2,
      }.freeze

      DOUBLE_DIT_REVENUE_ANGLES = [10, -130, 130, -10, 50, -50].freeze
      DOUBLE_DIT_REVENUE_REGIONS = View::Part::City::OO_REVENUE_REGIONS

      # Returns the two edges so that a is the edge to render close to, and
      # (a - b).abs is 1, 2 or 3.
      def normalized_edges
        @normalized_edges ||=
          begin
            edge_a = @tile.preferred_city_town_edges[@town]
            edge_b = (@town.exits - [edge_a]).first
            edges = [edge_a, edge_b]
            edges[edges.index(edges.min)] += 6 if (edge_a - edge_b).abs > 3
            edges
          end
      end

      def min_edge
        @min_edge ||= normalized_edges.min
      end

      # Returns a symbol of :straight, :gentle or :sharp based on the absolute
      # difference of the normalized edges
      def track_type
        @track_type ||=
          begin
            edge_a, edge_b = normalized_edges
            [nil, :sharp, :gentle, :straight][(edge_a - edge_b).abs]
          end
      end

      # Returns a symbol of :left, :right, or :straight based on the direction
      # the track curves starting from edge_a
      def track_direction
        @track_direction ||=
          begin
            edge_a, edge_b = normalized_edges

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
      def track_location
        edge_a, = normalized_edges

        loc =
          if @tile.towns.size == 1
            SINGLE_TOWN_REGIONS[track_type][min_edge]
          else
            EDGE_TOWN_REGIONS[track_type][edge_a % 6]
          end
        [loc]
      end

      # Returns an array of rotation options for the town rectangle that
      # corresponds to the positions given from track_location
      def rotation_angles
        edge_a, = normalized_edges

        if @tile.towns.size == 1
          {
            straight: [min_edge * 60],
            sharp: [(min_edge + 2) * 60],
            gentle: [(min_edge * 60) - 30],
          }[track_type]
        else

          tilt = RECTANGLE_TILT[track_type] || 0

          delta = {
            left: -tilt,
            right: tilt,
            straight: 0,
          }[track_direction]

          [(edge_a * 60) + delta]
        end
      end

      # Returns an array of weights, location and rotations
      def position
        edge_a, = normalized_edges

        if @tile.towns.size == 1
          angles = {
            straight: [edge_a * 60],
            sharp: [(min_edge + 0.5) * 60],
            gentle: [(min_edge + 1) * 60],
          }[track_type]

          positions = {
            straight: [0],
            sharp: [43.5],
            gentle: [20],
          }[track_type]

        else
          positional_angle = POSITIONAL_ANGLE[track_type] || 0
          delta = {
            left: positional_angle,
            right: -positional_angle,
            straight: 0,
          }[track_direction]
          angles = [(edge_a * 60) + delta]

          positions = {
            straight: [40],
            sharp: [60],
            gentle: [53.375],
          }[track_type]
        end

        radians = angles.map { |a| a / 180 * Math::PI }

        xs = positions.zip(radians).map { |p, r| -Math.sin(r) * p }
        ys = positions.zip(radians).map { |p, r| Math.cos(r) * p }

        track_location.zip(xs, ys, rotation_angles)
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

      def load_from_tile
        @edge = @tile.preferred_city_town_edges[@town]
        @towns = @tile.towns.size
      end

      def render_part
        children = [h(:rect, attrs: {
            transform: "#{translate} #{rotation}",
            x: -WIDTH / 2,
            y: -HEIGHT / 2,
            width: WIDTH,
            height: HEIGHT,
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
        revenues = @town.revenue.values.uniq
        return if revenues.uniq.size > 1

        revenue = revenues.first
        return if revenue.zero?

        angle = 0
        displacement = 38
        x = render_location[:x]
        y = render_location[:y]
        reverse_side = false
        regions = []

        # AFAIK no tiles have more than 2 towns
        case @towns
        when 1
          angle = rotation_angles[0]
          reverse_side = track_type == :sharp

          # for gentle and straight, exact regions vary, but it's always in
          # CENTER; close enough to always use CENTER and not worry about rotations
          regions = CENTER
        when 2
          angle = DOUBLE_DIT_REVENUE_ANGLES[@edge]
          displacement = 35
          regions = DOUBLE_DIT_REVENUE_REGIONS[@edge]
        end

        increment_weight_for_regions(regions)

        angle += 180 if reverse_side

        h(:g, { attrs: { transform: "translate(#{x} #{y})" } }, [
            h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
                h(:g, { attrs: { transform: "translate(#{displacement} 0)" } }, [
                    h(Part::SingleRevenue,
                      revenue: revenue,
                      transform: "rotate(#{-angle})")
                  ])
              ])
          ])
      end
    end
  end
end
