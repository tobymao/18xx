# frozen_string_literal: true

require 'lib/settings'
require 'view/game/hex'
require 'view/game/part/city'
require 'view/game/part/track'

module View
  module Game
    class SeaRoutes < Snabberb::Component
      include Lib::Settings

      needs :routes
      needs :start_pos, default: [1, 1]

      def render
        segment_indexes = Hash.new { |hash, key| hash[key] = [] }
        @route_nodes = {}
        @routes.each_with_index do |route, index|
          (route.chains || []).each do |chain|
            crossing = chain[:crossing]
            next unless crossing

            crossing.nodes.each { |node| @route_nodes[node.hex] = node }
            segments(crossing).each { |segment| segment_indexes[segment] << index }
          end
        end

        children = []
        @routes.each_index do |index|
          segment_indexes.each do |(from, to), indexes|
            indexes = indexes.uniq.sort
            child = line(from, to, index, indexes) if indexes.include?(index)
            children << child if child
          end
        end

        h(:g, { attrs: { id: 'sea-routes', 'pointer-events': 'none' } }, children)
      end

      private

      def line(from, to, index, indexes)
        width = width_for(index, indexes)
        x1, y1 = Hex.coordinates(from, @start_pos)
        x2, y2 = Hex.coordinates(to, @start_pos)
        start = trimmed([x1, y1], [x2, y2], from, width)
        finish = trimmed([x2, y2], [x1, y1], to, width)
        return if start.nil? || finish.nil?

        x1, y1 = start
        x2, y2 = finish

        h(:line, {
            attrs: {
              x1: x1,
              y1: y1,
              x2: x2,
              y2: y2,
              stroke: route_prop(index, :color),
              'stroke-width': width,
              'stroke-dasharray': '18 12',
              'stroke-linecap': 'round',
            },
          })
      end

      def trimmed(point, other, hex, width)
        node = @route_nodes[hex]
        return point unless node

        dx = other[0] - point[0]
        dy = other[1] - point[1]
        length = Math.sqrt((dx * dx) + (dy * dy))
        pull = clearance(node) + (width / 2.0)
        return if length <= pull

        [(point[0] + (dx * pull / length)).round(2), (point[1] + (dy * pull / length)).round(2)]
      end

      def clearance(node)
        node.city? && node.slots(all: true) > 1 ? Part::City::SLOT_DIAMETER : Part::City::SLOT_RADIUS
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
