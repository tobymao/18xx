# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :city, :edges, :exit_lanes, :junction,
                  :lanes, :nodes, :offboard, :stops, :terminal, :town, :track, :ignore

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

      def self.make_lanes(a, b, terminal: nil, lanes: nil, a_lane: nil, b_lane: nil, track: nil, ignore: nil)
        track ||= :broad
        if lanes
          Array.new(lanes) do |index|
            a_lanes = [lanes, index]
            b_lanes = if a.edge? && b.edge?
                        [lanes, lanes - index - 1]
                      else
                        a_lanes
                      end
            Path.new(a, b,
                     terminal: terminal,
                     lanes: [a_lanes, b_lanes],
                     track: track,
                     ignore: ignore)
          end
        else
          Path.new(a, b,
                   terminal: terminal,
                   lanes: [decode_lane_spec(a_lane), decode_lane_spec(b_lane)],
                   track: track,
                   ignore: ignore)
        end
      end

      def initialize(a, b, terminal: nil, lanes: LANES, track: :broad, ignore: nil)
        @a = a
        @b = b
        @terminal = terminal
        @lanes = lanes
        @edges = []
        @stops = []
        @nodes = []
        @exit_lanes = {}
        @track = track
        @ignore = ignore

        separate_parts
      end

      def ignore_gauge_compare
        @@ignore_gauge_compare ||= nil
      end

      def self.ignore_gauge_compare=(var)
        @@ignore_gauge_compare = var
      end

      def ignore_gauge_walk
        @@ignore_gauge_walk ||= nil
      end

      def self.ignore_gauge_walk=(var)
        @@ignore_gauge_walk = var
      end

      def <=>(other)
        id <=> other.id
      end

      def <=(other)
        other_ends = other.ends
        ends.all? { |t| other_ends.any? { |o| t <= o } } && (ignore_gauge_compare || tracks_match?(other))
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

      # skip: An exit to ignore. Useful to prevent ping-ponging between adjacent hexes.
      # jskip: An junction to ignore. May be useful on complex tiles
      # visited: a hashset of visited Paths. Used to avoid repeating track segments.
      # counter: a hash tracking edges and junctions to avoid reuse
      # on: A set of Paths mapping to 1 or 0. When `on` is set. Usage is currently limited to `select` in path & node
      # skip_track: If passed, don't walk on track of that type (ie: :broad track for 1873)
      # tile_type: if :lawson don't undo visited paths
      def walk(
        skip: nil,
        jskip: nil,
        visited: {},
        skip_paths: nil,
        counter: Hash.new(0),
        on: nil,
        tile_type: :normal,
        skip_track: nil,
        &block
      )
        return if visited[self] || skip_paths&.key?(self)
        return if @junction && counter[@junction] > 1
        return if edges.sum { |edge| counter[edge.id] }.positive?
        return if track == skip_track

        visited[self] = true
        counter[@junction] += 1 if @junction

        yield self, visited, counter

        if @junction && @junction != jskip
          @junction.paths.each do |jp|
            next if on && !on[jp]

            jp.walk(jskip: @junction, visited: visited, counter: counter, on: on, tile_type: tile_type, &block)
          end
        end

        edges.each do |edge|
          edge_id = edge.id
          edge = edge.num
          next if edge == skip
          next unless (neighbor = hex.neighbors[edge])

          counter[edge_id] += 1
          np_edge = hex.invert(edge)

          neighbor.paths[np_edge].each do |np|
            next if on && !on[np]
            next unless lane_match?(@exit_lanes[edge], np.exit_lanes[np_edge])
            next if !ignore_gauge_walk && !tracks_match?(np, dual_ok: true)

            np.walk(skip: np_edge, visited: visited, counter: counter, on: on, skip_track: skip_track,
                    tile_type: tile_type, &block)
          end

          counter[edge_id] -= 1
        end

        visited.delete(self) unless tile_type == :lawson
        counter[@junction] -= 1 if @junction
      end

      # return true if facing exits on adjacent tiles match up taking lanes into account
      # TBD: support titles where lanes of different sizes can connect
      def lane_match?(lanes0, lanes1)
        lanes0 &&
          lanes1 &&
          lanes1[LANE_WIDTH] == lanes0[LANE_WIDTH] &&
          lanes1[LANE_INDEX] == lane_invert(lanes0)[LANE_INDEX]
      end

      def lane_invert(lane)
        [lane[LANE_WIDTH], lane[LANE_WIDTH] - lane[LANE_INDEX] - 1]
      end

      def path?
        true
      end

      def node?
        return @_node if defined?(@_node)

        @_node = !@nodes.empty?
      end

      def ignore?
        !!@ignore
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

        @_gentle_curve = a_num && b_num && [2, 2.5, 3.5, 4].include?((a_num - b_num).abs)
      end

      def rotate(ticks)
        path = Path.new(@a.rotate(ticks), @b.rotate(ticks),
                        terminal: @terminal,
                        lanes: @lanes,
                        track: @track,
                        ignore: @ignore)
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
          if part.edge?
            @edges << part
            @exit_lanes[part.num] = @lanes[part == @a ? 0 : 1]
          elsif part.offboard?
            @offboard = part
            @stops << part
            @nodes << part
          elsif part.city?
            @city = part
            @stops << part
            @nodes << part
          elsif part.junction?
            @junction = part
          elsif part.town?
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
