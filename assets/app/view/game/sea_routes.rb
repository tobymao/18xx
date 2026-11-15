# frozen_string_literal: true

require 'lib/settings'
require 'view/game/hex'
require 'view/game/part/city'

module View
  module Game
    class SeaRoutes < Snabberb::Component
      include Lib::Settings

      LANE_SPACING = 1.5
      MITER_LIMIT = 2

      needs :routes
      needs :start_pos, default: [1, 1]

      def render
        segment_indexes = Hash.new { |hash, key| hash[key] = [] }
        @route_nodes = {}
        crossings = []
        @routes.each_with_index do |route, index|
          (route.chains || []).each do |chain|
            crossing = chain[:crossing]
            next unless crossing

            crossing.nodes.each { |node| @route_nodes[node.hex] = node }
            hexes = crossing_hexes(crossing)
            hexes.each_cons(2) { |a, b| segment_indexes[leg_key(a, b)] << index }
            crossings << [index, hexes]
          end
        end
        @segment_indexes = segment_indexes.transform_values { |indexes| indexes.uniq.sort }

        children = crossings.map { |index, hexes| polyline(index, hexes) }.compact
        h(:g, { attrs: { id: 'sea-routes', 'pointer-events': 'none' } }, children)
      end

      private

      def polyline(index, hexes)
        width = route_prop(index, :width).to_f
        legs = hexes.each_cons(2).map { |a, b| leg(a, b, index) }
        joins = legs.each_cons(2).each_with_index.map { |(a, b), i| vertex(a, b, hexes[i + 1]) }
        points = [first_point(legs, hexes, width), *joins, last_point(legs, hexes, width)]
        return if points.first.nil? || points.last.nil?

        h(:polyline, {
            attrs: {
              points: points.map { |x, y| "#{x.round(2)},#{y.round(2)}" }.join(' '),
              fill: 'none',
              stroke: route_prop(index, :color),
              'stroke-width': width,
              'stroke-dasharray': '18 12',
              'stroke-linecap': 'round',
              'stroke-linejoin': 'round',
            },
          })
      end

      def leg(from, to, index)
        key = leg_key(from, to)
        indexes = @segment_indexes[key]
        x1, y1 = Hex.coordinates(from, @start_pos)
        x2, y2 = Hex.coordinates(to, @start_pos)
        length = Math.sqrt(((x2 - x1)**2) + ((y2 - y1)**2))
        {
          direction: [(x2 - x1) / length, (y2 - y1) / length],
          offset: lane_offset(key, index, indexes),
          spacing: leg_spacing(indexes),
        }
      end

      def first_point(legs, hexes, width)
        start = trimmed(Hex.coordinates(hexes[0], @start_pos), Hex.coordinates(hexes[1], @start_pos), hexes[0], width)
        start && [start[0] + legs.first[:offset][0], start[1] + legs.first[:offset][1]]
      end

      def last_point(legs, hexes, width)
        finish = trimmed(Hex.coordinates(hexes[-1], @start_pos), Hex.coordinates(hexes[-2], @start_pos), hexes[-1], width)
        finish && [finish[0] + legs.last[:offset][0], finish[1] + legs.last[:offset][1]]
      end

      def vertex(incoming, outgoing, hex)
        cx, cy = Hex.coordinates(hex, @start_pos)
        ox1, oy1 = incoming[:offset]
        ox2, oy2 = outgoing[:offset]
        average = [cx + ((ox1 + ox2) / 2.0), cy + ((oy1 + oy2) / 2.0)]
        dx1, dy1 = incoming[:direction]
        dx2, dy2 = outgoing[:direction]
        cross = (dx1 * dy2) - (dy1 * dx2)
        return average if cross.abs < 1e-6

        along = (((ox2 - ox1) * dy2) - ((oy2 - oy1) * dx2)) / cross
        x = cx + ox1 + (along * dx1)
        y = cy + oy1 + (along * dy1)
        limit = self.class::MITER_LIMIT * [incoming[:spacing], outgoing[:spacing]].max
        Math.sqrt(((x - cx)**2) + ((y - cy)**2)) > limit ? average : [x, y]
      end

      def trimmed(point, other, hex, width)
        node = @route_nodes[hex]
        return point unless node

        dx = other[0] - point[0]
        dy = other[1] - point[1]
        length = Math.sqrt((dx * dx) + (dy * dy))
        pull = clearance(node) + (width / 2.0)
        return if length <= pull

        [point[0] + (dx * pull / length), point[1] + (dy * pull / length)]
      end

      def clearance(node)
        node.city? && node.slots(all: true) > 1 ? Part::City::SLOT_DIAMETER : Part::City::SLOT_RADIUS
      end

      def leg_spacing(indexes)
        indexes.map { |i| route_prop(i, :width).to_f }.max * self.class::LANE_SPACING
      end

      def lane_offset(key, index, indexes)
        return [0, 0] if indexes.one?

        shift = (indexes.index(index) - ((indexes.size - 1) / 2.0)) * leg_spacing(indexes)
        x1, y1 = Hex.coordinates(key[0], @start_pos)
        x2, y2 = Hex.coordinates(key[1], @start_pos)
        dx = x2 - x1
        dy = y2 - y1
        length = Math.sqrt((dx * dx) + (dy * dy))
        [-dy / length * shift, dx / length * shift]
      end

      def leg_key(a, b)
        a.id <= b.id ? [a, b] : [b, a]
      end

      def crossing_hexes(crossing)
        hexes = [crossing.nodes[0].hex, *crossing.hexes, crossing.nodes[1].hex]
        hexes.each_with_index.map { |hex, i| hex if i.zero? || hex != hexes[i - 1] }.compact
      end
    end
  end
end
