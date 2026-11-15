# frozen_string_literal: true

require 'lib/settings'
require 'view/game/hex'
require 'view/game/part/track'

module View
  module Game
    class SeaRoutes < Snabberb::Component
      include Lib::Settings

      needs :routes
      needs :start_pos, default: [1, 1]

      def render
        segment_indexes = Hash.new { |hash, key| hash[key] = [] }
        @routes.each_with_index do |route, index|
          (route.chains || []).each do |chain|
            crossing = chain[:crossing]
            next unless crossing

            segments(crossing).each { |segment| segment_indexes[segment] << index }
          end
        end

        children = []
        @routes.each_index do |index|
          segment_indexes.each do |(from, to), indexes|
            indexes = indexes.uniq.sort
            children << line(from, to, index, indexes) if indexes.include?(index)
          end
        end

        h(:g, { attrs: { id: 'sea-routes', 'pointer-events': 'none' } }, children)
      end

      private

      def line(from, to, index, indexes)
        x1, y1 = Hex.coordinates(from, @start_pos)
        x2, y2 = Hex.coordinates(to, @start_pos)

        h(:line, {
            attrs: {
              x1: x1,
              y1: y1,
              x2: x2,
              y2: y2,
              stroke: route_prop(index, :color),
              'stroke-width': width_for(index, indexes),
              'stroke-dasharray': '18 12',
              'stroke-linecap': 'round',
            },
          })
      end

      def width_for(index, indexes)
        base = route_prop(index, :width).to_f
        return base if indexes.one?

        [base, Part::Track::MULTI_PATH[:broad][:width]].min * [1, 3 * indexes.reverse.index(index)].max
      end

      def segments(crossing)
        hexes = [crossing.nodes[0].hex, *crossing.hexes, crossing.nodes[1].hex]
        hexes = hexes.each_with_index.map { |hex, i| hex if i.zero? || hex != hexes[i - 1] }.compact
        hexes.each_cons(2).map { |a, b| a.id <= b.id ? [a, b] : [b, a] }
      end
    end
  end
end
