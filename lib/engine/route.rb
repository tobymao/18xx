# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :last_hex, :phase, :train

    def initialize(phase, train, connection_hexes: [], routes: [])
      @connections = []
      @phase = phase
      @train = train
      @last_hex = nil
      @last_connection = nil
      @routes = routes
      init_from_connection_hexes(connection_hexes)
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

    def add_connection(connection, side, replace = false)
      return side == :head ? @connections.shift : @connections.pop unless connection

      raise GameError if @connections.include?(connection)
      raise GameError if connection.nodes.size != 2
      raise GameError if !replace && paths_for(connection.paths).any?

      if @connections.empty?
        hex_a, hex_b = connection.nodes.map(&:hex)
        hex_a, hex_b = hex_b, hex_a if hex_a == @last_hex
        @connections << { left: hex_a, right: hex_b, connection: connection }
      else
        hexes = connection.nodes.map(&:hex)
        left = head[:left]
        right = tail[:right]

        if hexes.include?(left)
          a, b = hexes
          a, b = b, a if a == left
          new = { left: a, right: b, connection: connection }
          replace ? @connections[0] = new : @connections.unshift(new)
        elsif hexes.include?(right)
          a, b = hexes
          a, b = b, a if b == right
          new = { left: a, right: b, connection: connection }
          replace ? @connections[-1] = new : @connections << new
        end
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
        replace = @connections.size == 1

        if head_c.hexes.include?(hex)
          add_connection(next_connection(head[:right], head_c, hex), :head, replace)
        elsif tail_c.hexes.include?(hex)
          add_connection(next_connection(tail[:left], tail_c, hex), :tail, replace)
        elsif (connection = select(head[:left], hex)[0])
          add_connection(connection, :head)
        elsif (connection = select(tail[:right], hex)[0])
          add_connection(connection, :tail)
        end
      elsif @last_hex
        add_connection(select(@last_hex, hex)[0])
      end

      @last_hex = hex
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
      @connections.flat_map { |c| [c[:left], c[:right]] }.uniq
    end

    def revenue
      stops_ = stops
      raise GameError, 'Route must have at least 2 stops' if @connections.any? && stops_.size < 2
      raise GameError, "#{stops_.size} is too many stops for #{@train.distance} train" if @train.distance < stops_.size

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end
  end
end
