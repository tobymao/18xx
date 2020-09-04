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
      @log = game.log
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

      if visits.empty?
        @stops = []
        return
      end

      # We never have to deal with the "visit" field of the
      # trainbecause that was already taken care of while calculating
      # the route.

      # types_pay lists how many locations of each type can be hit. A
      # 2+2 train (4 locations, at most 2 of which can be cities) looks
      # like this:
      #  [[["town"],                     2],
      #   [["city", "town", "offboard"], 2]]
      # Stops use the first available slot, so for each stop in this case
      # we'll try to put it in a town slot if possible and then
      # in a city/town/offboard slot.
      types_pay = distance.map { |h| [h['nodes'], h['pay']] }.sort_by { |t, _| t.size }

      best_stops = []
      best_revenue = 0
      max_num_stops = [distance.sum{|h| h['pay']}, visits.size].min
      # puts "max_num_stops for #{@train.name} is #{max_num_stops}"
      # puts "visits is #{visits.map{|s| s.hex.name}}"
      max_num_stops.downto(1) do |num_stops|
        # puts "Trying #{num_stops} stops #{num_stops.class}"
        visits.combination(num_stops.to_i).each do |stops|
          # puts "Trying #{stops.map{|s| s.hex.name}}"

          # Make sure this set of stops is legal

          # 1) At least stop must have a token
          if stops.none? { |stop| stop.tokened_by?(corporation) }
            # puts "No token"
            next
          end

          # 2) We can't ask for more revenue centers of a type than are allowed
          ok = true
          types_used = Array.new(types_pay.size, 0) # how many slots of each row are filled
          stops.each do |stop|
            stop_registered = false
            types_pay.each_with_index do |pair, i|
              if pair[0].include?(stop.type)
                if types_used[i] < pair[1]
                  types_used[i] += 1
                  stop_registered = true # we found a place to put this stop
                  break
                end
              end
            end
            if !stop_registered
              ok = false
              break
            end
          end
          if !ok
            # puts "Not enough resources"
            next
          end

          revenue = @game.revenue_for(self, stops)
          # puts "#{num_stops} stops: got #{revenue} for #{stops.map{|s| s.hex.name}}"
          if revenue > best_revenue
            best_stops = stops
            best_revenue = revenue 
          end
        end

        # We assume that no stop collection with m < n stops could be
        # better than a stop collection with n stops.
        break if best_revenue > 0
      end
      # puts "new code found #{best_revenue} with #{best_stops.map{|s| s.hex.name}}"

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

      # all the stops we could possibly add
      options_by_type = (visits - included).group_by(&:type)
      # hash of type to stops that have already been included
      included_by_type = included.group_by(&:type)

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
      # puts "old code found #{@game.revenue_for(self, @stops)} with #{@stops.map{|s| s.hex.name}}"
      revenue = @game.revenue_for(self, @stops)
      if best_revenue != revenue
        @log << "Undercounted revenue, should be #{best_revenue} for #{best_stops.map{|s| s.hex.name}}, was #{revenue} for #{@stops.map{|s| s.hex.name}}"
        puts "best route was #{best_revenue} with #{best_stops.map{|s| s.hex.name}}"
        puts "old code gave revenue #{revenue} with #{@stops.map{|s| s.hex.name}}"
      end
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
