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
      @upgrades = []
      @offboards = []
      @branches = nil
      @nodes = nil
      @stops = nil
      @edges = nil
      @junctions = nil
      @location_name = location_name
      @legal_rotations = []
      @blockers = []
      @preprinted = preprinted
      @index = index
      @preferred_city_town_edges = {}

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
      @nodes.each(&:clear!)
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
        @junctions.any? ||
        (@cities.size == 1 && @towns.empty?) ||
        ((cities.empty? && towns.size == 1) && edges.size > 2)
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
      # - allow labelled cities to upgrade regardless of count; they're probably
      #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
      # - TODO: account for games that allow double dits to upgrade to one town
      return false if @towns.size != other.towns.size
      return false if !label && @cities.size != other.cities.size

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

    # returns hash where keys are cities, and values are the edge the city or
    # town should be rendered at
    #
    # "ct" for "city or town"
    def preferred_city_town_edges
      # cache per rotation
      @preferred_city_town_edges[@rotation] ||=
        begin
          # ct => nums of edges it is connected to
          ct_edges = Hash.new { |h, k| h[k] = [] }

          # edge => how many tracks/cts are on that edge, plus 0.1
          # for each track/ct on neighboring edges
          edge_count = Hash.new(0)

          # slightly prefer to keep room along bottom to render location name
          edge_count[0] += 0.1

          # populate ct_edges and edge_count as described in above comments
          paths.each do |path|
            next unless (ct = path.city || path.town)

            path.exits.each do |edge|
              ct_edges[ct] << edge
              edge_count[edge] += 1
              edge_count[(edge + 1) % 6] += 0.1
              edge_count[(edge - 1) % 6] += 0.1
            end
          end

          # sort ct_edges so that the lowest edge with any paths will be
          # handled first
          sorted = ct_edges.each { |_, e| e.sort! }.sort_by { |_, e| e }

          # construct the final hash to return, updating edge_count along the
          # way
          sorted.map do |ct, edges_|
            edge = edges_.min_by { |e| edge_count[e] }

            # since this edge is being used, increase its count (and that of its
            # neighbors) to influence what edges will be used for the remaining
            # cts
            edge_count[edge] += 1
            edge_count[(edge + 1) % 6] += 0.1
            edge_count[(edge - 1) % 6] += 0.1

            [ct, edge]
          end.to_h
        end
    end

    private

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

      @parts.each.group_by(&:class).values.each do |parts|
        parts.each.with_index do |part, index|
          part.index = index
          part.tile = self
        end
      end

      @nodes = @paths.map(&:node).compact.uniq
      @branches = @paths.map(&:branch).compact.uniq
      @junctions = @paths.map(&:junction).compact.uniq
      @stops = @paths.map(&:stop).compact.uniq
      @edges = @paths.flat_map(&:edges).compact.uniq
    end
  end
end
