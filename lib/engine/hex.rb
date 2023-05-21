# frozen_string_literal: true

require_relative 'assignable'

module Engine
  class Hex
    include Assignable

    attr_accessor :x, :y, :ignore_for_axes, :location_name
    attr_reader :coordinates, :empty, :layout, :neighbors, :all_neighbors, :tile, :original_tile, :tokens,
                :column, :row, :hide_location_name

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

    LETTERS = ('A'..'Z').to_a + ('AA'..'AZ').to_a
    NEGATIVE_LETTERS = [0] + ('a'..'z').to_a

    COORD_LETTER = /([A-Za-z]+)/.freeze
    COORD_NUMBER = /(-?[0-9]+)/.freeze

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

      column, row =
        if axes_config[:x] == :letter
          [letter, number]
        else
          [number, letter]
        end

      [x, y, column, row]
    end

    # Coordinates are of the form A1..Z99
    # x and y map to the double coordinate system
    # layout is :pointy or :flat
    def initialize(coordinates, layout: nil, axes: nil, tile: Tile.for('blank'),
                   location_name: nil, hide_location_name: false, empty: false)
      @coordinates = coordinates
      @layout = layout
      @axes = axes
      @x, @y, @column, @row = self.class.init_x_y(@coordinates, axes)
      @neighbors = {}
      @all_neighbors = {}
      @location_name = location_name
      tile.location_name = location_name
      @hide_location_name = hide_location_name
      @original_tile = @tile = tile
      @tile.hex = self
      @activations = []
      @empty = empty
      @ignore_for_axes = false
      @tokens = []
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
          @tile.cities.to_h do |old_city|
            new_city = tile.cities.find do |city|
              # we want old_edges to be subset of new_edges
              # without the any? check, first city will always match
              !old_city.exits.empty? && (old_city.exits - city.exits).empty?
            end

            [old_city, new_city]
          end
        end

      # When downgrading from yellow to no-exit tiles, assume it's the same index
      # Also, when upgrading a no-exit city, assume it's the same index if possible, otherwise
      # pick first available city
      new_cities = city_map.values.compact
      @tile.cities.each_with_index do |old_city, index|
        next if city_map[old_city]

        new_city = tile.cities[index]
        new_city = tile.cities.find { |city| !new_cities.include?(city) } if new_cities.include?(new_city)

        city_map[old_city] = new_city
        new_cities << new_city
      end

      # when upgrading, preserve reservations on previous tile
      city_map.each do |old_city, new_city|
        if new_city
          old_city.reservations.compact.each do |entity|
            entity.all_abilities.each do |ability|
              next unless ability.type == :reservation
              next unless ability.hex == coordinates

              ability.tile = new_city.tile
              ability.city = new_city.tile.cities.index(new_city)
            end
          end

          new_city.reservations.concat(old_city.reservations)
          new_city.groups = old_city.groups
        end
        old_city.reservations.clear
      end

      @tile.hex = nil
      tile.hex = self

      # when upgrading, preserve tokens on previous tile (must be handled after
      # reservations are completely done due to OO weirdness)
      city_map.each do |old_city, new_city|
        old_city.tokens.each.with_index do |token, index|
          cheater = (index >= old_city.normal_slots) && index
          new_city.exchange_token(token, cheater: cheater) if token
        end
        old_city.extra_tokens.each { |token| new_city.exchange_token(token, extra_slot: true) }
        old_city.reset!
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

      tile.future_label.sticker = tile.future_label if tile.future_label
      if @tile.future_label
        # future label transfers over
        tile.future_label = @tile.future_label if @tile.future_label.color != tile.color.to_s
        # restore old tile's future_label
        @tile.future_label = @tile.future_label.sticker
      end

      tile.reservations = @tile.reservations
      @tile.reservations = []

      tile.borders.concat(@tile.borders)
      @tile.borders.clear

      tile.partitions.concat(@tile.partitions)
      @tile.partitions.clear

      # give the city/town name of this hex to the new tile; remove it from the
      # old one
      tile.location_name = @location_name
      @tile.location_name = nil

      @tile = tile

      @paths = nil
    end

    def lay_downgrade(tile)
      lay(tile)

      tile.restore_borders
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

    def distance(other)
      # Distance as the crow flies

      dx = (other.x - x).abs
      dy = (other.y - y).abs

      # pointy = double width
      # flat = double height
      if @layout == :pointy
        dy + [0, (dx - dy) / 2].max
      else
        dx + [0, (dy - dx) / 2].max
      end
    end

    def place_token(token, logo: nil, blocks_lay: nil, preprinted: true, loc: nil)
      token.place(self)
      @tokens << token
      icon = Part::Icon.new('', token.corporation.id, true, blocks_lay, preprinted, loc: loc)
      icon.image = logo || token.corporation.logo
      @tile.icons << icon
    end

    def remove_token(token)
      @tile.icons.delete(@tile.icons.find { |icon| icon.name == token.corporation.id })
      @tokens.delete(token)
    end

    def inspect
      "<#{self.class.name}: #{name}, tile: #{@tile.name}>"
    end
  end
end
