# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :branches, :city, :edges, :exit_lanes, :junction,
                  :lanes, :nodes, :offboard, :stops, :terminal, :town

      def self.decode_lane_spec(x_lane)
        if x_lane
          [x_lane.to_i, ((x_lane.to_f - x_lane.to_i) * 10).to_i]
        else
          [1, 0]
        end
      end

      def self.make_lanes(a, b, terminal: nil, lanes: nil, a_lane: nil, b_lane: nil)
        if lanes
          lanes.times.map do |index|
            a_lanes = [lanes, index]
            b_lanes = if a.edge? && b.edge?
                        [lanes, lanes - index - 1]
                      else
                        a_lanes
                      end
            Path.new(a, b, terminal, [a_lanes, b_lanes])
          end
        else
          Path.new(a, b, terminal, [decode_lane_spec(a_lane), decode_lane_spec(b_lane)])
        end
      end

      def initialize(a, b, terminal = nil, lanes = [[1, 0], [1, 0]])
        @a = a
        @b = b
        @terminal = terminal
        @lanes = lanes
        @edges = []
        @branches = []
        @stops = []
        @nodes = []
        @exit_lanes = {}

        separate_parts
      end

      def <=>(other)
        id <=> other.id
      end

      def <=(other)
        (@a <= other.a && @b <= other.b) ||
          (@a <= other.b && @b <= other.a)
      end

      def select(paths)
        on = paths.map { |p| [p, 0] }.to_h

        walk(on: on) do |path|
          on[path] = 1 if on[path]
        end

        on.keys.select { |p| on[p] == 1 }
      end

      def walk(skip: nil, visited: nil, on: nil)
        return if visited&.[](self)

        visited = visited&.dup || {}
        visited[self] = true
        yield self, visited

        exits.each do |edge|
          next if edge == skip
          next unless (neighbor = hex.neighbors[edge])

          np_edge = hex.invert(edge)

          neighbor.paths[np_edge].each do |np|
            next if on && !on[np]
            next unless lane_match?(@exit_lanes[edge], np.exit_lanes[np_edge])

            np.walk(skip: np_edge, visited: visited, on: on) { |p, v| yield p, v }
          end
        end
      end

      # return true if facing exits on adjacent tiles match up taking lanes into account
      # TBD: support titles where lanes of different sizes can connect
      def lane_match?(lanes0, lanes1)
        lanes0 && lanes1 && lanes1[0] == lanes0[0] && lanes1[1] == (lanes0[0] - lanes0[1] - 1)
      end

      def path?
        true
      end

      def node?
        return @_node if defined?(@_node)

        @_node = @nodes.any?
      end

      def terminal?
        !!@terminal
      end

      def single?
        return @_single if defined?(@_single)

        @_single = @lanes.first[0] == 1 && @lanes.last[0] == 1
      end

      def exits
        @exits ||= @edges.map(&:num)
      end

      def node_edge
        return nil unless @nodes.one?

        @node_edge ||= @tile.preferred_city_town_edges[@nodes.first]
      end

      # like a.num except it works when a is a town/city next to an edge
      def a_num
        @a_num ||= @a.edge? ? @a.num : node_edge
      end

      # like b.num except it works when b is a town/city next to an edge
      def b_num
        @b_num ||= @b.edge? ? @b.num : node_edge
      end

      def straight?
        return @_straight if defined?(@_straight)

        @_straight = a_num && b_num && (a_num - b_num).abs == 3
      end

      def gentle_curve?
        return @_gentle_curve if defined?(@_gentle_curve)

        @_gentle_curve = a_num && b_num && (((d = (a_num - b_num).abs) == 2) || d == 4 || d == 2.5 || d == 3.5)
      end

      def rotate(ticks)
        path = Path.new(@a.rotate(ticks), @b.rotate(ticks), @terminal, @lanes)
        path.index = index
        path.tile = @tile
        path
      end

      def inspect
        name = self.class.name.split('::').last
        if single?
          "<#{name}: hex: #{hex&.name}, exit: #{exits}>"
        else
          "<#{name}: hex: #{hex&.name}, exit: #{exits}, lanes: #{@lanes.first} #{@lanes.last}>"
        end
      end

      private

      def separate_parts
        [@a, @b].each do |part|
          case
          when part.edge?
            @edges << part
            @exit_lanes[part.num] = @lanes[part == @a ? 0 : 1]
          when part.offboard?
            @offboard = part
            @stops << part
            @nodes << part
          when part.city?
            @city = part
            @branches << part
            @stops << part
            @nodes << part
          when part.junction?
            @junction = part
            @branches << part
            @nodes << part
          when part.town?
            @town = part
            @branches << part
            @stops << part
            @nodes << part
          end
        end
      end
    end
  end
end
