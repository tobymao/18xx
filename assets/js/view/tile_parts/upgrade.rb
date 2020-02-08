# frozen_string_literal: true

require 'snabberb/component'

module View
  module TileParts
    class Upgrade < Snabberb::Component
      needs :cost
      needs :terrains, default: []

      def render
        terrain = @terrains.map.with_index do |t, index|
          {
            mountain: mountain(delta_y: 5 + (20 * index)),
            water: water(delta_y: 5 + (20 * index)),
          }[t]
        end

        h(
          :g,
          { attrs: { 'stroke-width': 1, transform: 'translate(30 -60)' } },
          [
            h(:text, { attrs: { fill: 'black', transform: 'scale(1.5)' } }, @cost),
          ] + terrain
        )
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
