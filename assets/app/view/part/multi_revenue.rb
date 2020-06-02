# frozen_string_literal: true

module View
  module Part
    class MultiRevenue < Snabberb::Component
      COLOR = {
        white: '#fff',
        yellow: '#fde900',
        green: '#71bf44',
        brown: '#cb7745',
        gray: '#bcbdc0',
        red: '#ec232a',
      }.freeze

      needs :revenues
      needs :transform, default: 'translate(0 0)'

      def render
        # Compute text and width first in order to get total_width
        computed_revenues = @revenues.map do |rev|
          phase, revenue = rev
          text = "#{'D' if phase == :diesel}#{revenue}"

          {
            text: text,
            width: text.size * 13,
            color: phase == :diesel ? :gray : phase,
          }
        end

        # Compute total width of rectangles so we can center
        total_width = computed_revenues.sum do |revenue|
          revenue['width']
        end

        children = computed_revenues.flat_map.with_index do |rev, index|
          fill = COLOR[rev['color']]
          width = rev['width']
          t_x = (26 * index) - (total_width * 0.5)

          rect_attrs = {
            fill: fill,
            transform: "translate(#{t_x} 0)",
            height: 24,
            width: width,
            x: 0,
            y: -12,
          }

          text_attrs = {
            transform: "translate(#{t_x + (width * 0.5)} -1)",
            fill: 'black',
            'text-anchor': 'middle',
            'dominant-baseline': 'central',
            'font-size': 20,
          }

          [
            h(:rect, attrs: rect_attrs),
            h(:text, { attrs: text_attrs }, rev['text']),
          ]
        end

        h(:g, { attrs: { transform: @transform } }, children)
      end
    end
  end
end
