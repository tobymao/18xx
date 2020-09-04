# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :last_node, :phase, :train, :routes, :stops

    def initialize(game, phase, train, connection_hexes: [], routes: [], override: nil)
      @connections = []
      @phase = phase
      @train = train
      @last_node = nil
      @last_connection = nil
      @routes = routes
      @override = override
      @game = game
      @stops = []
      restore_connections(connection_hexes) if connection_hexes
      update_stops
    end

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
      update_stops
    end

    def reset!
      @connections.clear
      @last_node = nil
      update_stops
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
      update_stops
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

    def update_stops
      visits = visited_stops
      distance = @train.distance
      if distance.is_a?(Numeric)
        @stops = visits
        return
      end

      z = [1, 2, 3, 4, 5, 6, 7]
      puts "z test = #{z.combination(7).to_a}"
      puts "All visits = #{visits.combination(visits.size).to_a}"

      best_stops = []
      best_revenue = 0
      max_num_stops = [distance.sum{|h| h['pay']}, visits.size].min
      puts "max_num_stops for #{@train.name} is #{max_num_stops}"
      puts "visits is #{visits.map{|s| s.hex.name}}"
      max_num_stops.downto(1) do |num_stops|
        puts "Trying #{num_stops} stops"
        puts "Possibilities are #{visits.combination(num_stops).to_a}"
        visits.combination(num_stops).each do |stops|
          # TODO: make sure this set of stops is legal
          revenue = @game.revenue_for(self, stops)
          puts "#{num_stops} stops: got #{revenue} for #{stops.map{|s| s.hex.name}}"
          if revenue > best_revenue
            best_stops = stops
            best_revenue = revenue 
          end
        end
        break if best_revenue > 0
      end
      puts "smart code found #{best_revenue} with #{best_stops.map{|s| s.hex.name}}"

      ### Original code below

      # always include the ends of a route because the user explicitly asked for it
      included = [visits[0], visits[-1]]

      # find the maximal token if not already in the end points
      if included.none? { |stop| stop.tokened_by?(corporation) }
        token = visits
          .select { |stop| stop.tokened_by?(corporation) }
          .max_by { |stop| stop.route_revenue(@phase, @train) }
        included << token if token
      end

      # "type" below is city / offboard / town / etc.

      # all the stops we could possibly add
      options_by_type = (visits - included).group_by(&:type)
      # hash of type to stops that have already been included
      included_by_type = included.group_by(&:type)

      # e.g. [(["city", "offboard"], 4), ["town"], 99]
      # We never have to deal with the "visit" field because that was
      # already taken care of while calculating the route
      types_pay = distance.map { |h| [h['nodes'], h['pay']] }.sort_by { |t, _| t.size }

      @stops = included + types_pay.flat_map do |types, pay|
        # e.g, types = ["city", "offboard"], pay = 4
        # The number we can take of these is reduced by the number we've already taken
        pay -= types.sum { |type| included_by_type[type]&.size || 0 }

        # For each type
        node_revenue = types.flat_map do |type|
          # nodes are all the nodes of this type we could add
          next [] unless (nodes = options_by_type[type])

          # For each, output [node, revenue from node]
          nodes.map { |node| [node, node.route_revenue(@phase, @train)] }
        end.sort_by(&:last).last(pay)
        # Then we sort all of those by revenue and take the top 'pay'

        # Now for each of those we remove them from further consideration
        node_revenue.each { |node, _| options_by_type[node.type].delete(node) }
        # And then return the nodes themselves.
        node_revenue.map(&:first)
      end
      puts "dumb code found #{@game.revenue_for(self, @stops)} with #{@stops.map{|s| s.hex.name}}"
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

      @game.revenue_for(self, @stops)
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
  end
end
