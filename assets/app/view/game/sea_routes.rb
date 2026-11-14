# frozen_string_literal: true

require 'lib/settings'
require 'view/game/hex'

module View
  module Game
    class SeaRoutes < Snabberb::Component
      include Lib::Settings

      needs :routes
      needs :start_pos, default: [1, 1]

      def render
        children = []
        @routes.each_with_index do |route, index|
          (route.chains || []).each do |chain|
            crossing = chain[:crossing]
            children.concat(crossing_children(crossing, index)) if crossing
          end
        end

        h(:g, { attrs: { id: 'sea-routes', 'pointer-events': 'none' } }, children)
      end

      private

      def crossing_children(crossing, index)
        color = route_prop(index, :color)
        marker_a, marker_b = crossing.hexes.map { |hex| Hex.coordinates(hex, @start_pos) }

        [
          h(:polyline, {
              attrs: {
                points: points(crossing),
                fill: 'none',
                stroke: color,
                'stroke-width': route_prop(index, :width),
                'stroke-dasharray': '18 12',
                'stroke-linecap': 'round',
                'stroke-linejoin': 'round',
              },
            }),
          h(:text, {
              attrs: {
                x: (marker_a[0] + marker_b[0]) / 2.0,
                y: (marker_a[1] + marker_b[1]) / 2.0,
                'text-anchor': 'middle',
                'dominant-baseline': 'central',
                'font-size': 36,
                fill: color,
              },
            }, crossing.units.to_s),
        ]
      end

      def points(crossing)
        hexes = [crossing.nodes[0].hex, *crossing.hexes, crossing.nodes[1].hex]
        hexes = hexes.each_with_index.map { |hex, i| hex if i.zero? || hex != hexes[i - 1] }.compact
        hexes.map { |hex| Hex.coordinates(hex, @start_pos).join(',') }.join(' ')
      end
    end
  end
end
