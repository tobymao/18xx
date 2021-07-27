# frozen_string_literal: true

module Engine
  class DistanceGraph
    def initialize(game, **opts)
      @game = game
      @node_distances = {}
      @path_distances = {}
      @hex_distances = {}
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
      a ||= [999, 999]
      a.first <= b.first && a.last <= b.last
    end

    def merge_distance(a, b)
      a ||= [999, 999]
      [[a.first, b.first].min, [a.last, b.last].min]
    end

    def node_distance_walk(
      node,
      distance,
      node_distances: {}, # instead of visited, hashset of minimum distances to nodes
      corporation: nil,
      path_distances: {}, # instead of visited_paths, hashset of minimum distances to paths
      counter: Hash.new(0),
      &block
    )
      return if smaller_or_equal_distance?(node_distances[node], distance)

      node_distances[node] = merge_distance(node_distances[node], distance)
      if node.city?
        distance = [distance.first + 1, distance.last]
      elsif node.town? && !node.halt?
        distance = [distance.first, distance.last + 1]
      end

      node.paths.each do |node_path|
        path_distance_walk(
          node_path,
          distance,
          path_distances: path_distances,
          counter: counter,
        ) do |path, pd, ct|
          ret = yield path, distance
          next if ret == :abort
          next if path.terminal?

          path.nodes.each do |next_node|
            next if next_node == node
            next if corporation && next_node.blocks?(corporation)

            node_distance_walk(
              next_node,
              distance,
              node_distances: node_distances,
              counter: ct,
              corporation: corporation,
              path_distances: pd,
              &block
            )
          end
        end
      end
    end

    def lane_match?(lanes0, lanes1)
      lanes0 && lanes1 && lanes1[0] == lanes0[0] && lanes1[1] == (lanes0[0] - lanes0[1] - 1)
    end

    def path_distance_walk(
      path,
      distance,
      skip: nil,
      jskip: nil,
      path_distances: {},
      skip_paths: nil,
      counter: Hash.new(0),
      &block
    )
      return if smaller_or_equal_distance?(path_distances[path], distance)
      return if path.junction && counter[path.junction] > 1
      return if path.edges.sum { |edge| counter[edge.id] }.positive?

      path_distances[path] = merge_distance(path_distances[path], distance)
      counter[path.junction] += 1 if path.junction

      yield path, path_distances, counter

      if path.junction && path.junction != jskip
        path.junction.paths.each do |jp|
          path_distance_walk(
            jp,
            distance,
            jskip: path.junction,
            path_distances: path_distances,
            counter: counter,
            &block
          )
        end
      end

      path.exits.each do |edge|
        edge_id = edge.id
        edge = edge.name
        next if edge == skip
        next unless (neighbor = path.hex.neighbors[edge])

        counter[edge_id] += 1
        np_edge = path.hex.invert(edge)

        neighbor.paths[np_edge].each do |np|
          next unless lane_match?(path.exit_lanes[edge], np.exit_lanes[np_edge])

          path_distance_walk(
            np,
            distance,
            skip: np_edge,
            path_distances: path_distances,
            counter: counter,
            &block)
        end
        counter[edge_id] -= 1
      end
      counter[path.junction] -= 1 if path.junction
    end

    def compute(corporation)
      tokens = get_token_cities(corporation)
      n_distances = {}
      p_distances = {}
      h_distances = {}

      tokens.each do |node|
        node_distance_walk(
          node,
          [0, 0],
          node_distances: n_distances,
          corporation: corporation,
          path_distances: p_distances
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
