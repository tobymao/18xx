# frozen_string_literal: true

require_relative 'sea_crossing'

module Engine
  module Game
    module G18OE
      module SeaRoutes
        def ferry_track?(path)
          path.color == self.class::FERRY_TRACK_COLOR
        end

        def port_exit?(hex_id, exit)
          entry = self.class::PORTS.dig(hex_id, exit)
          exit.is_a?(Integer) && !entry.nil? && !entry[:dead_end]
        end

        def sea_traffic?(path)
          ferry_track?(path) || path.exits.any? { |exit| port_exit?(path.hex.id, exit) }
        end

        def route_path_shareable?(path)
          sea_traffic?(path)
        end

        def port_token_distance(phase)
          self.class::PORT_TOKEN_DISTANCE_BY_PHASE[phase.name]
        end

        def sea_channel_passage_cost
          self.class::SEA_CHANNEL_PASSAGE_COST
        end

        def ferry_links(hex_id, exit)
          ferries = self.class::PORTS.dig(hex_id, exit)&.dig(:ferries) || []
          ferries.select { |ferry| hex_by_id(ferry[:hex]) }
            .map { |ferry| [[ferry[:hex], ferry[:exit]], ferry[:distance]] }
        end

        def port_marker_hex(hex_id, exit)
          ports = self.class::PORTS[hex_id]
          return unless ports

          if exit == :offshore
            hex_by_id(ports.dig(:offshore, :hex))
          else
            hex_by_id(hex_id)&.all_neighbors&.[](exit)
          end
        end

        def sea_crossing(kind, from, to, nodes)
          units = if kind == :ferry
                    ferry_links(*from).find { |anchor, _distance| anchor == to }&.last
                  else
                    port_distance(from, to)
                  end
          hexes = [port_marker_hex(*from) || nodes[0].hex, port_marker_hex(*to) || nodes[1].hex]
          SeaCrossing.new(kind: kind, from: from, to: to, nodes: nodes, units: units, hexes: hexes, game: self)
        end

        def port_usable?(hex_id, exit, corporation)
          entry = self.class::PORTS.dig(hex_id, exit)
          hex = hex_by_id(hex_id)
          return false if !entry || !entry[:port] || entry[:dead_end] || !hex

          entry[:port] == :public || hex.tile.cities.any? { |city| city_tokened_by?(city, corporation) }
        end

        def port_anchors(node, corporation)
          hex_id = node.hex.id
          exits = (self.class::PORTS[hex_id] || {}).keys.select do |exit|
            port_usable?(hex_id, exit, corporation) && anchor_attaches?(node, [hex_id, exit])
          end
          exits.map { |exit| [hex_id, exit] }
        end

        def pathless_ferry_partner(anchor)
          links = ferry_links(*anchor)
          if anchor[1] == :offshore
            links.first&.first
          else
            links.find { |other, _distance| other[1] == :offshore }&.first
          end
        end

        def sea_chains(from_node, to_node, corporation)
          return [] if !corporation || from_node.hex == to_node.hex

          crossings = port_anchors(from_node, corporation).product(port_anchors(to_node, corporation)).map do |from, to|
            sea_crossing(:crossing, from, to, [from_node, to_node])
          end
          crossings = crossings.select(&:units).sort_by { |crossing| [crossing.units, crossing.id] }
          ferries = (self.class::PORTS[from_node.hex.id] || {}).keys.filter_map do |exit|
            from = [from_node.hex.id, exit]
            next unless anchor_attaches?(from_node, from)

            to = pathless_ferry_partner(from)
            sea_crossing(:ferry, from, to, [from_node, to_node]) if to && anchor_attaches?(to_node, to)
          end
          (crossings + ferries).map(&:chain)
        end

        def extra_node_chains(start_node, end_node, corporation)
          sea_chains(start_node, end_node, corporation)
        end

        def sea_legs(route)
          route.connection_data.filter_map { |connection| connection[:chain][:crossing] } + ferry_legs(route)
        end

        def sea_cost(route)
          corporation = route.corporation
          return 0 unless corporation

          legs = sea_legs(route)
          return 0 if legs.empty?

          tokens = legs.flat_map(&:nodes).uniq.select { |node| node.city? && city_tokened_by?(node, corporation) }
          token_legs = tokens.map { |token| legs.each_index.select { |index| legs[index].nodes.include?(token) } }
          cheapest_sea_cost(legs, token_legs, port_token_distance(route.phase) || 0, Array.new(legs.size, 0))
        end

        def route_train_distance(route, train)
          distance = train.distance
          return distance if distance.is_a?(Numeric)

          cost = sea_cost(route)
          return distance if cost.zero?

          distance.map do |row|
            next row unless row['nodes'].include?('city')

            reduced = row.dup
            reduced['visit'] = [(row['visit'] || row['pay']) - cost, 0].max
            reduced['pay'] = [row['pay'] - cost, 0].max
            reduced
          end
        end

        def route_distance(route)
          route.visited_stops.count { |stop| !stop.town? } + sea_cost(route)
        end

        def route_distance_str(route)
          stops = route.visited_stops.count { |stop| !stop.town? }
          cost = sea_cost(route)
          cost.positive? ? "#{stops} + #{cost} sea" : stops.to_s
        end

        def largest_train_level(corporation)
          route_trains(corporation).map { |train| distance(train).first }.max || 0
        end

        def sea_reachable?(corporation)
          !graph_for_entity(corporation).sea_network(corporation).landings.empty?
        end

        private

        def cheapest_sea_cost(legs, token_legs, reduction, counts)
          return legs.each_index.sum { |index| [legs[index].units - (reduction * counts[index]), 0].max } if token_legs.empty?

          rest = token_legs[1..]
          options = [nil] + token_legs.first
          options.map do |index|
            assigned = counts.dup
            assigned[index] += 1 if index
            cheapest_sea_cost(legs, rest, reduction, assigned)
          end.min
        end

        def check_sea_crossing_separation(route)
          chains = route.chains
          crossings = chains.each_index.select { |index| chains[index][:crossing]&.kind == :crossing }
          crossings.each_cons(2) do |first, second|
            between = chains[(first + 1)...second]
            next if between.any? { |chain| chain[:paths].map(&:hex).uniq.size > 1 || chain[:crossing]&.kind == :ferry }

            raise GameError, 'Sea crossings must be separated by a land hex side'
          end
        end

        def ferry_legs(route)
          legs = {}
          land_stretches(route).each do |paths|
            ferry_runs(paths).each do |before, run, after|
              leg = ferry_leg(before, run, after)
              legs[leg[0]] ||= leg[1] if leg
            end
          end
          legs.values
        end

        def land_stretches(route)
          stretches = [[]]
          route.connection_data.each do |connection|
            if connection[:chain][:crossing]
              stretches << []
              next
            end

            paths = connection[:chain][:paths]
            paths = paths.reverse if !paths.empty? && !paths[0].nodes.include?(connection[:left])
            stretches.last.concat(paths)
          end
          stretches
        end

        def ferry_runs(paths)
          runs = []
          index = 0
          while index < paths.size
            if ferry_track?(paths[index])
              finish = index
              finish += 1 while finish + 1 < paths.size && ferry_track?(paths[finish + 1])
              before = index.positive? ? paths[index - 1] : nil
              after = paths[finish + 1]
              runs << [before, paths[index..finish], after]
              index = finish + 1
            else
              index += 1
            end
          end
          runs
        end

        def ferry_anchor(land, ferry_path)
          return unless land

          land.exits.each do |exit|
            next unless land.hex.all_neighbors[exit]&.id == ferry_path.hex.id

            anchor = [land.hex.id, exit]
            return anchor unless ferry_links(*anchor).empty?
          end
          nil
        end

        def ferry_leg(before, run, after)
          from = ferry_anchor(before, run.first)
          to = ferry_anchor(after, run.last)
          entry =
            if from && to
              ferry_links(*from).find { |anchor, _distance| anchor == to }
            elsif from
              single_ferry_entry(ferry_links(*from), run.last)
            elsif to
              single_ferry_entry(ferry_links(*to), run.first)
            end
          return unless entry

          key = [from || to, entry[0]].map(&:to_s).sort
          nodes = [before&.nodes, after&.nodes].flatten.compact.uniq
          [key, SeaLeg.new(entry[1], nodes)]
        end

        def single_ferry_entry(links, ferry_path)
          adjacent = ferry_path.hex.all_neighbors.values.map(&:id) + [ferry_path.hex.id]
          links.find { |anchor, _distance| adjacent.include?(anchor[0]) } || links.first
        end

        def anchor_attaches?(node, anchor)
          return false unless node.hex.id == anchor[0]

          anchor[1] == :offshore ? node.city? : node.paths.any? { |path| path.exits.include?(anchor[1]) }
        end
      end
    end
  end
end
