# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_accessor :halts
    attr_reader :last_node, :phase, :train, :routes, :abilities

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

      @connection_data = nil
      @last_node = nil
      @stops = nil
    end

    def clear_cache!
      @connection_hexes = nil
      @hexes = nil
      @revenue = nil
      @revenue_str = nil
      @subsidy = nil
      @stops = nil
    end

    def reset!
      clear_cache!

      @halts = nil
      @connection_data = nil
      @last_node = nil
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

    def connections
      connection_data&.map { |c| c[:connection] }
    end

    def next_connection(node, connection, other)
      connections = select(node, other, connection)
      index = connections.find_index(connection) || connections.size
      connections[index + 1]
    end

    def select(node, other, keep = nil)
      other_paths = @game.compute_other_paths(@routes, self)

      connection_data.each do |c|
        next if c[:connection] == keep

        other_paths.concat(c[:connection].paths)
      end

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
      if connection_data.any?
        case node
        when head[:left]
          if (connection = next_connection(head[:right], head[:connection], node))
            connection_data[0] = segment(connection, right: head[:right])
          else
            connection_data.shift
          end
        when tail[:right]
          if (connection = next_connection(tail[:left], tail[:connection], node))
            connection_data[-1] = segment(connection, left: tail[:left])
          else
            connection_data.pop
          end
        when head[:right]
          connection_data.shift
        when tail[:left]
          connection_data.pop
        else
          if (connection = select(head[:left], node)[0])
            connection_data.unshift(segment(connection, right: head[:left]))
          elsif (connection = select(tail[:right], node)[0])
            connection_data << segment(connection, left: tail[:right])
          end
        end
      elsif @last_node == node
        @last_node = nil
      elsif @last_node
        if (connection = select(@last_node, node)[0])
          a, b = connection.nodes
          a, b = b, a if @last_node == a
          connection_data << { left: a, right: b, connection: connection }
        end
      else
        @last_node = node
      end

      @routes.each(&:clear_cache!)
    end

    def paths
      connections.flat_map(&:paths)
    end

    def paths_for(other_paths)
      paths & other_paths
    end

    def visited_stops
      connection_data.flat_map { |c| [c[:left], c[:right]] }.uniq
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
      @game.check_connected(self, token)
    end

    def ordered_paths
      connection_data.flat_map do |c|
        cpaths = c[:connection].paths
        cpaths[0].nodes.include?(c[:left]) ? cpaths : cpaths.reverse
      end
    end

    def check_terminals!
      return if paths.size < 3

      raise GameError, 'Route cannot pass through terminal' if ordered_paths[1..-2].any?(&:terminal?)
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

    def revenue
      @revenue ||=
        begin
          visited = visited_stops
          raise GameError, 'Route must have at least 2 stops' if connection_data.any? && visited.size < 2
          unless (token = visited.find { |stop| @game.city_tokened_by?(stop, corporation) })
            raise GameError, 'Route must contain token'
          end

          check_distance!(visited)
          check_cycles!
          check_overlap!
          check_terminals!
          check_connected!(token)
          check_other!

          visited.flat_map(&:groups).flatten.group_by(&:itself).each do |key, group|
            raise GameError, "Cannot use group #{key} more than once" unless group.one?
          end

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
      @connection_hexes ||= connections&.map(&:id)
    end

    private

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

    def connection_data
      return @connection_data if @connection_data

      @connection_data = []
      return @connection_data unless @connection_hexes

      possibilities = @connection_hexes.map do |hex_ids|
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
        return @connection_data if !left || !right

        @connection_data << { left: left, right: right, connection: connection }
      else
        possibilities.each_cons(2).with_index do |pair, index|
          a, b, left, right, middle = find_connections(*pair, other_paths)
          return @connection_data.clear if !left&.hex || !right&.hex || !middle&.hex

          @connection_data << { left: left, right: middle, connection: a } if index.zero?
          @connection_data << { left: middle, right: right, connection: b }

          other_paths.concat(a.paths)
        end
      end

      @connection_data
    end
  end
end
