# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/runnable'

module View
  module Game
    module Part
      class TownDot < Base
        include Runnable

        needs :color, default: 'black'
        needs :tile
        needs :town
        needs :width, default: 8

        REVENUE_DISPLACEMENT = 42
        REVENUE_EDGE_DISPLACEMENT = 38
        REVENUE_ANGLE = -60

        REVENUE_REGIONS = {
          flat: [9, 16],
          pointy: [8, 9],
        }.freeze

        CENTER_TOWN = [
          {
            region_weights: CENTER,
            x: 0,
            y: 0,
          },
        ].freeze

        OFFSET_TOWNS = [
          {
            region_weights: [13, 14],
            x: -40,
            y: 20,
          },
          {
            region_weights: [9, 10],
            x: 40,
            y: -20,
          },
          {
            region_weights: { [6, 7] => 0.5 },
            x: -40,
            y: -20,
          },
          {
            region_weights: { [16, 17] => 0.5 },
            x: 40,
            y: 20,
          },
        ].freeze

        def load_from_tile
          @edge = @tile.preferred_city_town_edges[@town]
        end

        def preferred_render_locations
          if @edge
            [
              {
                region_weights: TownRect::EDGE_TOWN_REGIONS[@edge],
                x: -Math.sin((@edge * 60) / 180 * Math::PI) * 50,
                y: Math.cos((@edge * 60) / 180 * Math::PI) * 50,
              },
            ]
          else
            # see if any other towns are also in the center
            @tile.towns.count { |t| !@tile.preferred_city_town_edges[t] } > 1 ? OFFSET_TOWNS : CENTER_TOWN
          end
        end

        def render_revenue
          revenues = @town.uniq_revenues
          return if revenues.size > 1

          revenue = revenues.first
          return if !@town.halt? && revenue.zero?

          x = render_location[:x]
          y = render_location[:y]

          angle = layout == :pointy ? -60 : 0

          displacement = @edge ? REVENUE_EDGE_DISPLACEMENT : REVENUE_DISPLACEMENT

          increment_weight_for_regions(REVENUE_REGIONS[layout])
          if @town.halt?
            h(:g, { key: "#{@town.id}-r", attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
              h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
                h(:g, { attrs: { transform: "translate(#{displacement} 0) #{rotation_for_layout}" } }, [
                  h('text.tile__text', { attrs: { transform: "scale(1.5), rotate(#{-angle})" } }, @town.symbol),
                ]),
              ]),
            ])
          else
            h(:g, { key: "#{@town.id}-r", attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
              h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
                h(:g, { attrs: { transform: "translate(#{displacement} 0) rotate(#{-angle})" } }, [
                  h(Part::SingleRevenue, revenue: revenue, transform: rotation_for_layout),
                ]),
              ]),
            ])
          end
        end

        def render_part
          children = [h(:circle, attrs: {
            transform: translate.to_s,
            r: 10 * (0.8 + @width.to_i / 40),
            fill: (@town.halt? ? 'gray' : @color),
            stroke: (@town.halt? ? @color : 'none'),
            'stroke-width': 4,
          })]

          children << render_revenue
          children << h(HitBox, click: -> { touch_node(@town) }, transform: translate) unless @town.solo?
          h(:g, { key: "#{@town.id}-d" }, children)
        end
      end
    end
  end
end
