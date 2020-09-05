# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :last_node, :phase, :train, :routes

    def initialize(game, phase, train, connection_hexes: [], routes: [], override: nil)
      @connections = []
      @phase = phase
      @train = train
      @last_node = nil
      @last_connection = nil
      @routes = routes
      @override = override
      @game = game
      @stops = nil
      restore_connections(connection_hexes) if connection_hexes
    end

    def reset!
      @connections.clear
      @last_node = nil
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
      connections = select(node, other)
      index = connections.find_index(connection) || connections.size
      connections[index + 1]
    end

    def select(node, other)
      other_paths = @routes.reject { |r| r == self }.flat_map(&:paths)
      nodes = [node, other]

      node.hex.all_connections.select do |c|
        (c.nodes & nodes).size == 2 &&
          !@connections.include?(c) &&
          (c.paths & other_paths).empty?
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
      @routes.flat_map(&:paths).group_by(&:itself).each do |k, v|
        @game.game_error("Route cannot use same path twice #{k.inspect}") if v.size > 1
      end
    end

    def check_connected!(token)
      paths_ = paths.uniq

      # rubocop:disable Style/GuardClause, Style/IfUnlessModifier
      if token.select(paths_, corporation: corporation).size != paths_.size
        @game.game_error('Route is not connected')
      end
      # rubocop:enable Style/GuardClause, Style/IfUnlessModifier
    end

    def distance
      visited_stops.sum(&:visit_cost)
    end

    def check_distance!(visits)
      distance = @train.distance
      if distance.is_a?(Numeric)
        route_distance = visits.sum(&:visit_cost)
        @game.game_error("#{route_distance} is too many stops for #{distance} train") if distance < route_distance

        return
      end

      type_info = Hash.new { |h, k| h[k] = [] }

      distance.each do |h|
        pay = h['pay']
        visit = h['visit'] || pay
        info = { pay: pay, visit: visit }
        h['nodes'].each { |type| type_info[type] << info }
      end

      grouped = visits.group_by(&:type)

      grouped.each do |type, group|
        num = group.sum(&:visit_cost)

        type_info[type].sort_by(&:size).each do |info|
          next unless info[:visit].positive?

          info[:visit] -= num
          num = info[:visit] * -1
          break unless num.positive?
        end

        @game.game_error('Route has too many stops') if num.positive?
      end
    end

    def revenue
      return @override[:revenue] if @override

      visited = visited_stops
      @game.game_error('Route must have at least 2 stops') if @connections.any? && visited.size < 2
      unless (token = visited.find { |stop| stop.tokened_by?(corporation) })
        @game.game_error('Route must contain token')
      end

      check_distance!(visited)
      check_cycles!
      check_overlap!
      check_connected!(token)

      visited.flat_map(&:groups).flatten.group_by(&:itself).each do |key, group|
        @game.game_error("Cannot use group #{key} more than once") unless group.one?
      end

      @game.revenue_for(self, stops)
    end

    def corporation
      train.owner
    end

    def connection_hexes
      connections.map(&:id)
    end

    def find_connections(connections_a, connections_b)
      connections_a.each do |a|
        connections_b.each do |b|
          middle = (a.nodes & b.nodes)
          next if middle.empty?

          left = (a.nodes - middle)[0]
          right = (b.nodes - middle)[0]
          return [a, b, left, right, middle[0]]
        end
      end

      []
    end

    private

    def restore_connections(connection_hexes)
      possibilities = connection_hexes.map do |hexes|
        hex_ids = hexes.map(&:id)
        hexes[0].all_connections.select { |c| c.complete? && c.matches?(hex_ids) }
      end

      if possibilities.one?
        connection = possibilities[0].find do |conn|
          conn.nodes.any? { |node| node.tokened_by?(corporation) }
        end
        left, right = connection&.nodes
        return if !left || !right

        @connections << { left: left, right: right, connection: connection }
      else
        possibilities.each_cons(2).with_index do |pair, index|
          a, b, left, right, middle = find_connections(*pair)
          return @connections.clear if !left&.hex || !right&.hex || !middle&.hex

          @connections << { left: left, right: middle, connection: a } if index.zero?
          @connections << { left: middle, right: right, connection: b }
        end
      end
    end

    def compute_stops
      visits = visited_stops
      distance = @train.distance
      return visits if distance.is_a?(Numeric)
      return [] if visits.empty?

      # distance is an array of hashes defining how many locations of
      # each type can be hit. A 2+2 train (4 locations, at most 2 of
      # which can be cities) looks like this:
      #   [ { nodes: [ 'town' ],                     pay: 2},
      #     { nodes: [ 'city', 'town', 'offboard' ], pay: 2} ]
      # Stops use the first available slot, so for each stop in this case
      # we'll try to put it in a town slot if possible and then
      # in a city/town/offboard slot.
      distance = distance.sort_by { |types, _| types.size }

      max_num_stops = [distance.sum { |h| h['pay'] }, visits.size].min

      max_num_stops.downto(1) do |num_stops|
        # to_i to work around Opal bug
        stops, revenue = visits.combination(num_stops.to_i).map do |stops|
          # Make sure this set of stops is legal
          # 1) At least one stop must have a token
          next if stops.none? { |stop| stop.tokened_by?(corporation) }

          # 2) We can't ask for more revenue centers of a type than are allowed
          types_used = Array.new(distance.size, 0) # how many slots of each row are filled

          next unless stops.all? do |stop|
            row = distance.index.with_index do |h, i|
              h['nodes'].include?(stop.type) && types_used[i] < h['pay']
            end

            types_used[row] += 1 if row
            row
          end

          [stops, @game.revenue_for(self, stops)]
        end.compact.max_by(&:last)

        # We assume that no stop collection with m < n stops could be
        # better than a stop collection with n stops, so if we found
        # anything usable with this number of stops we return it
        # immediately.
        return stops if revenue.positive?
      end

      []
    end
  end
end
