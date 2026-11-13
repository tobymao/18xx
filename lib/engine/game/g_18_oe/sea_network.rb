# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      class SeaNetwork
        SEA_ZONE_DISTANCE = 2

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
          build_edges!
          @costs = shortest_costs(start_nodes)
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
                    hex.tile.cities.reject { |city| city.blocks?(@corporation) }.flat_map(&:paths)
                  else
                    hex.paths[exit] || []
                  end
          paths.map { |path| island_of(path) }.compact.uniq
        end

        def hex_cost(hex)
          return 0 if @token_hex_ids.include?(hex.id)

          cheapest(island_costs(hex.tile.paths + neighbor_paths(hex, hex.neighbors.keys)))
        end

        def anchor_costs(hex)
          @anchors.each_with_object({}) do |((hex_id, exit), data), costs|
            next if hex_id != hex.id || !data[:port] || !usable?(hex_id, exit)

            costs[exit] = @costs[[hex_id, exit]] if @costs.key?([hex_id, exit])
          end
        end

        def tile_cost(hex, tile)
          return 0 if @token_hex_ids.include?(hex.id)

          paths = hex.tile.paths + neighbor_paths(hex, tile.exits)
          anchors = @anchors.keys.select { |hex_id, exit| hex_id == hex.id && (exit == :offshore || tile.exits.include?(exit)) }
          cheapest(island_costs(paths) + anchors.map { |key| @costs[key] })
        end

        def city_cost(city)
          return 0 if @token_cities.include?(city)

          offshore = @costs[[city.hex.id, :offshore]] if @anchors.key?([city.hex.id, :offshore])
          cheapest(island_costs(city.paths) + [offshore])
        end

        def landings
          landing_anchors.each_with_object({}) do |(hex_id, exit), result|
            hex = @game.hex_by_id(hex_id)
            edges = exit == :offshore ? hex.neighbors.keys : [exit]
            edges.each { |edge| (result[hex] ||= {})[edge] = true }
          end
        end

        def landing_nodes
          landing_anchors.flat_map do |hex_id, exit|
            tile = @game.hex_by_id(hex_id).tile
            nodes = exit == :offshore ? tile.cities : tile.paths.select { |path| path.exits.include?(exit) }.flat_map(&:nodes)
            nodes.reject { |node| node.blocks?(@corporation) }
          end.uniq
        end

        private

        def landing_anchors
          @anchors.keys.select do |hex_id, exit|
            @anchors[[hex_id, exit]][:port] && usable?(hex_id, exit) && @costs.key?([hex_id, exit])
          end
        end

        def neighbor_paths(hex, edges)
          edges.flat_map do |edge|
            neighbor = hex.neighbors[edge]
            neighbor ? neighbor.paths[hex.invert(edge)] || [] : []
          end
        end

        def island_costs(paths)
          paths.map { |path| island_of(path) }.compact.uniq.map { |id| @costs[id] }
        end

        def cheapest(costs)
          costs.compact.min
        end

        def build_edges!
          @edges = Hash.new { |hash, key| hash[key] = [] }
          @anchors.each do |(hex_id, exit), data|
            key = [hex_id, exit]
            anchor_island_ids(hex_id, exit).each { |id| link!(key, id, 0) }
            ferry_links(hex_id, exit).each { |other, distance| link!(key, other, distance) if @anchors.key?(other) }
            zone = data[:port] && usable?(hex_id, exit) && @game.port_sea_zone(hex_id, exit)
            next unless zone

            @edges[key] << [zone, SEA_ZONE_DISTANCE]
            @edges[zone] << [key, 0]
          end
          @game.sea_zone_neighbors.each do |zone, others|
            others.each { |other| @edges[zone] << [other, SEA_ZONE_DISTANCE] }
          end
        end

        def link!(first, second, weight)
          @edges[first] << [second, weight]
          @edges[second] << [first, weight]
        end

        def start_nodes
          starts = @token_cities.flat_map { |city| city.paths.map { |path| island_of(path) } }.compact
          @token_cities.each do |city|
            hex_id = city.hex.id
            starts << [hex_id, :offshore] if @anchors.key?([hex_id, :offshore])
            city.paths.flat_map(&:exits).uniq.each { |exit| starts << [hex_id, exit] if @anchors.key?([hex_id, exit]) }
          end
          starts.uniq
        end

        def shortest_costs(starts)
          costs = starts.to_h { |node| [node, 0] }
          settled = {}
          while (node = costs.keys.reject { |key| settled[key] }.min_by { |key| costs[key] })
            settled[node] = true
            @edges[node].each do |other, weight|
              candidate = costs[node] + weight
              costs[other] = candidate if !settled[other] && (!costs.key?(other) || candidate < costs[other])
            end
          end
          costs
        end

        def build_islands!
          land_paths = @game.hexes.flat_map do |hex|
            hex.tile.paths.reject { |path| path.terminal? || (@game.sea_zone(hex.id) && path.nodes.empty?) }
          end
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
            adjacent.concat(node.paths) unless node.blocks?(@corporation)
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
