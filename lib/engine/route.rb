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

      connections.each_cons(2) do |a, b|
        middle = (a.nodes & b.nodes)
        left = (a.nodes - middle)[0].hex
        right = (b.nodes - middle)[0].hex
        middle = middle[0].hex
        @connections << { left: left, right: middle, connection: a } if a == connections[0]
        @connections << { left: middle, right: right, connection: b }
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

    def segment(connection, left: nil, right: nil)
      hexes = connection.nodes.map(&:hex)

      if left
        right = (hexes - [left])[0]
      else
        left = (hexes - [right])[0]
      end

      { left: left, right: right, connection: connection }
    end

    def add_connection(connection, node)
      if @connections.empty?
        return unless connection

        hex_a, hex_b = connection.nodes.map(&:hex)
        return @connections << { left: hex_a, right: hex_b, connection: connection }
      end
      # raise GameError if @connections.include?(connection)
      # raise GameError if conection && connection.nodes.size != 2
      # raise GameError if !replace && paths_for(connection.paths).any?

      case node
      when (hr = head[:right])
        return @connections.shift unless connection

        @connections[0] = segment(connection, right: hr)
      when (hl = head[:left])
        @connections.unshift(segment(connection, right: hl))
      when (tl = tail[:left])
        return @connections.pop unless connection

        @connections[-1] = segment(connection, left: tl)
      when (tr = tail[:right])
        @connections << segment(connection, left: tr)
      else
        # if connections.empty?
      end
    end

    def next_connection(node, connection, hex)
      connections = select(node, hex)
      index = connections.find_index(connection) || connections.size
      connections[index + 1]
    end

    def select(node, hex)
      other_paths = @routes.reject { |r| r == self }.flat_map(&:paths)

      node.all_connections.select do |c|
        c.complete? &&
          !@connections.include?(c) &&
          c.hexes.include?(hex) &&
          (c.paths & other_paths).empty?
      end
    end

    def touch_hex(hex)
      if @connections.any?
        head_c = head[:connection]
        tail_c = tail[:connection]
        solo = connections.size == 1

        if head_c.hexes.include?(hex)
          puts "head #{head[:right].name}"
          add_connection(next_connection(head[:right], head_c, hex), head[:right])
        elsif tail_c.hexes.include?(hex)
          puts "tail #{tail[:left].name}"
          add_connection(next_connection(tail[:left], tail_c, hex), tail[:left])
        elsif (connection = select(head[:left], hex)[0])
          puts "head connection"
          add_connection(connection, head[:left])
        elsif (connection = select(tail[:right], hex)[0])
          puts "tail connection"
          add_connection(connection, tail[:right])
        end
      elsif @last_hex == hex
        @last_hex = nil
      elsif @last_hex
        add_connection(select(@last_hex, hex)[0])
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

      @connections.flat_map { |c| [c[:left], c[:right]] }.uniq
    end

    def revenue
      return @override[:revenue] if @override

      stops_ = stops
      raise GameError, 'Route must have at least 2 stops' if @connections.any? && stops_.size < 2
      raise GameError, "#{stops_.size} is too many stops for #{@train.distance} train" if @train.distance < stops_.size

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end
  end
end
