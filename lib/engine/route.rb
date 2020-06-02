# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :last_node, :phase, :train

    def initialize(phase, train, connection_hexes: [], routes: [], override: nil)
      @connections = []
      @phase = phase
      @train = train
      @last_node = nil
      @last_connection = nil
      @routes = routes
      @override = override
      init_from_connection_hexes(connection_hexes) if connection_hexes
    end

    def init_from_connection_hexes(connection_hexes)
      connections = connection_hexes.map do |hexes|
        hexes.sort!
        hexes[0].all_connections.find { |c| c.complete? && c.hexes.sort == hexes }
      end

      return unless (first = connections[0])

      if connections.one?
        @connections << { left: first.nodes[0], right: first.nodes[-1], connection: first }
      else
        connections.each_cons(2) do |a, b|
          middle = (a.nodes & b.nodes)
          left = (a.nodes - middle)[0]
          right = (b.nodes - middle)[0]
          middle = middle[0]
          @connections << { left: left, right: middle, connection: a } if a == first
          @connections << { left: middle, right: right, connection: b }
        end
      end
    end

    def reset!
      @connections.clear
      @last_node = nil
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
    end

    def paths
      connections.flat_map(&:paths)
    end

    def paths_for(other_paths)
      paths & other_paths
    end

    def stops
      connections.flat_map(&:nodes).uniq
    end

    def hexes
      return @override[:hexes] if @override

      @connections.flat_map { |c| [c[:left].hex, c[:right].hex] }.uniq
    end

    def check_cycles!
      cycles = {}

      @connections.each do |c|
        right = c[:right]
        cycles[c[:left]] = true
        raise GameError, "Cannot use #{right.hex.name} twice" if cycles[right]

        cycles[right] = true
      end
    end

    def check_overlap!
      @routes.flat_map(&:paths).group_by(&:itself).each do |k, v|
        raise GameError, "Route cannot use same path twice #{k.inspect}" if v.size > 1
      end
    end

    def check_connected!(token)
      paths_ = paths.uniq

      # rubocop:disable Style/GuardClause, Style/IfUnlessModifier
      if token.select(paths_, corporation: corporation).size != paths_.size
        raise GameError, 'Route is not connected'
      end
      # rubocop:enable Style/GuardClause, Style/IfUnlessModifier
    end

    def revenue
      return @override[:revenue] if @override

      stops_ = stops
      raise GameError, 'Route must have at least 2 stops' if @connections.any? && stops_.size < 2
      raise GameError, "#{stops_.size} is too many stops for #{@train.distance} train" if @train.distance < stops_.size
      raise GameError, 'Route must contain token' unless (token = stops_.find { |stop| stop.tokened_by?(corporation) })

      check_cycles!
      check_overlap!
      check_connected!(token)

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end

    def corporation
      train.owner
    end

    def connection_hexes
      connections.map(&:id)
    end
  end
end
