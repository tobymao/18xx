# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/part/city'
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
        needs :show_revenue

        REVENUE_DISPLACEMENT = 42
        REVENUE_EDGE_DISPLACEMENT = 25
        REVENUE_ANGLE = -60
        TWO_DOT_OFFSET = 12

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

          angle = layout == :pointy ? REVENUE_ANGLE : 0

          displacement = @edge ? REVENUE_EDGE_DISPLACEMENT : REVENUE_DISPLACEMENT

          increment_weight_for_regions(REVENUE_REGIONS[layout])

          h(:g, { key: "#{@town.id}-r", attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
            h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
              h(:g, { attrs: { transform: "translate(#{displacement} 0) rotate(#{-angle})" } }, [
                if @town.halt?
                  h('text.tile__text',
                    { attrs: { transform: "scale(1.5), #{rotation_for_layout}" } },
                    @town.symbol)
                else
                  h(Part::SingleRevenue, revenue: revenue, transform: rotation_for_layout)
                end,
              ]),
            ]),
          ])
        end

        def render_part
          radius = 10 * (0.8 + (@width.to_i / 40))
          fill = @town.halt? ? 'gray' : @color
          stroke = @town.halt? ? @color : 'white'

          children = []

          case @town.size
          when 2
            children << h(:ellipse, attrs: {
                            transform: translate.to_s,
                            rx: TWO_DOT_OFFSET + radius + 4,
                            ry: radius + 3,
                            fill: 'white',
                            stroke: @color,
                            'stroke-width': 2,
                          })
            [-TWO_DOT_OFFSET, TWO_DOT_OFFSET].each do |dx|
              children << h(:circle, attrs: {
                              transform: "#{translate} translate(#{dx} 0)",
                              r: radius,
                              fill: fill,
                              stroke: stroke,
                              'stroke-width': 4,
                            })
            end
            if @show_revenue && !(rendered = render_revenue_size2).empty?
              children.concat(rendered)
            end
          when 1
            children << h(:circle, attrs: {
                            transform: translate.to_s,
                            r: radius,
                            fill: fill,
                            stroke: stroke,
                            'stroke-width': 4,
                          })
            children << render_boom if @town.boom
            if @show_revenue && (rendered = render_revenue)
              children << rendered
            end
          else
            raise NotImplementedError, "Unsupported town size: #{@town.size}"
          end

          children << h(HitBox, click: -> { touch_node(@town) }, transform: translate) unless @town.solo?
          h(:g, { key: "#{@town.id}-d" }, children)
        end

        def render_revenue_size2
          revenues = @town.uniq_revenues
          return [] if revenues.size > 1

          revenue = revenues.first
          return [] if revenue.zero?

          x = render_location[:x]
          y = render_location[:y]

          increment_weight_for_regions(REVENUE_REGIONS[layout])

          [-REVENUE_DISPLACEMENT, REVENUE_DISPLACEMENT].map.with_index do |dx, i|
            h(:g, {
                key: "#{@town.id}-r#{i}",
                attrs: { transform: "translate(#{(x + dx).round(2)} #{y.round(2)})" },
              }, [
              h(Part::SingleRevenue, revenue: revenue, transform: rotation_for_layout),
            ])
          end
        end

        def render_boom(transform: nil)
          h(:circle, attrs: {
              transform: transform || translate.to_s,
              stroke: @color,
              r: Part::City::SLOT_RADIUS,
              'stroke-width': 2,
              'stroke-dasharray': 6,
            })
        end
      end
    end
  end
end
