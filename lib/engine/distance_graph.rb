# frozen_string_literal: true

module Engine
  class DistanceGraph
    def initialize(game, **opts)
      @game = game
      @node_distances = {}
      @path_distances = {}
      @hex_distances = {}
      @separate_node_types = opts[:separate_node_types] || false
    end

    def clear
      @node_distances.clear
      @path_distances.clear
      @hex_distances.clear
    end

    def node_distances(corporation)
      compute(corporation) unless @node_distances[corporation]
      @node_distances[corporation]
    end

    def path_distances(corporation)
      compute(corporation) unless @path_distances[corporation]
      @path_distances[corporation]
    end

    def hex_distances(corporation)
      compute(corporation) unless @hex_distances[corporation]
      @hex_distances[corporation]
    end

    def get_token_cities(corporation)
      tokens = []
      @game.hexes.each do |hex|
        hex.tile.cities.each do |city|
          next unless city.tokened_by?(corporation)

          tokens << city
        end
      end
      tokens
    end

    def smaller_or_equal_distance?(a, b)
      a&.all? { |k, v| v <= b[k] }
    end

    def merge_distance(a, b)
      return b.dup unless a

      a.map { |k, v| [k, [v, b[k]].min] }.to_h
    end

    def node_walk(
      node,
      distance: nil,
      node_distances: {},
      path_distances: {},
      corporation: nil,
      counter: Hash.new(0),
      &block
    )
      return if smaller_or_equal_distance?(node_distances[node], distance)

      node_distances[node] = merge_distance(node_distances[node], distance)
      return if corporation && node.blocks?(corporation)

      if node.city? || node.town? && !@separate_node_types
        distance[:city] += 1
      elsif node.town? && !node.halt?
        distance[:town] += 1
      end

      node.paths.each do |node_path|
        next if smaller_or_equal_distance?(path_distances[node_path], distance)

        node_path.walk(
          counter: counter,
        ) do |path, _vp, ct|
          path_distances[path] = merge_distance(path_distances[path], distance)

          ret = yield path, distance
          next if ret == :abort
          next if path.terminal?

          path.nodes.each do |next_node|
            next if next_node == node

            node_walk(
              next_node,
              distance: distance,
              node_distances: node_distances,
              path_distances: path_distances,
              corporation: corporation,
              counter: ct,
              &block
            )
          end
        end
      end

      if node.city? || node.town? && !@separate_node_types
        distance[:city] -= 1
      elsif node.town? && !node.halt?
        distance[:town] -= 1
      end
    end

    def compute(corporation)
      tokens = get_token_cities(corporation)
      n_distances = {}
      p_distances = {}
      h_distances = {}

      tokens.each do |node|
        node_walk(
          node,
          distance: @separate_node_types ? { city: 0, town: 0 } : { city: 0 },
          node_distances: n_distances,
          path_distances: p_distances,
          corporation: corporation,
        ) do |path, dist|
          hex = path.hex
          h_distances[hex] = merge_distance(h_distances[hex], dist)
        end
      end

      @node_distances[corporation] = n_distances
      @path_distances[corporation] = p_distances
      @hex_distances[corporation] = h_distances
    end
  end
end
