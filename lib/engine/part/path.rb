# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :city, :edges, :exit_lanes, :junction,
                  :lanes, :nodes, :offboard, :stops, :terminal, :town, :track

      LANES = [[1, 0].freeze, [1, 0].freeze].freeze
      MATCHES_BROAD = %i[broad dual].freeze
      MATCHES_NARROW = %i[narrow dual].freeze
      LANE_INDEX = 1
      LANE_WIDTH = 0

      def self.decode_lane_spec(x_lane)
        if x_lane
          [x_lane.to_i, ((x_lane.to_f - x_lane.to_i) * 10).to_i]
        else
          [1, 0]
        end
      end

      def self.make_lanes(a, b, terminal: nil, lanes: nil, a_lane: nil, b_lane: nil, track: nil)
        track ||= :broad
        if lanes
          lanes.times.map do |index|
            a_lanes = [lanes, index]
            b_lanes = if a.edge? && b.edge?
                        [lanes, lanes - index - 1]
                      else
                        a_lanes
                      end
            Path.new(a, b,
                     terminal: terminal,
                     lanes: [a_lanes, b_lanes],
                     track: track)
          end
        else
          Path.new(a, b,
                   terminal: terminal,
                   lanes: [decode_lane_spec(a_lane), decode_lane_spec(b_lane)],
                   track: track)
        end
      end

      def initialize(a, b, terminal: nil, lanes: LANES, track: :broad)
        @a = a
        @b = b
        @terminal = terminal
        @lanes = lanes
        @edges = []
        @stops = []
        @nodes = []
        @exit_lanes = {}
        @track = track

        separate_parts
      end

      def <=>(other)
        id <=> other.id
      end

      def <=(other)
        other_ends = other.ends
        ends.all? { |t| other_ends.any? { |o| t <= o } } && tracks_match?(other)
      end

      def tracks_match?(other_path, dual_ok: false)
        other_track = other_path.track
        case @track
        when :broad
          MATCHES_BROAD.include?(other_track)
        when :narrow
          MATCHES_NARROW.include?(other_track)
        when :dual
          dual_ok || other_track == :dual
        end
      end

      def ends
        @ends ||= [@a, @b].flat_map do |part|
          next part unless part.junction?

          part.paths.flat_map do |path|
            next [] if path == self

            [path.a, path.b].reject(&:junction?)
          end
        end
      end

      def select(paths)
        on = paths.map { |p| [p, 0] }.to_h

        walk(on: on) do |path|
          on[path] = 1 if on[path]
        end

        on.keys.select { |p| on[p] == 1 }
      end

      #
      #
      #
      # on and chain are mutually exclusive
      # skip: An exit to ignore. Useful to prevent ping-ponging between adjacent hexes.
      # jskip: An junction to ignore. May be useful on complex tiles
      # visited: a hashset of visited Paths. Used to avoid repeating track segments.
      # visited_edges: See Node.walk
      # on: A set of Paths mapping to 1 or 0. When `on` is set. Usage is currently limited to `select` in path & node
      # chain: an array of the previously visited Paths to get to this point
      #  * If `chain` is set `walk` will yield to a block, providing the chain (including this part), and will
      #      'bubble up' yields from recursive calls
      #  * If `chain` is nil `walk` will yield to a block, providing this Part and the visited Paths including this one

      # on: HashSet of Paths that we want to *exclusively* walk on
      def walk(skip: nil, jskip: nil, visited: nil, visited_edges: {}, on: nil, chain: nil)
        return if visited&.[](self)

        visited = visited&.dup || {}
        visited[self] = true

        if chain
          chained = chain + [self]
          yield chained if chain.empty? ? @nodes.size == 2 : @nodes.any?
        else
          yield self, visited, visited_edges
        end

        if @junction && @junction != jskip
          @junction.paths.each do |jp|
            next if on && !on[jp]

            if chain
              jp.walk(jskip: @junction, visited: visited, visited_edges: visited_edges, chain: chained) do |c|
                yield c
              end
            else
              jp.walk(jskip: @junction, visited: visited, visited_edges: visited_edges, on: on) do |p, v, ve|
                yield p, v, ve
              end
            end
          end
        end

        exits.each do |edge|
          next if edge == skip
          next if visited_edges[[hex, edge, @exit_lanes[edge]]]
          next unless (neighbor = hex.neighbors[edge])

          np_edge = hex.invert(edge)

          neighbor.paths[np_edge].each do |np|
            next if on && !on[np]
            next unless lane_match?(@exit_lanes[edge], np.exit_lanes[np_edge])
            next unless tracks_match?(np, dual_ok: true)
            next if visited_edges[[neighbor, np_edge, np.exit_lanes[np_edge]]]

            # We only need to store one side of the edge so let's keep the 'source'
            neighbors_edges = visited_edges.merge({ [hex, edge, @exit_lanes[edge]] => 1 })
            if chain
              np.walk(skip: np_edge, visited: visited, visited_edges: neighbors_edges, chain: chained) do |c|
                yield c
              end
            else
              np.walk(skip: np_edge, visited: visited, visited_edges: neighbors_edges, on: on) do |p, v, ve|
                yield p, v, ve
              end
            end
          end
        end
      end

      # return true if facing exits on adjacent tiles match up taking lanes into account
      # TBD: support titles where lanes of different sizes can connect
      def lane_match?(lanes0, lanes1)
        lanes0 && lanes1 &&
            lanes1[LANE_WIDTH] == lanes0[LANE_WIDTH] && lanes1[LANE_INDEX] == lane_invert(lanes0)[LANE_INDEX]
      end

      def lane_invert(lane)
        [lane[LANE_WIDTH], lane[LANE_WIDTH] - lane[LANE_INDEX] - 1]
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

        @_single = @lanes.first[LANE_WIDTH] == 1 && @lanes.last[LANE_WIDTH] == 1
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
        path = Path.new(@a.rotate(ticks), @b.rotate(ticks),
                        terminal: @terminal,
                        lanes: @lanes,
                        track: @track)
        path.index = index
        path.tile = @tile
        path
      end

      def inspect
        name = self.class.name.split('::').last
        if single?
          "<#{name}: hex: #{hex&.name}, exit: #{exits}, track: #{track}>"
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
            @stops << part
            @nodes << part
          when part.junction?
            @junction = part
          when part.town?
            @town = part
            @stops << part
            @nodes << part
          end
          part.lanes = @lanes[part == @a ? 0 : 1]
        end
      end
    end
  end
end
