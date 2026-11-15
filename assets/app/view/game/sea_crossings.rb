# frozen_string_literal: true

require 'lib/settings'
require 'view/game/hex'
require 'view/game/part/city'

module View
  module Game
    class SeaCrossings < Snabberb::Component
      include Lib::Settings

      LANE_SPACING = 1.5
      MITER_LIMIT = 2

      needs :game, store: true
      needs :routes
      needs :start_pos, default: [1, 1]

      def render
        @route_nodes = {}
        raw = []
        @routes.each_with_index do |route, index|
          (route.chains || []).each do |chain|
            crossing = chain[:crossing]
            next unless crossing

            crossing.nodes.each { |node| @route_nodes[node.hex] = node }
            raw << [index, crossing]
          end
        end
        step_routes = step_route_indexes(raw)
        crossings = raw.map { |index, crossing| [index, crossing_hexes(crossing, step_routes)] }
        index_legs(crossings)

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
        x1, y1 = Hex.coordinates(@leg_travel[key][0], @start_pos)
        x2, y2 = Hex.coordinates(@leg_travel[key][1], @start_pos)
        dx = x2 - x1
        dy = y2 - y1
        length = Math.sqrt((dx * dx) + (dy * dy))
        [-dy / length * shift, dx / length * shift]
      end

      def index_legs(crossings)
        segment_indexes = Hash.new { |hash, key| hash[key] = [] }
        lead = {}
        @leg_travel = {}
        crossings.each do |index, hexes|
          hexes.each_cons(2) do |a, b|
            key = leg_key(a, b)
            segment_indexes[key] << index
            next if lead[key] && lead[key] <= index

            lead[key] = index
            @leg_travel[key] = [a, b]
          end
        end
        @segment_indexes = segment_indexes.transform_values { |indexes| indexes.uniq.sort }
      end

      def step_route_indexes(raw)
        steps = Hash.new { |hash, key| hash[key] = [] }
        raw.each do |index, crossing|
          crossing_path(crossing).each_cons(2) { |a, b| steps[leg_key(a, b)] << index }
        end
        steps.transform_values { |indexes| indexes.uniq.sort }
      end

      def crossing_hexes(crossing, step_routes)
        joined = sea_pieces(crossing_path(crossing), step_routes).each_with_index.flat_map do |piece, i|
          straight = Path.for(@game).straighten(piece, crossing)
          i.zero? ? straight : straight.drop(1)
        end
        hexes = [crossing.nodes[0].hex, *joined, crossing.nodes[1].hex]
        hexes.each_with_index.map { |hex, i| hex if i.zero? || hex != hexes[i - 1] }.compact
      end

      def crossing_path(crossing)
        Path.for(@game).path(*crossing.hexes, crossing)
      end

      def sea_pieces(path, step_routes)
        cuts = (1...path.size - 1).reject do |i|
          step_routes[leg_key(path[i - 1], path[i])] == step_routes[leg_key(path[i], path[i + 1])]
        end
        bounds = [0, *cuts, path.size - 1]
        bounds.each_cons(2).map { |from, to| path[from..to] }
      end

      def leg_key(a, b)
        a.id <= b.id ? [a, b] : [b, a]
      end

      class Path
        CLEARANCE = 3
        COAST_COST = 2

        @instances = {}

        def self.for(game)
          @instances[game] ||= new(game.hexes)
        end

        def initialize(hexes)
          @hexes = hexes
          @paths = {}
          @straightened = {}
        end

        def path(from_hex, to_hex, crossing)
          forward = (from_hex.id <=> to_hex.id) <= 0
          first, last = forward ? [from_hex, to_hex] : [to_hex, from_hex]
          found = (@paths[[first.id, last.id]] ||= cheapest_path(first, last, crossing))
          forward ? found : found.reverse
        end

        def straighten(hexes, crossing)
          forward = (hexes.first.id <=> hexes.last.id) <= 0
          canonical = forward ? hexes : hexes.reverse
          straight = (@straightened[canonical.map(&:id)] ||= straighten_path(canonical, crossing))
          forward ? straight : straight.reverse
        end

        private

        def land_distance(hex, crossing)
          @land_distance ||= begin
            distance = {}
            land = @hexes.reject { |h| crossing.sea_hex?(h) }
            edge = @hexes.select { |h| crossing.sea_hex?(h) && h.all_neighbors.size < 6 }
            land.each { |h| distance[h] = 0 }
            edge.each { |h| distance[h] = 1 }
            queue = land + edge
            until queue.empty?
              current = queue.shift
              current.all_neighbors.each_value do |neighbor|
                next if distance.key?(neighbor)

                distance[neighbor] = distance[current] + 1
                queue << neighbor
              end
            end
            distance
          end
          @land_distance[hex] || @hexes.size
        end

        def step_cost(hex, crossing)
          return crossing.channel_passage_cost unless crossing.sea_hex?(hex)

          shortfall = [self.class::CLEARANCE - land_distance(hex, crossing), 0].max
          1 + (self.class::COAST_COST * shortfall)
        end

        def cheapest_path(from_hex, to_hex, crossing)
          costs = { from_hex => 0 }
          previous = {}
          frontier = [from_hex]
          done = {}
          until frontier.empty?
            current = frontier.min_by.with_index { |hex, index| [costs[hex], index] }
            frontier.delete(current)
            next if done[current]

            done[current] = true
            break if current == to_hex

            current.all_neighbors.each_value do |neighbor|
              cost = costs[current] + step_cost(neighbor, crossing)
              next if costs[neighbor] && costs[neighbor] <= cost

              costs[neighbor] = cost
              previous[neighbor] = current
              frontier << neighbor
            end
          end
          found = [to_hex]
          found.unshift(previous[found.first]) while previous[found.first]
          found
        end

        def straighten_path(path, crossing)
          allowed = path.to_h { |hex| [hex, true] }
          result = [path.first]
          index = 0
          while index < path.size - 1
            jump = (path.size - 1).downto(index + 1).find do |candidate|
              line = line_hexes(path[index], path[candidate])
              next unless line.all? { |hex| hex && (crossing.sea_hex?(hex) || allowed[hex]) }

              line.map { |hex| land_distance(hex, crossing) }.min >=
                path[index..candidate].map { |hex| land_distance(hex, crossing) }.min
            end
            index = jump || (index + 1)
            result << path[index]
          end
          result
        end

        def line_hexes(from_hex, to_hex)
          dq = grid_q(to_hex) - grid_q(from_hex)
          dr = to_hex.y - from_hex.y
          steps = ((dq.abs + dr.abs + (dq + dr).abs) / 2.0).round
          return [from_hex] if steps.zero?

          (0..steps).map do |k|
            t = k / steps.to_f
            hex_at_cube(grid_q(from_hex) + (dq * t) + 1e-6, from_hex.y + (dr * t) + 1e-6)
          end
        end

        def grid_parity
          @grid_parity ||= (@hexes.first.x - @hexes.first.y) % 2
        end

        def grid_q(hex)
          (hex.x - hex.y - grid_parity) / 2.0
        end

        def hex_by_grid
          @hex_by_grid ||= @hexes.to_h { |hex| [[hex.x, hex.y], hex] }
        end

        def hex_at_cube(q, r)
          s = -q - r
          rq = q.round
          rr = r.round
          rs = s.round
          dq = (rq - q).abs
          dr = (rr - r).abs
          ds = (rs - s).abs
          if dq > dr && dq > ds
            rq = -rr - rs
          elsif dr > ds
            rr = -rq - rs
          end
          hex_by_grid[[(2 * rq) + rr + grid_parity, rr]]
        end
      end
    end
  end
end
