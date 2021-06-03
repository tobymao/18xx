# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_accessor :halts, :routes
    attr_reader :last_node, :phase, :train, :abilities

    def initialize(game, phase, train, **opts)
      @game = game
      @phase = phase
      @train = train

      @routes = opts[:routes] || []
      @connection_hexes = opts[:connection_hexes]
      @hexes = opts[:hexes]
      @revenue = opts[:revenue]
      @revenue_str = opts[:revenue_str]
      @subsidy = opts[:subsidy]
      @halts = opts[:halts]
      @abilities = opts[:abilities]

      @node_chains = {}
      @connection_data = opts[:connection_data]
      @last_node = nil
      @last_offboard = []
      @stops = nil
    end

    def clear_cache!(all: false)
      @connection_hexes = nil if all
      @hexes = nil
      @revenue = nil
      @revenue_str = nil
      @subsidy = nil
      @stops = nil
    end

    def reset!
      clear_cache!(all: true)

      @halts = nil
      @connection_data = nil
      @last_node = nil
      @last_offboard = []
    end

    def cycle_halts
      return unless @halts

      @halts += 1
      @halts = 0 if @halts > @game.max_halts(self)
      clear_cache!
    end

    def head
      connection_data[0]
    end

    def tail
      connection_data[-1]
    end

    def chains
      connection_data&.map { |c| c[:chain] }
    end

    def next_chain(node, chain, other)
      chains = select(node, other, chain)
      index = chains.find_index(chain) || chains.size
      chains[index + 1]
    end

    def select(node, other, keep = nil)
      other_paths = @game.compute_other_paths(@routes, self)

      connection_data.each do |c|
        next if c[:chain] == keep

        other_paths.concat(c[:chain][:paths])
      end

      get_node_chains(node, other).select { |c| (c[:paths] & other_paths).empty? }
    end

    # walk paths from start_node, and only keep connections that end at end_node
    def get_node_chains(start_node, end_node)
      @node_chains[[start_node, end_node]] ||=
        begin
          new_chains = []
          start_node.paths.each do |start_path|
            start_path.walk do |current, visited|
              next unless current.nodes.include?(end_node)

              paths = visited.keys
              new_chains << {
                nodes: [start_node, end_node],
                paths: paths,
                hexes: paths.map(&:hex),
                id: chain_id(paths),
              }
            end
          end

          new_chains
        end
    end

    def segment(chain, left: nil, right: nil)
      nodes = chain[:nodes]

      if left
        right = (nodes - [left])[0]
      else
        left = (nodes - [right])[0]
      end

      { left: left, right: right, chain: chain }
    end

    def touch_node(node)
      if connection_data.any?
        case node
        when head[:left]
          if (chain = next_chain(head[:right], head[:chain], node))
            connection_data[0] = segment(chain, right: head[:right])
          else
            connection_data.shift
          end
        when tail[:right]
          if (chain = next_chain(tail[:left], tail[:chain], node))
            connection_data[-1] = segment(chain, left: tail[:left])
          else
            connection_data.pop
          end
        when head[:right]
          connection_data.shift
        when tail[:left]
          connection_data.pop
        else
          if (chain = select(head[:left], node)[0])
            connection_data.unshift(segment(chain, right: head[:left]))
          elsif (chain = select(tail[:right], node)[0])
            connection_data << segment(chain, left: tail[:right])
          end
        end
        connection_data.pop if @train.local? && connection_data.size == 2
      elsif @last_node == node
        @last_node = nil
        connection_data.clear
      elsif @last_node
        connection_data.clear
        if (chain = select(@last_node, node)[0])
          a, b = chain[:nodes]
          a, b = b, a if @last_node == a
          connection_data << { left: a, right: b, chain: chain }
        end
      else
        @last_node = node
        add_single_node_connection(node) if @train.local? && @connection_data.empty?
      end

      @halts = nil
      @routes.each { |r| r.clear_cache!(all: true) }
    end

    # hex with multiple offboards was clicked - determine which one to
    # connect to the route
    #
    # we pick the one next to the first/last node in connected_data
    # If both nodes could connect, cycle through them
    def disambiguate_node(nodes)
      onodes = nodes.select(&:offboard?)

      # find first and last nodes in current route
      list = connection_data.empty? ? [@last_node].compact : [head[:left], tail[:right]]
      return if list.empty?

      # if those match either of the nodes in the tile, use it and remember it
      if (match = onodes.find { |n| list.include?(n) })
        touch_node(match)
        @last_offboard = [match]
        return
      end

      # otherwise use a node on the tile that connects to the current route
      # if multiple, ignore the most recently used one
      candidates = onodes.select { |node| list.any? { |last| select(last, node)[0] } }
      if candidates.size > 1
        touch_node((candidates - @last_offboard)[0])
        @last_offboard = []
      elsif candidates.one?
        touch_node(candidates[0])
        @last_offboard = []
      end
    end

    def paths
      chains.flat_map { |ch| ch[:paths] }
    end

    def paths_for(other_paths)
      paths & other_paths
    end

    def visited_stops
      @visited_stops ||= connection_data.flat_map { |c| [c[:left], c[:right]] }.uniq
    end

    def stops
      @stops ||= @game.compute_stops(self)
    end

    def hexes
      return @hexes if @hexes

      # find unique node hexes
      connection_data
        .flat_map { |c| [c[:left], c[:right]] }
        .chunk(&:itself)
        .to_a # opal has a bug that needs this conversion from enum
        .map(&:first)
        .map(&:hex)
        .compact
    end

    def all_hexes
      # All hexes, including those not considered stops (1817 mines)
      paths.map(&:hex).uniq
    end

    def check_cycles!
      return if @train.local?

      cycles = {}

      connection_data.each do |c|
        right = c[:right]
        cycles[c[:left]] = true
        raise GameError, "Cannot use #{right.hex.name} twice" if cycles[right]

        cycles[right] = true
      end
    end

    def check_overlap!
      @game.check_overlap(@routes)
    end

    def check_connected!(token)
      @check_connected ||= @game.check_connected(self, token) || true
    end

    def ordered_paths
      connection_data.flat_map do |c|
        cpaths = c[:chain][:paths]
        cpaths[0].nodes.include?(c[:left]) ? cpaths : cpaths.reverse
      end
    end

    def check_terminals!
      return if paths.size < 3

      raise GameError, 'Route cannot pass through terminal' if ordered_paths[1..-2].any?(&:terminal?)
    end

    def distance_str
      @game.route_distance_str(self)
    end

    def distance
      @distance ||= @game.route_distance(self)
    end

    def check_distance!(visits)
      @check_distance ||= @game.check_distance(self, visits) || true
    end

    def check_other!
      @game.check_other(self)
    end

    def revenue
      @revenue ||=
        begin
          visited = visited_stops
          if !connection_data.empty? && visited.size < 2 && !@train.local?
            raise GameError, 'Route must have at least 2 stops'
          end
          unless (token = visited.find { |stop| @game.city_tokened_by?(stop, corporation) })
            raise GameError, 'Route must contain token'
          end

          visited.flat_map(&:groups).flatten.group_by(&:itself).each do |key, group|
            raise GameError, "Cannot use group #{key} more than once" unless group.one?
          end

          check_terminals!
          check_other!
          check_cycles!
          check_distance!(visited)
          check_overlap!
          check_connected!(token)

          @game.revenue_for(self, stops)
        end
    end

    def subsidy
      return nil unless @game.respond_to?(:subsidy_for)

      @subsidy ||= @game.subsidy_for(self, stops)
    end

    def revenue_str
      @revenue_str ||= @game.revenue_str(self)
    end

    def corporation
      @game.train_owner(train)
    end

    def connection_hexes
      @connection_hexes ||= if @train.local? && connection_data.one? && connection_data[0][:chain][:paths].empty?
                              [['local', connection_data[0][:left].hex.id]]
                            else
                              chains&.map { |ch| ch[:id] }
                            end
    end

    private

    def chain_id(paths)
      # deal with ambiguous intra-tile path
      if paths.one? && paths[0].tile.ambiguous_connection?
        node0, node1 = paths[0].nodes.map(&:index).sort
        ["#{paths[0].hex.id} #{node0}.#{node1}"]
      else
        junction_map = {}
        hex_ids = []

        # skip over paths that have a junction we've already seen
        paths.each do |path|
          hex_ids << path.hex.id if !junction_map[path.a] && !junction_map[path.b]
          junction_map[path.a] = true if path.a.junction?
          junction_map[path.b] = true if path.b.junction?
        end

        hex_ids
      end
    end

    def add_single_node_connection(node)
      @connection_data << { left: node, right: node, chain: { nodes: nil, paths: [], hexes: nil, id: nil } }
    end

    def find_pairwise_chain(chains_a, chains_b, other_paths)
      chains_a = chains_a.select { |a| (a[:paths] & other_paths).empty? }
      chains_b = chains_b.select { |b| (b[:paths] & other_paths).empty? }
      chains_a.each do |a|
        chains_b.each do |b|
          next if (middle = (a[:nodes] & b[:nodes])).empty?
          next unless (b[:paths] & a[:paths]).empty?

          left = (a[:nodes] - middle)[0]
          right = (b[:nodes] - middle)[0]
          return [a, b, left, right, middle[0]]
        end
      end

      []
    end

    def find_matching_chains(hex_ids)
      start_hex = @game.hex_by_id(hex_ids.first.split.first)
      end_hex = @game.hex_by_id(hex_ids.last.split.first)
      matching = []
      start_hex.tile.nodes.each do |start_node|
        end_hex.tile.nodes.each do |end_node|
          next if start_node == end_node

          get_node_chains(start_node, end_node).each do |ch|
            matching << ch if ch[:id] == hex_ids
          end
        end
      end
      matching
    end

    def connection_data
      return @connection_data if @connection_data

      @connection_data = []
      return @connection_data unless @connection_hexes

      if @connection_hexes.one? && @connection_hexes[0].include?('local')
        if @train.local?
          city_node = @game.hex_by_id(@connection_hexes[0][1]).tile.nodes.find do |n|
            @game.city_tokened_by?(n, corporation)
          end
          return add_single_node_connection(city_node)
        else
          @connection_hexes.clear
        end
      end

      possibilities = @connection_hexes.map do |hex_ids|
        find_matching_chains(hex_ids)
      end

      other_paths = @game.compute_other_paths(@routes, self)

      if possibilities.one?
        chain = possibilities[0].find do |ch|
          ch[:nodes].any? { |node| @game.city_tokened_by?(node, corporation) } && (ch[:paths] & other_paths).empty?
        end
        return @connection_data unless chain

        left, right = chain[:nodes]
        return @connection_data if !left || !right

        @connection_data << { left: left, right: right, chain: chain }
      else
        possibilities.each_cons(2).with_index do |pair, index|
          a, b, left, right, middle = find_pairwise_chain(*pair, other_paths)
          return @connection_data.clear if !left&.hex || !right&.hex || !middle&.hex

          @connection_data << { left: left, right: middle, chain: a } if index.zero?
          @connection_data << { left: middle, right: right, chain: b }

          other_paths.concat(a[:paths])
        end
      end

      @connection_data
    end
  end
end
