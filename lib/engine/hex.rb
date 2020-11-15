# frozen_string_literal: true

require_relative 'assignable'
require_relative 'connection'

module Engine
  class Hex
    include Assignable

    attr_accessor :x, :y, :ignore_for_axes, :location_name
    attr_reader :connections, :coordinates, :empty, :layout, :neighbors, :tile, :original_tile

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
        [-1, 1] => 0,
        [-2, 0] => 1,
        [-1, -1] => 2,
        [1, -1] => 3,
        [2, 0] => 4,
        [1, 1] => 5,
      },
    }.freeze

    LETTERS = ('A'..'Z').to_a
    NEGATIVE_LETTERS = [0] + ('a'..'z').to_a

    COORD_LETTER = /([A-Za-z]+)/.freeze
    COORD_NUMBER = /([0-9]+)/.freeze

    def self.invert(dir)
      (dir + 3) % 6
    end

    def self.init_x_y(coordinates, axes_config)
      axes_config ||= { x: :letter, y: :number }

      letter = coordinates.match(COORD_LETTER)[1]
      number = coordinates.match(COORD_NUMBER)[1].to_i

      x =
        if axes_config[:x] == :letter
          LETTERS.index(letter) || -NEGATIVE_LETTERS.index(letter)
        else
          number - 1
        end

      y =
        if axes_config[:y] == :letter
          LETTERS.index(letter) || -NEGATIVE_LETTERS.index(letter)
        else
          number - 1
        end

      [x, y]
    end

    # Coordinates are of the form A1..Z99
    # x and y map to the double coordinate system
    # layout is :pointy or :flat
    def initialize(coordinates, layout: nil, axes: nil, tile: Tile.for('blank'),
                   location_name: nil, empty: false)
      @coordinates = coordinates
      @layout = layout
      @x, @y = self.class.init_x_y(@coordinates, axes)
      @neighbors = {}
      @connections = Hash.new { |h, k| h[k] = [] }
      @location_name = location_name
      tile.location_name = location_name
      @original_tile = @tile = tile
      @tile.hex = self
      @activations = []
      @empty = empty
      @ignore_for_axes = false
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

    def tile=(new_tile)
      @original_tile = @tile = new_tile
      new_tile.hex = self
    end

    def lay(tile)
      # key: city on @tile (AKA old_city)
      # values: city on tile (AKA new_city)
      #
      # map old cities to new based on edges they are connected to
      city_map =
        # if @tile is blank, map cities by index
        if @tile.cities.flat_map(&:exits).empty? && (@tile.cities.size == tile.cities.size)
          @tile.cities.zip(tile.cities).to_h
        # if @tile is not blank, ensure connectivity is maintained
        else
          @tile.cities.map.with_index do |old_city, index|
            new_city = tile.cities.find do |city|
              # we want old_edges to be subset of new_edges
              # without the any? check, first city will always match
              old_city.exits.any? && (old_city.exits - city.exits).empty?
            end

            # When downgrading from yellow to no-exit tiles, assume it's the same index
            # Also, when upgrading a no-exit city, assume it's the same index if possible
            new_city ||= (tile.cities[index] || tile.cities[0])
            [old_city, new_city]
          end.to_h
        end

      # when upgrading, preserve reservations on previous tile
      city_map.each do |old_city, new_city|
        old_city.reservations.compact.each do |entity|
          entity.abilities(:reservation) do |ability|
            next unless ability.hex == coordinates

            ability.tile = new_city.tile
            ability.city = new_city.index
          end
        end

        new_city.reservations.concat(old_city.reservations)
        old_city.reservations.clear

        new_city.groups = old_city.groups
      end

      # when upgrading, preserve tokens on previous tile (must be handled after
      # reservations are completely done due to OO weirdness)
      city_map.each do |old_city, new_city|
        old_city.tokens.each.with_index do |token, index|
          cheater = (index >= old_city.normal_slots) && index
          new_city.exchange_token(token, cheater: cheater) if token
        end
        old_city.remove_tokens!
      end

      new_icons = tile.icons.group_by(&:name)
      @tile.icons.each do |icon|
        next unless icon.sticky
        next if new_icons[icon.name]&.pop

        new_icon = icon.dup
        new_icon.preprinted = false
        tile.icons << new_icon
      end
      @tile.icons = @tile.icons.select(&:preprinted)

      tile.reservations = @tile.reservations
      @tile.reservations = []

      tile.borders.concat(@tile.borders)
      @tile.borders.clear

      @tile.hex = nil
      tile.hex = self

      # give the city/town name of this hex to the new tile; remove it from the
      # old one
      tile.location_name = @location_name
      @tile.location_name = nil

      @tile = tile

      @connections.clear
      @paths = nil

      connect!
    end

    def lay_downgrade(tile)
      hexes = []

      @tile.paths.each do |path|
        path.walk { |p| hexes << p.hex if p.node? }
      end

      lay(tile)

      hexes.uniq.each do |hex|
        hex.connections.each do |_, connections|
          connections.select!(&:valid?)
        end
      end

      tile.restore_borders
    end

    def connect!
      Connection.connect!(self)
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
      @connections.values.flatten.uniq.select(&:valid?)
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
