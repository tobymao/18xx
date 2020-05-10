# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :connections, :phase, :train

    def initialize(phase, train, hexes = [])
      @connections = []
      @start = nil
      @phase = phase
      @train = train
      init_from_hexes(hexes)
    end

    def init_from_hexes(hexes)
      slice = []
      nodes = 0

      hexes.uniq.each do |hex|
        slice << hex
        nodes += 1 if hex.tile.nodes.any?
        puts slice if train.id == '4-1'

        if nodes > 1
          connections = slice[0].all_connections.select do |connection|
            puts "** conection #{connection.inspect}" if train.id == '4-1'
            (connection.hexes & slice).size == slice.size
          end
          puts connections if train.id == '4-1'

          # raise if connections.size != 1
          @connections << connections[0] if connections.any?
          slice = [hex]
          nodes = 1
        end
      end
    end

    def reset!
      @connections.clear
      @start = nil
    end

    def touch_hex(hex)
      if @connections.any?
        if (connection = @connections[0].connections.find { |c| c.include?(hex) })
          @connections.insert(0, connection)
        end

        if (connection = @connections[-1].connections.find { |c| c.include?(hex) })
          @connections << connection
        end
      elsif @start
        puts "ALL CONN #{@start.all_connections}"

        connection = @start.all_connections.find { |c|
          puts "** add hex #{hex} -- #{c.hexes}"
          c.include?(hex)
        }
        puts "connection #{connection}"
        @connections << connection if connection
      else
        @start = hex
        puts "start #{hex.inspect}"
      end
      puts @connections.inspect
    end

    def paths_for(paths)
      @connections.flat_map(&:paths) & paths
    end

    def stops
      @connections.flat_map(&:nodes).uniq
    end

    def hexes
      @connections.flat_map(&:hexes).uniq
    end

    def revenue
      stops_ = stops
      raise GameError, 'Route must have at least 2 stops' if stops_.size < 2
      raise GameError, "#{stops_.size} is too many stops for #{@train.distance} train" if @train.distance < stops_.size

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end
  end
end
