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

    # returns array where the value at an index is which edge that city (based
    # on index in self.cities) should be rendered
    def edges_for_city_rendering
      @_edges_for_city_rendering ||= {}
      cached_val = @_edges_for_city_rendering[@rotation]
      return cached_val unless cached_val.nil?

      # array of hashes; index is city index, edges is nums of edges that city
      # connects to
      city_edges = cities.map do |city|
        edges = paths.select do |path|
          [path.a, path.b].any? { |p| p.is?(city) }
        end.flat_map(&:edges).map(&:num)

        {
          index: city.index,
          edges: edges.sort,
        }
      end

      # sort so that cities connected to lower edges are handled first
      city_edges = city_edges.sort_by { |ce| ce[:edges] }

      # key: edge num where a city might be rendered
      # value: suitability of edge for rendering, on a scale of 0 to 10; start
      # with 10, update value as each city's spot is determined in the loop
      # below
      edges_with_paths = city_edges.flat_map { |ce| ce[:edges] }
      candidate_edges = edges_with_paths.zip(Array.new(edges_with_paths.size, 10)).to_h

      # slightly prefer to keep room along bottom to render location name
      candidate_edges[0] -= 1 if candidate_edges.include?(0)

      # start off by reducing suitability for all edges where neighboring edges
      # have track; doubly so if both of an edge's neighbors have track
      candidate_edges = subtract_all_neighbors(candidate_edges, edges_with_paths)

      # if any candidate edge is used by multiple paths to cities, set that
      # edge's score to 0 (e.g., edge to Chicago Connections on "Chi" tiles in
      # 1846)
      candidate_edges.keys.each do |edge|
        uses = paths.flat_map { |p| [p.a, p.b] }
                   .select(&:edge?)
                   .map(&:num)
                   .count { |e| e == edge }
        candidate_edges[edge] = 0 if uses > 1
      end

      # index: the city index
      # value: the edge on which to render that city
      # - start off nil, update value as each city's spot is determined in the
      #   loop below
      # - this is the value that will be returned
      dest_edges = Array.new(city_edges.size)

      city_edges.each do |city|
        candidates = candidate_edges.select { |edge, _score| city[:edges].include?(edge) }

        # pick the candidate with best score; tiebreak by lowest edge
        #
        # if no candidates available, just take the first edge that has any path
        # to the city
        edge = (candidates.max_by { |e, score| [score, -e] } || city[:edges]).first

        # update candidates for rendering future cities; the chosen edge is now
        # 0 for other cities, and neighboring edges are reduced by 1
        candidate_edges = update_candidates(candidate_edges, edge, city[:index])

        # update the return value
        # (can't just use city_edges.map here because city_edges may be sorted
        # differently than tile.cities)
        dest_edges[city[:index]] = edge
      end

      @_edges_for_city_rendering[@rotation] = dest_edges
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

    # used by edges_for_city_rendering; for each given edge, subtract 1 for each
    # of its neighbors
    def subtract_all_neighbors(candidate_edges, edges)
      edges.each do |edge|
        candidate_edges = subtract_for_neighbors(candidate_edges, edge)
      end
      candidate_edges
    end

    # used by edges_for_city_rendering; set the given edge to 0 and subtract for
    # its neighbors
    def update_candidates(candidate_edges, edge, city_index)
      if edge.nil?
        puts "Error rendering tile '#{name}': could not find edge on which to render city #{city_index}."
        return candidate_edges
      end

      candidate_edges[edge] = 0
      subtract_for_neighbors(candidate_edges, edge)
    end

    # used by edges_for_city_rendering; subtract 1 for each of the given edge's
    # neighboring edges
    def subtract_for_neighbors(candidate_edges, edge)
      puts edge unless edge.is_a?(Integer)

      neighbor1 = (edge + 1) % 6
      neighbor2 = (edge - 1) % 6

      candidate_edges[neighbor1] -= 1 if candidate_edges.include?(neighbor1)
      candidate_edges[neighbor2] -= 1 if candidate_edges.include?(neighbor2)

      candidate_edges
    end
  end
end
