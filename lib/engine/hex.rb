# frozen_string_literal: true

require_relative 'connection'

module Engine
  class Hex
    attr_reader :connections, :coordinates, :layout, :neighbors, :tile, :x, :y, :location_name

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

    def <=>(other)
      name <=> other.name
    end

    def name
      @coordinates
    end

    def lay(tile)
      # key: city on @tile (AKA old_city)
      # values: city on tile (AKA new_city)
      #
      # map old cities to new based on edges they are connected to
      city_map =
        # if @tile is blank, map cities by index
        if @tile.cities.flat_map(&:connected_edges).empty? && (@tile.cities.size == tile.cities.size)
          @tile.cities.zip(tile.cities).to_h

        # if @tile is not blank, ensure connectivity is maintained
        else
          @tile.cities.map do |old_city|
            cities = tile.cities.select do |new_city|
              # we want old_edges to be subset of new_edges
              old_edges = old_city.connected_edges
              new_edges = new_city.connected_edges
              old_edges & new_edges == old_edges
            end.compact

            unless cities.one?
              err_msg = "City #{old_city.index} on old tile maps to "\
                        "cities #{cities.map(&:index)} on new tile; expected "\
                        'exactly one city on new tile'
              raise GameError, err_msg
            end

            [old_city, cities.first]
          end.to_h
        end

      # when upgrading, preserve tokens (both reserved and actually placed) on
      # previous tile
      city_map.each do |old_city, new_city|
        new_city.reservations = old_city.reservations.dup

        old_city.tokens.each do |token|
          new_city.exchange_token(token) if token
        end
        old_city.remove_tokens!
        old_city.reservations.clear
      end

      @tile.hex = nil
      tile.hex = self

      # give the city/town name of this hex to the new tile; remove it from the
      # old one
      tile.location_name = @location_name
      @tile.location_name = nil
      @tile = tile
      clear_cache
      connect!
    end

    def connect!
      Connection.connect!(self)
    end

    def clear_cache
      @paths = nil
    end

    def paths
      @paths =
        begin
          paths = Hash.new { |h, k| h[k] = [] }

          @tile.paths.each do |path|
            path.exits.each { |e| paths[e] << path }
          end

          paths
        end
    end

    def all_connections
      @connections.values.flatten.uniq
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
