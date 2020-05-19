# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :last_hex, :phase, :train

    def initialize(phase, train, connection_hexes: [], routes: [], override: nil)
      @connections = []
      @phase = phase
      @train = train
      @last_hex = nil
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

      if connections.size == 1
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
      @last_hex = nil
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

    def next_connection(node, connection, hex)
      connections = select(node, hex)
      index = connections.find_index(connection) || connections.size
      connections[index + 1]
    end

    def select(node, hex)
      other_paths = @routes.reject { |r| r == self }.flat_map(&:paths)

      node.hex.all_connections.select do |c|
        c.complete? &&
          !@connections.include?(c) &&
          c.hexes.include?(hex) &&
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

    def touch_hex(hex)
      if @connections.any?
        head_c = head[:connection]
        tail_c = tail[:connection]

        if head_c.hexes.include?(hex)
          if (connection = next_connection(head[:right], head_c, hex))
            @connections[0] = segment(connection, right: head[:right])
          else
            @connections.shift
          end
        elsif tail_c.hexes.include?(hex)
          if (connection = next_connection(tail[:left], tail_c, hex))
            @connections[-1] = segment(connection, left: tail[:left])
          else
            @connections.pop
          end
        elsif (connection = select(head[:left], hex)[0])
          @connections.unshift(segment(connection, right: head[:left]))
        elsif (connection = select(tail[:right], hex)[0])
          @connections << segment(connection, left: tail[:right])
        end
      elsif @last_hex == hex
        @last_hex = nil
      elsif @last_hex
        if (connection = select(@last_hex.tile.nodes[0], hex)[0])
          a, b = connection.nodes
          a, b = b, a if @last_hex == a.hex
          @connections << { left: a, right: b, connection: connection }
        end
      else
        @last_hex = hex
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

    def check_connected!
      return unless (connection = connections[0])

      connected = connection.select(connections, corporation: corporation)
      unconnected = connections - connected
      raise GameError, 'Route is not connected' if unconnected.any?
    end

    def revenue
      return @override[:revenue] if @override

      stops_ = stops
      raise GameError, 'Route must have at least 2 stops' if @connections.any? && stops_.size < 2
      raise GameError, "#{stops_.size} is too many stops for #{@train.distance} train" if @train.distance < stops_.size
      raise GameError, 'Route must contain token' if stops.any? && stops_.none? { |s| s.tokened_by?(corporation) }

      check_cycles!
      check_overlap!
      check_connected!

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end

    def corporation
      train.owner
    end
  end
end
