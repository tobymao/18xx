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
        needs :phase_styles, default: nil # array parallel to @revenues: [{ label: 'I-II', colors: [a, b] }, ...]

        HEIGHT = 27
        def render
          styled = !@phase_styles.nil?

          # Compute text and width first in order to get total_width
          computed_revenues = @revenues.map do |rev|
            phase, revenue = rev
            text = "#{'D' if phase == :diesel}#{revenue}"
            text = '—' if styled && revenue.to_i.zero?

            {
              text: text,
              width: text.size * 16,
              color: phase == :diesel ? :gray : phase,
            }
          end

          # uniform box width so stacked rows line up
          if styled
            max_width = computed_revenues.map { |r| r[:width] }.max
            computed_revenues.each { |r| r[:width] = max_width }
          end

          # Compute total width of rectangles so we can center
          step_size = (computed_revenues.size / @rows.to_f).ceil
          total_width = computed_revenues.each_slice(step_size).map do |slice|
            slice.sum { |revenue| revenue[:width] }
          end

          row = 0
          t_x = -(total_width[row] * 0.5)
          index = 0
          t_y = -((@rows - 1) * HEIGHT * 0.5)

          children = computed_revenues.flat_map do |rev|
            style = @phase_styles && @phase_styles[index]
            colors = style && style[:colors].map { |c| c.start_with?('#') ? c : color_for(c) }
            fill = if colors
                     colors[0]
                   else
                     (rev[:color].start_with?('#') ? rev[:color] : color_for(rev[:color]))
                   end
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

            elements = [h(:rect, attrs: rect_attrs)]

            if colors
              # second color fills the lower-right half, only if it differs from the first
              if colors[1] && colors[1] != colors[0]
                elements << h(:polygon, attrs: {
                                points: "#{width},-12 #{width},#{HEIGHT - 12} 0,#{HEIGHT - 12}",
                                fill: colors[1],
                                transform: "translate(#{t_x} #{t_y})",
                              })
              end

              elements << h(:text, {
                              attrs: {
                                transform: "translate(#{t_x - 4} #{t_y})",
                                'text-anchor': 'end',
                                'dominant-baseline': 'central',
                                'font-size': '16',
                                fill: '#000',
                              },
                            }, style[:label])
            end

            elements << h('text.number', text_props, rev[:text])

            t_x += width
            index += 1
            if (index % step_size).zero? && index < computed_revenues.size
              row += 1
              t_x = -(total_width[row] * 0.5)
              t_y += HEIGHT
            end

            elements
          end

          h(:g, { attrs: { transform: @transform } }, children)
        end
      end
    end
  end
end
