# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G1858
      class Graph < Engine::Graph
        # Alters the default handling of node's in an entity's home hexes in
        # two ways:
        # 1. The entity's +coordinates+ and +city+ attributes are arrays in
        # matching order, so that a city is only included if its index is in
        # the +city+ array at the same position as the hex in the +coordinates+
        # array.
        # 2. Where a home hex only has plain track then a dummy node is created
        # to allow routes to be traced out from this hex.
        def home_hex_nodes(entity)
          nodes = {}
          hexes = Array(entity.coordinates).map { |h| @game.hex_by_id(h) }
          cities = Array(entity.city)
          hexes.zip(cities).each do |hex, city_idx|
            if city_idx
              nodes[hex.tile.cities[city_idx]] = true
            elsif hex.tile.city_towns.empty?
              # Plain track in a home hex (or no tile or track). Create a
              # node for each track path to allow routes to be traced out
              # from this hex.
              hex.tile.paths.each { |path| nodes[G1858::Part::PathNode.new(path)] = true }
            else
              hex.tile.city_towns.each { |ct| nodes[ct] = true }
            end
          end
          nodes
        end
      end
    end
  end
end
