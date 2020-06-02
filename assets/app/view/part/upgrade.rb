# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class Upgrade < Base
      needs :cost
      needs :terrains, default: []

      P_CENTER = {
        region_weights: CENTER,
        x: 0,
        y: 0,
      }.freeze

      P_TOP_RIGHT_CORNER = {
        region_weights: [3, 4],
        x: 30,
        y: -60,
      }.freeze

      P_BOTTOM_LEFT_CORNER = {
        region_weights: [19, 20],
        x: -30,
        y: 60,
      }.freeze

      P_EDGE2 = {
        region_weights: [0, 5, 6],
        x: -50,
        y: -45,
      }.freeze

      def preferred_render_locations
        [
          P_CENTER,
          P_TOP_RIGHT_CORNER,
          P_EDGE2,
          P_BOTTOM_LEFT_CORNER,
        ]
      end

      def render_part
        text_attrs = {
          'text-anchor': 'middle',
          fill: 'black',
          transform: 'scale(1.5)',
        }
        cost = h(:text, { attrs: text_attrs }, @cost)

        delta_x = -10

        terrain = @terrains.map.with_index do |t, index|
          {
            mountain: mountain(delta_x: delta_x, delta_y: 5 + (20 * index)),
            water: water(delta_x: delta_x, delta_y: 5 + (20 * index)),
          }[t]
        end

        children = [cost] + terrain

        attrs = {
          class: 'upgrade',
          'stroke-width': 1,
          transform: "#{translate} #{rotation_for_layout}",
        }

        h(:g, { attrs: attrs }, children)
      end

      def mountain(delta_x: 0, delta_y: 0)
        h(:polygon, attrs: { transform: "translate(#{delta_x} #{delta_y})",
                             points: '0,20 10,0 20,20' })
      end

      def water(delta_x: 0, delta_y: 0)
        h(:g, { attrs: { transform: "translate(#{10 + delta_x} #{12 + delta_y}) scale(0.7)" } }, [
            h(:path, attrs: {
                d: 'M -15 -7 Q -7.5 -15, 0 -7 S 7.5 1, 15 -7M -15 -2  Q -7.5 -10, 0 -2  S 7.5 6, 15 -2',
                fill: 'none',
                stroke: 'white',
                'stroke-width': '2',
                'stroke-linecap': 'round',
                'stroke-linejoin': 'round',
              }),
            h(:path,  attrs: {
                d: 'M -15 -7 Q -7.5 -15, 0 -7 S 7.5 1, 15 -7M -15 -2  Q -7.5 -10, 0 -2  S 7.5 6, 15 -2',
                fill: 'none',
                stroke: '#147ebe',
                'stroke-width': '2',
                'stroke-linecap': 'round',
                'stroke-linejoin': 'round',
              }),
          ])
      end
    end
  end
end
