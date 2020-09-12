# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/part/city'
require 'view/game/part/town_location'
require 'view/game/runnable'

module View
  module Game
    module Part
      class TownRect < Base
        include Runnable
        include TownLocation

        needs :town
        needs :color, default: 'black'
        needs :width, default: 8

        # bias away from top and bottom if possible
        EDGE_TOWN_REVENUE_REGIONS = {
          0 => [[23], false],
          0.5 => [[12], true],
          1 => [[5], true],
          1.5 => [[19], false],
          2 => [[12], false],
          2.5 => [[5], false],
          3 => [[0], false],
          3.5 => [[11], true],
          4 => [[18], true],
          4.5 => [[23], true],
          5 => [[11], false],
          5.5 => [[18], false],
        }.freeze

        DOUBLE_DIT_REVENUE_ANGLES = [170, -130, 130, -10, 50, -50].freeze
        DOUBLE_DIT_REVENUE_REGIONS = City::OO_REVENUE_REGIONS

        # Maps the position method into the required format for
        # preferred_render_locations
        def preferred_render_locations
          edges = normalized_edges(@edge, @town.exits)
          town_position(@tile, @town, edges).map do |weights, x, y, angle|
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
          @num_cts = @tile.city_towns.size
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

          edges = normalized_edges(@edge, @town.exits)

          if @town.exits.size == 2
            if @num_cts == 1
              angle = town_rotation_angles(@tile, @town, edges)[0]
              reverse_side = town_track_type(edges) == :sharp

              # for gentle and straight, exact regions vary, but it's always in
              # CENTER; close enough to always use CENTER and not worry about rotations
              regions = CENTER
            else
              angle = DOUBLE_DIT_REVENUE_ANGLES[@edge]
              displacement = 35
              regions, = DOUBLE_DIT_REVENUE_REGIONS[@edge]
            end
          else
            angle = town_rotation_angles(@tile, @town, edges)[0]
            if @edge
              regions, invert = EDGE_TOWN_REVENUE_REGIONS[@edge]
              displacement = invert ? -35 : 35
            else
              regions = CENTER
            end
          end

          increment_weight_for_regions(regions)

          angle += 180 if reverse_side

          h(:g, { key: "#{@town.id}-r", attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
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
