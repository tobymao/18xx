# frozen_string_literal: true

module Engine
  class Hex
    attr_reader :coordinates, :layout, :neighbors, :tile, :x, :y, :location_name

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

      @tile.hex = nil
      tile.hex = self

      # give the city/town name of this hex to the new tile; remove it from the
      # old one
      tile.location_name = @location_name
      @tile.location_name = nil
      @tile = tile
    end

    def neighbor_direction(other)
      DIRECTIONS[@layout][[other.x - @x, other.y - @y]]
    end

    def connections(other, direct: false, corporation: nil)
      connected_paths(other, direct: direct, corporation: corporation) +
        other.connected_paths(self, direct: direct, corporation: corporation)
    end

    def connected_paths(other, direct: false, corporation: nil)
      dir = neighbor_direction(other)
      direct_paths, indirect_paths = @tile.paths.partition { |p| p.exits.include?(dir) }
      return direct_paths if direct

      branches = direct_paths.map(&:branch).compact

      direct_paths + indirect_paths.select do |path|
        branch = path.branch
        branches.include?(branch) && !branch.blocks?(corporation)
      end
    end

    def connected_exits(other, direct: false, corporation: nil)
      connected_paths(other, direct: direct, corporation: corporation)
        .map(&:exits)
        .flatten
        .uniq
    end

    def connected?(other)
      targeting?(other) && other.targeting?(self)
    end

    def targeting?(other)
      dir = neighbor_direction(other)
      @tile.exits.include?(dir)
    end

    def invert(dir)
      self.class.invert(dir)
    end

    def ==(other)
      @coordinates == other&.coordinates
    end

    def inspect
      "<#{self.class.name}: #{name}, tile: #{@tile.name}>"
    end
  end
end
