# frozen_string_literal: true

module Engine
  class DistanceGraph
    def initialize(game, **opts)
      @game = game
      @node_distances = {}
      @path_distances = {}
      @hex_distances = {}
      @separate_node_types = opts[:separate_node_types]
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

    def merge_distance(dict, key, b)
      if (a = dict[key])
        a.each { |k, v| a[k] = [v, b[k]].min }
      else
        dict[key] = b.dup
      end
    end

    def node_walk(
      node,
      distance,
      node_distances,
      path_distances,
      corporation,
      counter: Hash.new(0),
      &block
    )
      return if smaller_or_equal_distance?(node_distances[node], distance)

      merge_distance(node_distances, node, distance)
      return if corporation && node.blocks?(corporation)

      count = node.visit_cost.positive? ? 1 : 0

      if !@separate_node_types
        distance[:node] += count
      elsif node.city?
        distance[:city] += count
      elsif node.town? && !node.halt?
        distance[:town] += count
      end

      node.paths.each do |node_path|
        node_path.walk(counter: counter) do |path, _vp, ct|
          merge_distance(path_distances, path, distance)

          ret = yield path, distance
          next if ret == :abort
          next if path.terminal?

          path.nodes.each do |next_node|
            next if next_node == node

            node_walk(
              next_node,
              distance,
              node_distances,
              path_distances,
              corporation,
              counter: ct,
              &block
            )
          end
        end
      end

      if !@separate_node_types
        distance[:node] -= count
      elsif node.city?
        distance[:city] -= count
      elsif node.town? && !node.halt?
        distance[:town] -= count
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
          @separate_node_types ? { city: 0, town: 0 } : { node: 0 },
          n_distances,
          p_distances,
          corporation,
        ) do |path, dist|
          merge_distance(h_distances, path.hex, dist)
        end
      end

      @node_distances[corporation] = n_distances
      @path_distances[corporation] = p_distances
      @hex_distances[corporation] = h_distances
    end
  end
end
