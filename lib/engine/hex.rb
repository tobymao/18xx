# frozen_string_literal: true

require_relative 'connection'

module Engine
  class Hex
    attr_reader :coordinates, :layout, :neighbors, :paths, :tile, :x, :y, :location_name

    DIRECTIONS = {
      flat: {
        [0, 2] => 0,
        [-1, 1] => 1,
        [-1, -1] => 2,
        [0, -2] => 3,
        [1, -1] => 4,
        [1, 1] => 5,
      },
      pointy: {
        [1, 1] => 0,
        [-1, 1] => 1,
        [-2, 0] => 2,
        [-1, -1] => 3,
        [1, -1] => 4,
        [2, 0] => 5,
      },
    }.freeze

    LETTERS = ('A'..'Z').to_a

    def self.invert(dir)
      (dir + 3) % 6
    end

    # Coordinates are of the form A1..Z99
    # x and y map to the double coordinate system
    # layout is pointy or flat
    def initialize(coordinates, layout: :pointy, tile: Tile.for('blank'), location_name: nil)
      @coordinates = coordinates
      @layout = layout
      @x = LETTERS.index(@coordinates[0]).to_i
      @y = @coordinates[1..-1].to_i - 1
      @neighbors = {}
      @connections = Hash.new { |h, k| h[k] = [] }
      @location_name = location_name
      tile.location_name = location_name
      @tile = tile
      @tile.hex = self
    end

    def id
      @coordinates
    end

    def name
      @coordinates
    end

    def lay(tile)
      # when upgrading, preserve tokens (both reserved and actually placed) on
      # previous tile
      @tile.cities.each_with_index do |city, i|
        tile.cities[i].reservations = city.reservations.dup

        city.tokens.each do |token|
          tile.cities[i].exchange_token(token) if token
        end
        city.remove_tokens!
        city.reservations.clear
      end

      puts "*** lay tile #{@tile.hex.name} ***"

      @tile.hex = nil
      tile.hex = self

      # give the city/town name of this hex to the new tile; remove it from the
      # old one
      tile.location_name = @location_name
      @tile.location_name = nil
      @tile = tile

      connect!
    end

    def all_connections
      @connections.values.flatten
    end

    def disconnect!
      nodes = @tile.nodes
      paths = @tile.paths

      all_connections.each do |connection|
        paths.each { |p| connection.remove_path(p) }
      end
    end

    def connect!(edge = nil)
      @tile.paths.each { |path| Connection.connect!(path) }
    end

    def neighbor_direction(other)
      DIRECTIONS[@layout][[other.x - @x, other.y - @y]]
    end

    def targeting?(other)
      dir = neighbor_direction(other)
      @tile.exits.include?(dir)
    end

    def invert(dir)
      self.class.invert(dir)
    end

    def inspect
      "<#{self.class.name}: #{name}, tile: #{@tile.name}>"
    end
  end
end
