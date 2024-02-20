# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    module Part
      class MultiRevenue < Snabberb::Component
        include Lib::Settings

        needs :revenues
        needs :transform, default: 'translate(0 0)'
        needs :rows, default: 1

        HEIGHT = 27
        def render
          # Compute text and width first in order to get total_width
          computed_revenues = @revenues.map do |rev|
            phase, revenue = rev
            text = "#{'D' if phase == :diesel}#{revenue}"

            {
              text: text,
              width: text.size * 16,
              color: phase == :diesel ? :gray : phase,
            }
          end

          # Compute total width of rectangles so we can center
          step_size = (computed_revenues.size / @rows.to_f).ceil
          total_width = Array.new(@rows) do |row|
            computed_revenues[(row - 1) * step_size, step_size].sum do |revenue|
              revenue[:width]
            end
          end

          row = 0
          t_x = -(total_width[row] * 0.5)
          index = 0
          t_y = 0
          children = computed_revenues.flat_map do |rev|
            fill = rev[:color].start_with?('#') ? rev[:color] : color_for(rev[:color])
            font_color = contrast_on(fill)
            width = rev[:width]

            rect_attrs = {
              fill: fill,
              transform: "translate(#{t_x} #{t_y})",
              height: HEIGHT,
              width: width,
              x: 0,
              y: -12,
            }

            text_props = {
              attrs: {
                transform: "translate(#{t_x + (width * 0.5)} #{t_y})",
                fill: font_color,
                stroke: font_color,
                'dominant-baseline': 'central',
              },
            }
            t_x += width
            index += 1
            if index == step_size && index < computed_revenues.size
              row += 1
              t_x = -(total_width[row] * 0.5)
              t_y += HEIGHT
            end
            [
              h(:rect, attrs: rect_attrs),
              h('text.number', text_props, rev[:text]),
            ]
          end

          h(:g, { attrs: { transform: @transform } }, children)
        end
      end
    end
  end
end
