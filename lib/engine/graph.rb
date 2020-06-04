# frozen_string_literal: true

require_relative 'part/path'

module Engine
  class Graph
    def initialize(game)
      @game = game
      @connected_hexes = {}
      @connected_nodes = {}
      @connected_paths = {}
      @reachable_hexes = {}
    end

    def clear
      @connected_hexes.clear
      @connected_nodes.clear
      @connected_paths.clear
      @reachable_hexes.clear
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

    def reachable_hexes(corporation)
      compute(corporation) unless @reachable_hexes[corporation]
      @reachable_hexes[corporation]
    end

    def compute(corporation)
      hexes = Hash.new { |h, k| h[k] = [] }
      nodes = {}
      paths = {}

      @game.hexes.each do |hex|
        hex.tile.cities.each do |city|
          next unless city.tokened_by?(corporation)

          hexes[hex].concat(hex.neighbors.keys)
          nodes[city] = true
        end
      end

      tokens = nodes.dup

      # this can be much more efficient if we track path directional visited
      tokens.keys.each do |node|
        node.walk(visited: tokens.reject { |k, _| k == node }, corporation: corporation) do |path|
          paths[path] = true
          nodes[path.node] = true if path.node
          hex = path.hex

          path.exits.each do |edge|
            hexes[hex] << edge
            neighbor = hex.neighbors[edge]
            edge = hex.invert(edge)
            hexes[neighbor] << edge if neighbor.paths[edge].empty?
          end
        end
      end

      corporation.abilities(:teleport) do |ability, _|
        ability[:hexes].each do |hex_id|
          hex = @game.hex_by_id(hex_id)
          hexes[hex].concat(hex.neighbors.keys)
          hex.tile.nodes.each { |node| nodes[node] = true }
        end
      end

      hexes.default = nil
      hexes.each { |_, edges| edges.uniq! }

      @connected_hexes[corporation] = hexes
      @connected_nodes[corporation] = nodes
      @connected_paths[corporation] = paths
      @reachable_hexes[corporation] = paths.map { |path, _| [path.hex, true] }.to_h
    end
  end
end
