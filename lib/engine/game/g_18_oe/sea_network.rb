# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      class SeaNetwork
        ZONE_UNITS = 2

        attr_reader :anchors

        def initialize(game, corporation)
          @game = game
          @corporation = corporation
          @token_cities = game.hexes.flat_map { |hex| hex.tile.cities }
            .select { |city| game.city_tokened_by?(city, corporation) }
          @token_hex_ids = @token_cities.map { |city| city.hex.id }.uniq
          @parent = {}
          @island_ids = {}
          build_islands!
          build_anchors!
        end

        def usable?(hex_id, exit)
          data = @anchors[[hex_id, exit]]
          return false unless data
          return true unless data[:port]

          data[:port] == :public || @token_hex_ids.include?(hex_id)
        end

        def ferry_links(hex_id, exit)
          data = @anchors[[hex_id, exit]]
          return [] unless data

          (data[:ferries] || []).select { |ferry| @game.hex_by_id(ferry[:hex]) }
            .map { |ferry| [[ferry[:hex], ferry[:exit]], ferry[:distance]] }
        end

        def island_of(path)
          @island_ids[path]
        end

        def anchor_island_ids(hex_id, exit)
          hex = @game.hex_by_id(hex_id)
          paths = if exit == :offshore
                    hex.tile.cities.flat_map(&:paths)
                  else
                    hex.paths[exit] || []
                  end
          paths.map { |path| island_of(path) }.compact.uniq
        end

        private

        def build_islands!
          land_paths = @game.hexes.reject { |hex| @game.sea_zone(hex.id) }
            .flat_map { |hex| hex.tile.paths.reject(&:terminal?) }
          land_paths.each { |path| @parent[path] = path }
          land_paths.each do |path|
            adjacent_paths(path).each { |other| union(path, other) if @parent.key?(other) }
          end
          ids = {}
          land_paths.each { |path| @island_ids[path] = (ids[find(path)] ||= ids.size) }
        end

        def adjacent_paths(path)
          adjacent = path.junction ? path.junction.paths.dup : []
          hex = path.hex
          path.exits.each do |edge|
            next unless (neighbor = hex.neighbors[edge])

            adjacent.concat(neighbor.paths[hex.invert(edge)])
          end
          path.nodes.each do |node|
            adjacent.concat(node.paths) if !node.city? || !node.blocks?(@corporation)
          end
          adjacent
        end

        def build_anchors!
          @anchors = {}
          @game.class::PORTS.each do |hex_id, exits|
            next unless @game.hex_by_id(hex_id)

            exits.each do |exit, data|
              next if data[:dead_end]

              @anchors[[hex_id, exit]] = data
            end
          end
        end

        def find(path)
          while (parent = @parent[path]) != path
            @parent[path] = @parent[parent]
            path = parent
          end
          path
        end

        def union(first, second)
          root_first = find(first)
          root_second = find(second)
          @parent[root_second] = root_first unless root_first == root_second
        end
      end
    end
  end
end
