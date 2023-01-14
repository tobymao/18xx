# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree 'part'
else
  require 'require_all'
  require_rel 'part'
end

require_relative 'game_error'
require_relative 'config/tile'

module Engine
  class Tile
    include Config::Tile

    attr_accessor :blocks_lay, :hex, :icons, :index, :legal_rotations, :location_name,
                  :name, :opposite, :reservations, :upgrades, :color, :future_label
    attr_reader :borders, :cities, :edges, :junction, :nodes, :labels, :parts, :preprinted, :rotation, :stops, :towns,
                :offboards, :blockers, :city_towns, :unlimited, :stubs, :partitions, :id, :frame, :stripes, :hidden

    ALL_EDGES = [0, 1, 2, 3, 4, 5].freeze

    def self.for(name, **opts)
      if (code = WHITE[name])
        color = :white
      elsif (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
      elsif (code = GREENBROWN[name])
        color = :green
        code = if code.size.positive?
                 'stripes=color:brown;' + code
               else
                 'stripes=color:brown'
               end
      elsif (code = BROWN[name])
        color = :brown
      elsif (code = BROWNGRAY[name])
        color = :brown
        code = if code.size.positive?
                 'stripes=color:gray;' + code
               else
                 'stripes=color:gray'
               end
      elsif (code = GRAY[name])
        color = :gray
      elsif (code = RED[name])
        color = :red
      elsif (code = BLUE[name])
        color = :blue
      elsif (code = BROWNSEPIA[name])
        color = :brown
        code = if code.size.positive?
                 'stripes=color:sepia;' + code
               else
                 'stripes=color:sepia'
               end
      else
        raise Engine::GameError, "Tile '#{name}' not found"
      end

      from_code(name, color, code, **opts)
    end

    def self.decode(code)
      cache = []

      code.split(';').map do |part_code|
        type, params = part_code.split('=')
        params ||= ''

        params = params.split(',').to_h { |param| param.split(':') } if params.include?(':')

        part(type, params, cache)
      end
    end

    def self.from_code(name, color, code, **opts)
      Tile.new(name, code: code, color: color, parts: decode(code), **opts)
    end

    def self.part(type, params, cache)
      case type
      when 'path'
        params = params.to_h do |k, v|
          case k
          when 'terminal', 'a_lane', 'b_lane', 'ignore'
            [k, v]
          when 'lanes'
            [k, v.to_i]
          when 'track'
            [k, v.to_sym]
          else
            case v[0]
            when '_'
              [k, cache[v[1..-1].to_i]]
            else
              [k, Part::Edge.new(v)]
            end
          end
        end

        Part::Path.make_lanes(params['a'], params['b'], terminal: params['terminal'],
                                                        lanes: params['lanes'], a_lane: params['a_lane'],
                                                        b_lane: params['b_lane'],
                                                        track: params['track'],
                                                        ignore: params['ignore'])
      when 'city'
        city = Part::City.new(params['revenue'],
                              slots: params['slots'],
                              groups: params['groups'],
                              hide: params['hide'],
                              visit_cost: params['visit_cost'],
                              route: params['route'],
                              format: params['format'],
                              boom: params['boom'],
                              loc: params['loc'])
        cache << city
        city
      when 'pass'
        pass = Part::Pass.new(params['revenue'],
                              slots: params['slots'],
                              groups: params['groups'],
                              hide: params['hide'],
                              visit_cost: params['visit_cost'],
                              route: params['route'],
                              format: params['format'],
                              boom: params['boom'],
                              loc: params['loc'],
                              color: params['color'],
                              size: params['size'])
        cache << pass
        pass
      when 'town'
        town = Part::Town.new(params['revenue'],
                              groups: params['groups'],
                              hide: params['hide'],
                              visit_cost: params['visit_cost'],
                              route: params['route'],
                              format: params['format'],
                              loc: params['loc'],
                              boom: params['boom'],
                              style: params['style'],
                              to_city: params['to_city'])
        cache << town
        town
      when 'halt'
        halt = Part::Halt.new(params['symbol'],
                              groups: params['groups'],
                              hide: params['hide'],
                              visit_cost: params['visit_cost'],
                              route: params['route'],
                              format: params['format'],
                              loc: params['loc'])
        cache << halt
        halt
      when 'offboard'
        offboard = Part::Offboard.new(params['revenue'],
                                      groups: params['groups'],
                                      hide: params['hide'],
                                      visit_cost: params['visit_cost'],
                                      route: params['route'],
                                      format: params['format'])
        cache << offboard
        offboard
      when 'label'
        Part::Label.new(params)
      when 'upgrade'
        Part::Upgrade.new(params['cost'], params['terrain']&.split('|'), params['size'])
      when 'border'
        Part::Border.new(params['edge'], params['type'], params['cost'], params['color'])
      when 'junction'
        junction = Part::Junction.new
        cache << junction
        junction
      when 'icon'
        Part::Icon.new(params['image'], params['name'], params['sticky'], params['blocks_lay'],
                       large: params['large'])
      when 'stub'
        Part::Stub.new(params['edge'].to_i)
      when 'partition'
        Part::Partition.new(params['a'], params['b'], params['type'], params['restrict'])
      when 'frame'
        Part::Frame.new(params['color'], params['color2'])
      when 'stripes'
        Part::Stripes.new(params['color'])
      when 'future_label'
        Part::FutureLabel.new(params['label'], params['color'])
      end
    end

    # rotation 0-5
    def initialize(name,
                   code:,
                   color:,
                   parts:,
                   rotation: 0,
                   preprinted: false,
                   index: 0,
                   location_name: nil,
                   **opts)
      @name = name
      @code = code
      @color = color.to_sym
      @parts = parts&.flatten
      @rotation = rotation
      @cities = []
      @paths = []
      @stubs = []
      @partitions = []
      @towns = []
      @city_towns = []
      @all_stop = []
      @upgrades = []
      @offboards = []
      @original_borders = []
      @borders = []
      @nodes = nil
      @stops = nil
      @edges = nil
      @frame = nil
      @stripes = nil
      @junction = nil
      @icons = []
      @location_name = location_name
      @legal_rotations = []
      @blockers = []
      @reservations = []
      @preprinted = preprinted
      @index = index
      @blocks_lay = nil
      @reservation_blocks = opts[:reservation_blocks] || :never
      @unlimited = opts[:unlimited] || false
      @labels = []
      @future_label = nil
      @opposite = nil
      @hidden = opts[:hidden] || false
      @id = "#{@name}-#{@index}"

      separate_parts
    end

    def dup
      # This assumes you pass in the highest index of that tile
      Tile.new(@name,
               code: @code,
               color: @color,
               parts: Tile.decode(@code),
               rotation: @rotation,
               preprinted: @preprinted,
               index: @index + 1,
               location_name: @location_name,
               reservation_blocks: @reservation_blocks,
               unlimited: @unlimited,
               hidden: @hidden)
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
      @junction&.clear!
      @_paths = nil
      @_exits = nil
      @_exit_count = nil
      @preferred_city_town_edges = nil
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

    def converging_exit?(num)
      exit_count[num] > 1
    end

    def exit_count
      @_exit_count ||= begin
        counts = Hash.new(0)
        @edges.each { |edge| counts[rotate(edge.num, @rotation)] += 1 }
        counts
      end
    end

    def ignore_gauge_walk=(val)
      @paths.each { |p| p.ignore_gauge_walk = val }
      @nodes.each(&:clear!)
      @junction&.clear!
      @_paths = nil
    end

    def ignore_gauge_compare=(val)
      @paths.each { |p| p.ignore_gauge_compare = val }
      @nodes.each(&:clear!)
      @junction&.clear!
      @_paths = nil
    end

    def terrain
      @upgrades.flat_map(&:terrains).uniq
    end

    # if tile has more than one intra-tile paths, connections using those paths
    # cannot be identified with just a hex name
    def ambiguous_connection?
      @ambiguous_connection ||= @paths.count { |p| p.nodes.size > 1 } > 1
    end

    def paths_are_subset_of?(other_paths)
      if @junction && other_paths.any?(&:junction)
        # Upgrading from a Lawson tile to a Lawson tile is a special case
        other_exits = other_paths.flat_map(&:exits).uniq
        ALL_EDGES.any? { |ticks| (exits - other_exits.map { |e| (e + ticks) % 6 }).empty? }
      else
        ALL_EDGES.any? do |ticks|
          @paths.all? do |path|
            path = path.rotate(ticks)
            other_paths.any? { |other| path <= other }
          end
        end
      end
    end

    def add_blocker!(private_company)
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
      @preferred_city_town_edges ||= compute_city_town_edges
    end

    def reserved_by?(corporation)
      @reservations.any? { |r| [r, r.owner].include?(corporation) }
    end

    def add_reservation!(entity, city, slot = nil, reserve_city = true)
      # Single city, assume the first unless reserve_city is false
      city = 0 if @cities.one? && reserve_city
      slot = @cities[city].get_slot(entity) if city && slot.nil?

      if city && slot
        @cities[city].add_reservation!(entity, slot)
      else
        @reservations << entity
      end
    end

    def token_blocked_by_reservation?(corporation)
      return false if @reservations.empty?

      if @reservation_blocks == :always || (@reservation_blocks == :yellow_only && @color == :yellow)
        !@reservations.include?(corporation)
      else
        @reservations.count { |x| corporation != x } >= @cities.sum(&:available_slots)
      end
    end

    def city_town_edges
      # Returns a list of each edge a city/town goes to
      ct_edges = Hash.new { |h, k| h[k] = [] }
      paths.each do |path|
        next unless (ct = path.city || path.town)

        path.exits.each do |edge|
          ct_edges[ct] << edge
        end
      end
      ct_edges.values
    end

    def city_town_edges_are_subset_of?(other_cte)
      cte = city_town_edges
      ALL_EDGES.any? do |rotation|
        cte.all? do |city|
          other_cte.any? do |other_city|
            city.all? { |edge| other_city.include?(rotate(edge, rotation)) }
          end
        end
      end
    end

    def compute_loc(loc = nil)
      return nil if !loc || loc == 'center'

      (loc.to_f + @rotation) % 6
    end

    def compute_city_town_edges
      # ct => nums of edges it is connected to
      ct_edges = Hash.new { |h, k| h[k] = [] }

      # edge => how many tracks/cts are on that edge, plus 0.1
      # for each track/ct on neighboring edges
      edge_count = Hash.new(0)

      if @paths.empty? && @cities.size >= 2
        # If a tile has no paths but multiple cities, avoid them rendering on top of each other
        div = 6 / @cities.size
        @cities.each_with_index { |x, index| edge_count[x] = (index * div) }
        return edge_count
      end

      # if a tile has exactly one city and no towns, place in center
      if @cities.one? && @towns.empty? && !compute_loc(@cities.first.loc)
        ct_edges[@cities.first] = nil
        return ct_edges
      end
      # if a tile has no cities and exactly one town that doesn't have two exits, place in center
      if @cities.empty? && @towns.one? && (@towns[0].exits.size != 2) && !compute_loc(@towns.first.loc)
        ct_edges[@towns.first] = nil
        return ct_edges
      end

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
      ct_edges = ct_edges.each { |_, e| e.sort! }.sort_by { |_, e| e }

      # construct the final hash to return, updating edge_count along the
      # way
      ct_edges = ct_edges.to_h do |ct, edges_|
        edge = ct.loc ? compute_loc(ct.loc) : edges_.min_by { |e| edge_count[e] }

        # since this edge is being used, increase its count (and that of its
        # neighbors) to influence what edges will be used for the remaining
        # cts
        unless ct.loc
          edge_count[edge] += 1
          edge_count[(edge + 1) % 6] += 0.1
          edge_count[(edge - 1) % 6] += 0.1
        end

        [ct, edge]
      end

      # take care of city/towns with no paths when there is one other city/town
      pathless_cts = @city_towns.select { |ct| ct.paths.empty? }
      if pathless_cts.one? && @city_towns.size == 2
        ct = pathless_cts.first
        ct_edges[ct] = (ct_edges.values.first + 3) % 6 if ct_edges.values.first
      end

      # take care of city/towns with no exits
      exitless_cts = @city_towns.select { |xct| xct.exits.empty? }
      exitless_cts.select do |xct|
        ct_edges[xct] = compute_loc(xct.loc) if xct.loc
      end

      ct_edges
    end

    # this is invariant over rotations
    def crossover?
      return @_crossover if defined?(@_crossover)

      @_crossover = compute_crossover
    end

    def compute_crossover
      return false unless @paths.size > 1

      edge_paths = Hash.new { |h, k| h[k] = [] }

      paths.each do |p|
        next if p.nodes.size > 1
        next if p.a_num == p.b_num

        edge_paths[p.a_num] << p
        edge_paths[p.b_num] << p
      end

      paths.each do |p|
        next if p.nodes.size > 1

        a_num = p.a_num
        b_num = p.b_num

        if p.straight?
          return true if edge_paths[(a_num + 1) % 6].any?(&:straight?)
          return true if edge_paths[(a_num - 1) % 6].any?(&:straight?)
        elsif p.gentle_curve?
          low = [a_num, b_num].min
          middle = (a_num - b_num).abs == 2 ? (low + 1) % 6 : (low - 1) % 6
          return true if edge_paths[middle].any? { |ep| ep.straight? || ep.gentle_curve? }
        end
      end

      false
    end

    def revenue_to_render
      @revenue_to_render ||= @revenue_stops.map(&:revenue_to_render)
    end

    def revenue_changed
      @revenue_to_render = nil
    end

    # Used to set label for a recently placed tile
    def label=(label_name)
      @labels.clear
      @labels << Part::Label.new(label_name) if label_name
    end

    def label
      @labels.last
    end

    def restore_borders(edges = nil)
      edges ||= ALL_EDGES

      # Re-add borders that are in the edge list returning those that are missing
      missing = edges.map do |edge|
        original = @original_borders.find { |e| e.edge == edge }
        next unless original
        next if @borders.include?(original)

        @borders << original
        edge
      end.compact

      missing.each do |edge|
        neighbor = @hex.neighbors[edge]&.tile
        neighbor&.restore_borders([Hex.invert(edge)])
      end
    end

    def reframe!(color1, color2 = nil)
      @frame = color1 ? Engine::Part::Frame.new(color1, color2) : nil
    end

    def restripe!(color)
      @stripes = color ? Part::Stripes.new(color) : nil
    end

    def available_slot?
      cities.sum(&:available_slots).positive?
    end

    private

    def separate_parts
      @parts.each do |part|
        @blocks_lay ||= part.blocks_lay?

        if part.city?
          @cities << part
          @city_towns << part
        elsif part.label?
          @labels << part
        elsif part.path?
          @paths << part
        elsif part.town?
          @towns << part
          @city_towns << part
        elsif part.upgrade?
          @upgrades << part
        elsif part.offboard?
          @offboards << part
        elsif part.border?
          @original_borders << part
          @borders << part
        elsif part.junction?
          @junction = part
        elsif part.icon?
          @icons << part
        elsif part.stub?
          @stubs << part
        elsif part.partition?
          @partitions << part
        elsif part.frame?
          @frame = part
        elsif part.stripes?
          @stripes = part
        elsif part.future_label?
          @future_label = part
        else
          raise "Part #{part} not separated."
        end
      end

      @parts.each_with_index do |part, idx|
        part.index = idx
        part.tile = self
      end

      @nodes = @paths.flat_map(&:nodes).uniq
      @stops = @paths.flat_map(&:stops).uniq
      @edges = @paths.flat_map(&:edges).uniq

      # allow offboards w/o paths to render
      @revenue_stops = (@stops + @offboards).uniq

      @edges.each { |e| e.tile = self }
    end
  end
end
