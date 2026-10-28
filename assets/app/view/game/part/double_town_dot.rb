# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/part/single_revenue'
require 'view/game/runnable'

module View
  module Game
    module Part
      class DoubleTownDot < Base
        include Runnable

        needs :color, default: 'black'
        needs :tile
        needs :double_town
        needs :width, default: 8
        needs :show_revenue

        DOT_OFFSET = 12
        PILL_HALF_WIDTH = 14
        REVENUE_DISPLACEMENT = 58

        def preferred_render_locations
          [{ region_weights: CENTER, x: 0, y: 0 }]
        end

        def towns
          @double_town.towns
        end

        def direction(loc, radius)
          angle = @tile.compute_loc(loc) * 60 / 180.0 * Math::PI
          [-Math.sin(angle) * radius, Math.cos(angle) * radius]
        end

        def render_pill
          x, y = direction(@double_town.axis, DOT_OFFSET)

          [
            [(PILL_HALF_WIDTH * 2) + 2, 'black'],
            [(PILL_HALF_WIDTH * 2) - 2, 'white'],
          ].map do |stroke_width, stroke|
            h(:line, attrs: {
                x1: -x.round(2),
                y1: -y.round(2),
                x2: x.round(2),
                y2: y.round(2),
                stroke: stroke,
                'stroke-width': stroke_width,
                'stroke-linecap': 'round',
              })
          end
        end

        def dot_positions
          x, y = direction(@double_town.axis, DOT_OFFSET)
          [[-x, -y], [x, y]]
        end

        def render_dots
          radius = 10 * (0.8 + (@width.to_i / 40))

          dot_positions.map do |cx, cy|
            h(:circle, attrs: {
                cx: cx.round(2),
                cy: cy.round(2),
                r: radius,
                fill: @color,
                stroke: 'white',
                'stroke-width': 4,
              })
          end
        end

        def render_hit_boxes
          towns.zip(dot_positions).map do |town, (cx, cy)|
            h(HitBox, click: -> { touch_node(town) }, transform: "translate(#{cx.round(2)} #{cy.round(2)})",
                      r: DOT_OFFSET)
          end
        end

        def render_revenues
          towns.zip(@double_town.revenue_locs).map do |town, loc|
            revenue = town.uniq_revenues.first
            next if revenue.nil? || revenue.zero?

            x, y = direction(loc, REVENUE_DISPLACEMENT)
            h(:g, { key: "#{town.id}-r", attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
              h(Part::SingleRevenue, revenue: revenue, transform: rotation_for_layout),
            ])
          end.compact
        end

        def render_part
          children = render_pill + render_dots
          children.concat(render_revenues) if @show_revenue
          children.concat(render_hit_boxes)
          h(:g, { key: "#{towns.first.id}-d" }, children)
        end
      end
    end
  end
end
