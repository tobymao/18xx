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
        def home_hex_nodes(minor)
          return {} unless minor.minor?

          nodes = {}
          company = @game.private_company(minor)

          minor.coordinates.each do |coord|
            tile = @game.hex_by_id(coord).tile
            if tile.city_towns.empty?
              # Plain track in a home hex (or no tile or track). Create a
              # node for each track path to allow routes to be traced out
              # from this hex.
              tile.paths.each do |path|
                node = path_node(path, minor)
                nodes[node] = true if node
              end
            elsif tile.cities.size > 1
              tile.cities.each do |city|
                next unless city.reserved_by?(company)

                nodes[city] = true
              end
            else
              tile.city_towns.each { |ct| nodes[ct] = true }
            end
          end
          nodes
        end

        private

        def path_node(path, _entity)
          G1858::Part::PathNode.new(path)
        end
      end
    end
  end
end
