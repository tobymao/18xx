# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_accessor :halts
    attr_reader :last_node, :phase, :train, :routes

    def initialize(game, phase, train, connection_hexes: [], routes: [], override: nil, halts: nil)
      @connections = []
      @phase = phase
      @train = train
      @last_node = nil
      @last_connection = nil
      @routes = routes
      @override = override
      @game = game
      @stops = nil
      @halts = halts
      restore_connections(connection_hexes) if connection_hexes
    end

    def reset!
      @connections.clear
      @last_node = nil
      @stops = nil
      @halts = nil
    end

    def cycle_halts
      return unless @halts

      @halts += 1
      @halts = 0 if @halts > @game.max_halts(self)
      @stops = nil
    end

    def head
      @connections[0]
    end

    def tail
      @connections[-1]
    end

    def connections
      @connections.map { |c| c[:connection] }
    end

    def next_connection(node, connection, other)
      connections = select(node, other, connection)
      index = connections.find_index(connection) || connections.size
      connections[index + 1]
    end

    def select(node, other, keep = nil)
      other_paths = @game.compute_other_paths(@routes, self)
      other_paths.concat(@connections.reject { |c| c[:connection] == keep }
                          .flat_map { |c| c[:connection].paths })
      nodes = [node, other]

      node.hex.all_connections.select do |c|
        (c.nodes & nodes).size == 2 && (c.paths & other_paths).empty?
      end
    end

    def segment(connection, left: nil, right: nil)
      nodes = connection.nodes

      if left
        right = (nodes - [left])[0]
      else
        left = (nodes - [right])[0]
      end

      { left: left, right: right, connection: connection }
    end

    def touch_node(node)
      if @connections.any?
        case node
        when head[:left]
          if (connection = next_connection(head[:right], head[:connection], node))
            @connections[0] = segment(connection, right: head[:right])
          else
            @connections.shift
          end
        when tail[:right]
          if (connection = next_connection(tail[:left], tail[:connection], node))
            @connections[-1] = segment(connection, left: tail[:left])
          else
            @connections.pop
          end
        when head[:right]
          @connections.shift
        when tail[:left]
          @connections.pop
        else
          if (connection = select(head[:left], node)[0])
            @connections.unshift(segment(connection, right: head[:left]))
          elsif (connection = select(tail[:right], node)[0])
            @connections << segment(connection, left: tail[:right])
          end
        end
      elsif @last_node == node
        @last_node = nil
      elsif @last_node
        if (connection = select(@last_node, node)[0])
          a, b = connection.nodes
          a, b = b, a if @last_node == a
          @connections << { left: a, right: b, connection: connection }
        end
      else
        @last_node = node
      end
      @stops = nil
    end

    def paths
      connections.flat_map(&:paths)
    end

    def paths_for(other_paths)
      paths & other_paths
    end

    def visited_stops
      @connections.flat_map { |c| [c[:left], c[:right]] }.uniq
    end

    def stops
      @stops ||= compute_stops
    end

    def hexes
      return @override[:hexes] if @override

      # find unique node hexes
      @connections
        .flat_map { |c| [c[:left], c[:right]] }
        .chunk(&:itself)
        .to_a # opal has a bug that needs this conversion from enum
        .map(&:first)
        .map(&:hex)
    end

    def all_hexes
      # All hexes, including those not considered stops (1817 mines)
      paths.map(&:hex).uniq
    end

    def check_cycles!
      cycles = {}

      @connections.each do |c|
        right = c[:right]
        cycles[c[:left]] = true
        @game.game_error("Cannot use #{right.hex.name} twice") if cycles[right]

        cycles[right] = true
      end
    end

    def check_overlap!
      @game.check_overlap(@routes)
    end

    def check_connected!(token)
      @game.check_connected(self, token)
    end

    def ordered_paths
      @connections.flat_map do |c|
        cpaths = c[:connection].paths
        cpaths[0].nodes.include?(c[:left]) ? cpaths : cpaths.reverse
      end
    end

    def check_terminals!
      return if paths.size < 3

      @game.game_error('Route cannot pass through terminal') if ordered_paths[1..-2].any?(&:terminal?)
    end

    def distance
      @game.route_distance(self)
    end

    def check_distance!(visits)
      @game.check_distance(self, visits)
    end

    def check_other!
      @game.check_other(self)
    end

    def lock!
      @revenue = revenue
    end

    def revenue
      return @revenue if @revenue
      return @override[:revenue] if @override

      visited = visited_stops
      @game.game_error('Route must have at least 2 stops') if @connections.any? && visited.size < 2
      unless (token = visited.find { |stop| @game.city_tokened_by?(stop, corporation) })
        @game.game_error('Route must contain token')
      end

      check_distance!(visited)
      check_cycles!
      check_overlap!
      check_terminals!
      check_connected!(token)
      check_other!

      visited.flat_map(&:groups).flatten.group_by(&:itself).each do |key, group|
        @game.game_error("Cannot use group #{key} more than once") unless group.one?
      end

      @game.revenue_for(self, stops)
    end

    def subsidy
      @game.subsidy_for(self, stops)
    end

    def corporation
      @game.train_owner(train)
    end

    def connection_hexes
      connections.map(&:id)
    end

    def find_connections(connections_a, connections_b, other_paths)
      connections_a = connections_a.select { |a| (a.paths & other_paths).empty? }
      connections_b = connections_b.select { |b| (b.paths & other_paths).empty? }
      connections_a.each do |a|
        connections_b.each do |b|
          next if (middle = (a.nodes & b.nodes)).empty?
          next if (b.paths & a.paths).any?

          left = (a.nodes - middle)[0]
          right = (b.nodes - middle)[0]
          return [a, b, left, right, middle[0]]
        end
      end

      []
    end

    private

    def restore_connections(connection_hexes)
      possibilities = connection_hexes.map do |hex_ids|
        hexes = hex_ids.map { |hex_str| @game.hex_by_id(hex_str.split.first) }
        hexes[0].all_connections.select { |c| c.matches?(hex_ids) }
      end

      other_paths = @game.compute_other_paths(@routes, self)

      if possibilities.one?
        connection = possibilities[0].find do |conn|
          conn.nodes.any? { |node| @game.city_tokened_by?(node, corporation) } &&
            (conn.paths & other_paths).empty?
        end
        left, right = connection&.nodes
        return if !left || !right

        @connections << { left: left, right: right, connection: connection }
      else
        possibilities.each_cons(2).with_index do |pair, index|
          a, b, left, right, middle = find_connections(*pair, other_paths)
          return @connections.clear if !left&.hex || !right&.hex || !middle&.hex

          @connections << { left: left, right: middle, connection: a } if index.zero?
          @connections << { left: middle, right: right, connection: b }

          other_paths.concat(a.paths)
        end
      end
    end

    def compute_stops
      @game.compute_stops(self)
    end
  end
end
