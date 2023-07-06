# frozen_string_literal: true

require_relative 'part/path'

module Engine
  class Graph
    def initialize(game, **opts)
      @game = game
      @connected_hexes = {}
      @connected_nodes = {}
      @connected_paths = {}
      @connected_hexes_by_token = Hash.new { |h, k| h[k] = {} }
      @connected_paths_by_token = Hash.new { |h, k| h[k] = {} }
      @connected_nodes_by_token = Hash.new { |h, k| h[k] = {} }
      @reachable_hexes = {}
      @tokenable_cities = {}
      @routes = {}
      @tokens = {}
      @cheater_tokens = {}
      @home_as_token = opts[:home_as_token] || false
      @no_blocking = opts[:no_blocking] || false
      @skip_track = opts[:skip_track]
      @check_tokens = opts[:check_tokens]
      @check_regions = opts[:check_regions]
    end

    def clear
      @connected_hexes.clear
      @connected_nodes.clear
      @connected_paths.clear
      @connected_hexes_by_token.clear
      @connected_nodes_by_token.clear
      @connected_paths_by_token.clear
      @reachable_hexes.clear
      @tokenable_cities.clear
      @tokens.clear
      @cheater_tokens.clear
      @routes.delete_if do |_, route|
        !route[:route_train_purchase]
      end
    end

    def clear_graph_for(corporation)
      clear
      @routes.delete(corporation)
    end

    def clear_graph_for_all
      # warning: this is very costly
      clear
      @routes.clear
    end

    def route_info(corporation)
      compute(corporation, routes_only: true) unless @routes[corporation]
      @routes[corporation]
    end

    def can_token?(corporation, cheater: false)
      tokens = cheater ? @cheater_tokens : @tokens
      return tokens[corporation] if tokens.key?(corporation)

      compute(corporation) do |node|
        if node.tokenable?(corporation, free: true, cheater: cheater)
          tokens[corporation] = true
          break
        end
      end
      tokens[corporation] ||= false
      tokens[corporation]
    end

    def no_blocking?
      @no_blocking
    end

    def tokenable_cities(corporation)
      # A list of all tokenable cities per corporation
      return @tokenable_cities[corporation] if @tokenable_cities.key?(corporation)

      cities = []
      compute(corporation) do |node|
        cities << node if node.tokenable?(corporation, free: true)
      end

      @tokenable_cities[corporation] = cities if cities.any?
      cities
    end

    def connected_hexes(corporation)
      compute(corporation) unless @connected_hexes[corporation]
      @connected_hexes[corporation]
    end

    def connected_nodes(corporation)
      compute(corporation) unless @connected_nodes[corporation]
      @connected_nodes[corporation]
    end

    def connected_paths(corporation)
      compute(corporation) unless @connected_paths[corporation]
      @connected_paths[corporation]
    end

    def connected_hexes_by_token(corporation, token)
      compute_by_token(corporation) unless @connected_hexes_by_token[corporation][token]
      @connected_hexes_by_token[corporation][token]
    end

    def connected_nodes_by_token(corporation, token)
      compute_by_token(corporation) unless @connected_nodes_by_token[corporation][token]
      @connected_nodes_by_token[corporation][token]
    end

    def connected_paths_by_token(corporation, token)
      compute_by_token(corporation) unless @connected_paths_by_token[corporation][token]
      @connected_paths_by_token[corporation][token]
    end

    def reachable_hexes(corporation)
      compute(corporation) unless @reachable_hexes[corporation]
      @reachable_hexes[corporation]
    end

    def compute_by_token(corporation)
      compute(corporation)
      @game.hexes.each do |hex|
        hex.tile.cities.each do |city|
          next unless @game.city_tokened_by?(city, corporation)
          next if @check_tokens && @game.skip_token?(self, corporation, city)

          compute(corporation, one_token: city)
        end
      end
    end

    # Called from #compute when @home_is_token is true.
    # Returns a hash whose keys are the Engine::Hex objects for each hex in the
    # entity's coordinates list. The values are hashes with keys that are the
    # edge numbers of all adjacent hexes and values of +true+.
    def home_hexes(corporation)
      home_hexes = Hash.new { |h, k| h[k] = {} }
      hexes = Array(corporation.coordinates).map { |h| @game.hex_by_id(h) }
      hexes.each do |hex|
        hex.neighbors.each { |edge, _| home_hexes[hex][edge] = true }
      end
      home_hexes
    end

    # Called from #compute when @home_is_token is true.
    # Returns a hash whose keys are the nodes (either Engine::Part::City or
    # Engine::Part::Town objects) for nodes in the hexes that are in the
    # entity's coordinates list. The value for each item is +true+.
    #
    # Where there are multiple cities in a hex:
    # 1. If the entity does not have a +city+ attribute defined then all cities
    # are included.
    # 2. If there is a single value in the +city+ attribute then the city with
    # the matching index is included.
    # 3. If +city+ is an array then all cities with matching indexes are
    # included.
    def home_hex_nodes(corporation)
      nodes = {}
      hexes = Array(corporation.coordinates).map { |h| @game.hex_by_id(h) }
      hexes.each do |hex|
        if corporation.city
          Array(corporation.city).map { |c_idx| hex.tile.cities[c_idx] }.compact.each { |c| nodes[c] = true }
        else
          hex.tile.city_towns.each { |ct| nodes[ct] = true }
        end
      end
      nodes
    end

    def compute(corporation, routes_only: false, one_token: nil)
      hexes = Hash.new { |h, k| h[k] = {} }
      nodes = {}
      paths = {}

      @game.hexes.each do |hex|
        hex.tile.cities.each do |city|
          next if one_token && (city != one_token)

          next unless @game.city_tokened_by?(city, corporation)
          next if @check_tokens && @game.skip_token?(self, corporation, city)

          hex.neighbors.each { |e, _| hexes[hex][e] = true }
          nodes[city] = true
        end
      end

      if @home_as_token && corporation.coordinates
        hexes.merge!(home_hexes(corporation))
        nodes.merge!(home_hex_nodes(corporation))
      end

      tokens = nodes.dup

      @game.abilities(corporation, :token) do |ability, c|
        next unless c == corporation # token ability must be activated
        next unless ability.teleport_price

        ability.hexes.each do |hex_id|
          @game.hex_by_id(hex_id).tile.cities.each do |node|
            nodes[node] = true
            yield node if block_given?
          end
        end
      end

      @game.abilities(corporation, :teleport) do |ability, owner|
        next unless owner == corporation # teleport ability must be activated

        ability.hexes.each do |hex_id|
          hex = @game.hex_by_id(hex_id)
          hex.neighbors.each { |e, _| hexes[hex][e] = true }
          hex.tile.cities.each do |node|
            nodes[node] = true
            yield node if ability.used? && block_given?
          end
        end
      end

      routes = @routes[corporation] || {}
      walk_corporation = @no_blocking ? nil : corporation
      skip_paths = @check_regions ? @game.graph_border_paths(corporation) : @game.graph_skip_paths(corporation)

      tokens.keys.each do |node|
        return nil if routes[:route_train_purchase] && routes_only

        visited = tokens.reject { |token, _| token == node }
        local_nodes = {}

        node.walk(visited: visited, corporation: walk_corporation, skip_track: @skip_track,
                  skip_paths: skip_paths, converging_path: false) do |path, _, _|
          next if paths[path]

          paths[path] = true

          path.nodes.each do |p_node|
            nodes[p_node] = true
            local_nodes[p_node] = true
            yield p_node if block_given?
          end

          hex = path.hex

          path.exits.each do |edge|
            hexes[hex][edge] = true
            hexes[hex.neighbors[edge]][hex.invert(edge)] = true if !@check_regions || !@game.region_border?(hex, edge)
          end
        end

        next if routes[:route_train_purchase]

        mandatory_nodes = 0
        optional_nodes = 0
        local_nodes.each do |p_node, _|
          case p_node.route
          when :mandatory
            mandatory_nodes += 1
          when :optional
            optional_nodes += 1
          end
        end

        if mandatory_nodes > 1
          routes[:route_available] = true
          routes[:route_train_purchase] = true
          @routes[corporation] = routes
        elsif mandatory_nodes == 1 && optional_nodes.positive?
          routes[:route_available] = true
        end
      end

      hexes.default = nil
      hexes.transform_values!(&:keys)

      # connected_hexes - hexes in which this corporation can lay track
      # connected_nodes - hexes in which this corporation can token
      # reachable_hexes - hexes in which this corporation can run

      if one_token
        @connected_hexes_by_token[corporation][one_token] = hexes
        @connected_nodes_by_token[corporation][one_token] = nodes
        @connected_paths_by_token[corporation][one_token] = paths
      else
        @routes[corporation] = routes
        @connected_hexes[corporation] = hexes
        @connected_nodes[corporation] = nodes
        @connected_paths[corporation] = paths
        @reachable_hexes[corporation] = paths.to_h { |path, _| [path.hex, true] }
      end
    end
  end
end
