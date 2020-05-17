# frozen_string_literal: true

require_relative 'game_error'
require_relative 'part/city'
require_relative 'part/town'
require_relative 'part/edge'
require_relative 'part/junction'
require_relative 'part/label'
require_relative 'part/offboard'
require_relative 'part/path'
require_relative 'part/upgrade'
require_relative 'config/tile'

module Engine
  class Tile
    include Config::Tile
    # * [t]own     - [r]evenue, local_[id] (default: 0)
    # * [c]ity     - [r]evenue, local_[id] (default: 0), [s]lots (default 1)
    # * [o]ffboard - [r]evenues for different phases (separated by "/")
    # * [p]ath     - endpoints [a] and [b]; the endpoints can be an edge number,
    #                town/city/offboard reference, or a lawson-style [j]unction
    # * [l]abel    - large letters on tile
    # * [u]pgrade  - [c]ost, [t]errain (multiple terrain types separated by "+"),

    # [r]evenue    - number, list of numbers separated by "/", or something like
    #                yellow_30|brown_60|diesel_100

    attr_accessor :hex, :legal_rotations, :location_name, :name, :index
    attr_reader :cities, :color, :edges, :junctions, :label, :nodes,
                :parts, :preprinted, :rotation, :stops, :towns, :upgrades, :offboards, :blockers

    def self.for(name, **opts)
      if (code = WHITE[name])
        color = :white
      elsif (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
      elsif (code = BROWN[name])
        color = :brown
      elsif (code = GRAY[name])
        color = :gray
      elsif (code = RED[name])
        color = :red
      else
        raise Engine::GameError, "Tile '#{name}' not found"
      end

      from_code(name, color, code, **opts)
    end

    def self.decode(code)
      cache = []

      code.split(';').map do |part_code|
        type, params = part_code.split('=')

        params = params.split(',').map { |param| param.split(':') }.to_h if params.include?(':')

        part(type, params, cache)
      end
    end

    def self.from_code(name, color, code, **opts)
      Tile.new(name, color: color, parts: decode(code), **opts)
    end

    def self.part(type, params, cache)
      case type
      when 'p'
        params = params.map do |k, v|
          case v[0]
          when '_'
            [k, cache[v[1..-1].to_i]]
          when 'j'
            [k, Part::Junction.new]
          else
            [k, Part::Edge.new(v)]
          end
        end.to_h

        Part::Path.new(params['a'], params['b'])
      when 'c'
        city = Part::City.new(params['r'], params.fetch('s', 1))
        cache << city
        city
      when 't'
        town = Part::Town.new(params['r'])
        cache << town
        town
      when 'l'
        label = Part::Label.new(params)
        cache << label
        label
      when 'u'
        upgrade = Part::Upgrade.new(params['c'], params['t']&.split('+'))
        cache << upgrade
        upgrade
      when 'o'
        offboard = Part::Offboard.new(params['r'])
        cache << offboard
        offboard
      end
    end

    # rotation 0-5
    def initialize(name, color:, parts:, rotation: 0, preprinted: false, index: 0, location_name: nil)
      @name = name
      @color = color
      @parts = parts
      @rotation = rotation
      @cities = []
      @paths = []
      @towns = []
      @branches = []
      @edges = nil
      @junctions = nil
      @upgrades = []
      @offboards = []
      @location_name = location_name
      @legal_rotations = []
      @blockers = []
      @preprinted = preprinted
      @index = index

      tag_parts
      separate_parts
    end

    def id
      "#{@name}-#{@index}"
    end

    def <=>(other)
      [COLORS.index(@color), @name.to_i] <=> [COLORS.index(other.color), other.name.to_i]
    end

    def rotate!(absolute = nil)
      new_rotation = absolute ||
        @legal_rotations.find { |r| r > @rotation } ||
        @legal_rotations.first ||
        @rotation
      @rotation = new_rotation
      @_paths = nil
      @_exits = nil
      self
    end

    def rotate(num, ticks = 1)
      (num + ticks) % 6
    end

    def paths
      @_paths ||= @paths.map { |path| path.rotate(@rotation) }
    end

    def exits
      @_exits ||= @edges.map { |e| rotate(e.num, @rotation) }.uniq
    end

    def lawson?
      @lawson ||=
        [
          @junctions.any?,
          [cities.size, towns.size] == [1, 0],
          ([cities.size, towns.size] == [0, 1]) && ![1, 2].include?(exits.size),
        ].any?
    end

    def matches(other)
      @name == other.name && @color == other.color && @parts == other.parts
    end

    def upgrade_cost(abilities)
      ignore = abilities.find { |a| a[:type] == :ignore_terrain }

      @upgrades.sum do |upgrade|
        cost = upgrade.cost
        cost = 0 if ignore && upgrade.terrains.uniq == [ignore[:terrain]]
        cost
      end
    end

    def upgrades_to?(other)
      # correct color progression?
      return false unless COLORS.index(other.color) == (COLORS.index(@color) + 1)

      # correct label?
      return false if label != other.label

      # honors existing town/city counts?
      # TODO: this is not true for some OO upgrades, or some tiles where
      # double-town can be upgraded into a single town
      return false unless @towns.size == other.towns.size
      return false unless @cities.size == other.cities.size

      # honors pre-existing track?
      return false unless paths_are_subset_of?(other.paths)

      true
    end

    def paths_are_subset_of?(other_paths)
      (0..5).any? do |ticks|
        @paths.all? do |path|
          path = path.rotate(ticks)
          other_paths.any? { |other| path <= other }
        end
      end
    end

    def add_blocker!(private_company)
      @parts << private_company
      @blockers << private_company
    end

    def inspect
      "<#{self.class.name}: #{name}, hex: #{@hex&.name}>"
    end

    private

    def tag_parts
      @parts.each.group_by(&:class).values.each do |parts|
        parts.each.with_index do |part, index|
          part.index = index
          part.tile = self
        end
      end
    end

    def separate_parts
      @parts.each do |part|
        if part.city?
          @cities << part
        elsif part.label?
          @label = part
        elsif part.path?
          @paths << part
        elsif part.town?
          @towns << part
        elsif part.upgrade?
          @upgrades << part
        elsif part.offboard?
          @offboards << part
        else
          raise "Part #{part} not separated."
        end
      end

      @nodes = @paths.map(&:node)
      @branches = @paths.map(&:branch)
      @junctions = @paths.map(&:junction)
      @edges = @paths.flat_map(&:edges)
      @stops = @paths.map(&:stop).compact
    end
  end
end
