# frozen_string_literal: true

require_relative 'sea_crossing'

module Engine
  module Game
    module G18OE
      SeaPoolNeed = Struct.new(:cost, :need, :pa_eligible, :h_eligible)
      RouterConnection = Struct.new(:connection_data, :corporation, :phase)

      module SeaRoutes
        def ferry_track?(path)
          path.color == self.class::FERRY_TRACK_COLOR
        end

        def sea_exit?(hex_id, exit)
          entry = self.class::PORTS.dig(hex_id, exit)
          exit.is_a?(Integer) && !entry.nil? && !entry[:dead_end]
        end

        def sea_traffic?(path)
          ferry_track?(path) || path.exits.any? { |exit| sea_exit?(path.hex.id, exit) }
        end

        def shared_track?(path)
          sea_traffic?(path)
        end

        def sea_reduction(phase)
          self.class::SEA_REDUCTION_BY_PHASE[phase.name]
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

        def usable_ports(node, corporation)
          hex_id = node.hex.id
          exits = (self.class::PORTS[hex_id] || {}).keys.select do |exit|
            port_usable?(hex_id, exit, corporation) && anchor_attaches?(node, [hex_id, exit])
          end
          exits.map { |exit| [hex_id, exit] }
        end

        def offshore_ferry_end(anchor)
          links = ferry_links(*anchor)
          if anchor[1] == :offshore
            links.first&.first
          else
            links.find { |other, _distance| other[1] == :offshore }&.first
          end
        end

        def sea_links(from_node, to_node, corporation)
          return [] if !corporation || from_node.hex == to_node.hex

          crossings = usable_ports(from_node, corporation).product(usable_ports(to_node, corporation)).map do |from, to|
            sea_crossing(:crossing, from, to, [from_node, to_node])
          end
          crossings = crossings.select(&:units).sort_by { |crossing| [crossing.units, crossing.id] }
          ferries = (self.class::PORTS[from_node.hex.id] || {}).keys.filter_map do |exit|
            from = [from_node.hex.id, exit]
            next unless anchor_attaches?(from_node, from)

            to = offshore_ferry_end(from)
            sea_crossing(:ferry, from, to, [from_node, to_node]) if to && anchor_attaches?(to_node, to)
          end
          (crossings + ferries).map(&:chain)
        end

        def route_links(from_node, to_node, corporation)
          sea_links(from_node, to_node, corporation)
        end

        def sea_legs(route)
          route.shared_cache[:sea_legs] ||= connection_sea_legs(route.connection_data)
        end

        def connection_sea_legs(connection_data)
          connection_data.filter_map { |connection| connection[:chain][:crossing] } +
            ferry_legs(connection_data)
        end

        def auto_router_connection_cost(connection_data, corporation)
          legs = connection_sea_legs(connection_data)
          return 0 if legs.empty?

          route = RouterConnection.new(connection_data, corporation, phase)
          cost = cheapest_sea_cost(route, legs)
          [cost - sea_pool_total(corporation, phase), 0].max
        end

        def sea_pool(corporation, phase)
          owned = port_authorities(corporation)
          pool = port_authority_seas.to_h { |sea| [sea, owned.include?(sea) ? port_authority_reduction : 0] }
          pool[:h] = minor_h_reduction?(corporation) ? (sea_reduction(phase) || 0) : 0
          pool
        end

        def sea_pool_need(route, legs = nil)
          route.shared_cache[:sea_pool_need] ||= begin
            legs ||= sea_legs(route)
            pool = sea_pool(route.corporation, route.phase)
            reduction = sea_reduction(route.phase) || 0
            needs = sea_leg_assignments(route, legs).map do |assignment, tokens|
              assigned_sea_pool_need(route, legs, tokens, assignment, reduction, pool)
            end
            coverable = needs.select { |need| sea_pool_coverable?([need], pool) }
            (coverable.empty? ? needs : coverable).each_with_index.min_by { |need, index| [need.cost, index] }.first
          end
        end

        def sea_pool_coverable?(needs, pool)
          return true if needs.empty?
          return false if needs.any? { |need| need.need > need.cost }

          first = needs.first
          rest = needs[1..]
          seas = port_authority_seas
          options = seas.map { |sea| (0..[first.pa_eligible[sea], pool[sea]].min).to_a }
          options << (0..[first.h_eligible, pool[:h]].min).to_a
          options.first.product(*options[1..]).any? do |split|
            next false unless split.sum == first.need

            remaining = pool.dup
            seas.each_with_index { |sea, index| remaining[sea] -= split[index] }
            remaining[:h] -= split.last
            sea_pool_coverable?(rest, remaining)
          end
        end

        def sea_pool_total(corporation, phase)
          sea_pool(corporation, phase).values.sum
        end

        def sea_pool_allocation(routes)
          legs = routes.to_h { |route| [route, route.corporation ? sea_legs(route) : []] }
          needs = routes.reject { |route| legs[route].empty? }.to_h { |route| [route, sea_pool_need(route, legs[route])] }
          needy = needs.keys.select { |route| needs[route].need.positive? }
          return routes.to_h { |route| [route, true] } if needy.empty?

          pool = sea_pool(needy.first.corporation, needy.first.phase)
          return routes.to_h { |route| [route, true] } if sea_pool_coverable?(needy.map { |route| needs[route] }, pool)

          values = needy.to_h { |route| [route, covered_sea_pool_revenue(route, needs[route])] }
          best = (0..needy.size).flat_map { |size| needy.combination(size).to_a }
            .select { |subset| sea_pool_coverable?(subset.map { |route| needs[route] }, pool) }
            .min_by { |subset| [-subset.sum { |route| values[route] }, -subset.size, subset.map { |route| needy.index(route) }] }
          routes.to_h { |route| [route, !needy.include?(route) || best.include?(route)] }
        end

        def sea_distance(route)
          return 0 unless route.corporation

          unless @sea_pool_covered
            cached = route.shared_cache[:sea_distance]
            return cached[1] if cached && cached[0].equal?(route.routes)
          end

          legs = sea_legs(route)
          return 0 if legs.empty?

          pool_total = sea_pool_total(route.corporation, route.phase)
          distance = if @sea_pool_covered&.key?(route)
                       need = sea_pool_need(route, legs)
                       need.cost - need.need
                     elsif route.router_cost && pool_total.zero?
                       route.router_cost
                     elsif pool_total.zero?
                       cheapest_sea_cost(route, legs)
                     else
                       need = sea_pool_need(route, legs)
                       if need.need.positive?
                         routes = route.routes.include?(route) ? route.routes : [route]
                         sea_pool_allocation(routes)[route] ? need.cost - need.need : need.cost
                       else
                         need.cost
                       end
                     end

          route.shared_cache[:sea_distance] = [route.routes, distance] unless @sea_pool_covered
          distance
        end

        def route_train_distance(route, train)
          distance = train_distance(train)
          return distance if distance.is_a?(Numeric)

          cost = sea_distance(route)
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
          counted_stops(route).count { |stop| !stop.town? } + sea_distance(route)
        end

        def route_distance_str(route)
          stops = counted_stops(route).count { |stop| !stop.town? }
          cost = sea_distance(route)
          cost.positive? ? "#{stops} + #{cost} sea" : stops.to_s
        end

        def largest_city_limit(corporation)
          limit = route_trains(corporation).map { |train| distance(train).first }.max || 0
          one_plus_one_marker?(corporation) ? limit + 1 : limit
        end

        def sea_boundary_zones(from_sea, to_sea)
          @sea_boundary_zones ||= {}
          @sea_boundary_zones[[from_sea, to_sea]] ||= self.class::SEA_ZONES.keys.select do |zone|
            sea(zone) == from_sea && sea_zone_neighbors[zone].any? { |other| sea(other) == to_sea }
          end
        end

        def sea_crossing_areas(from_port, to_port, units)
          from_zone = port_sea_zone(*from_port)
          to_zone = port_sea_zone(*to_port)
          from_sea = sea(from_zone)
          to_sea = sea(to_zone)
          return [from_sea] * units if from_sea == to_sea

          boundary = sea_boundary_zones(from_sea, to_sea).min_by do |zone|
            sea_zone_distance(from_zone, zone) + sea_zone_distance(zone, to_zone)
          end
          from_count = [[boundary ? sea_zone_distance(from_zone, boundary) : units, units].min, 0].max
          ([from_sea] * from_count) + ([to_sea] * (units - from_count))
        end

        def check_sea_pool_coverage!(routes)
          first = routes.first
          return if !first&.corporation || sea_pool_total(first.corporation, first.phase).zero?
          return unless sea_pool_allocation(routes).value?(false)

          raise GameError, 'Port authority and Minor H reductions do not cover every train'
        end

        def sea_connectivityable?(corporation)
          !graph_for_entity(corporation).sea_connectivity(corporation).landings.empty?
        end

        private

        def covered_sea_pool_revenue(route, need)
          previous = @sea_pool_covered
          @sea_pool_covered = { route => need }
          revenue_for(route, compute_stops(route))
        rescue GameError
          0
        ensure
          @sea_pool_covered = previous
        end

        def sea_leg_assignments(route, legs)
          tokens = legs.flat_map(&:nodes).uniq.select { |node| node.city? && port_token_city?(node, route.corporation) }
          choices = tokens.map { |token| [nil] + legs.each_index.select { |index| legs[index].nodes.include?(token) } }
          assignments = choices.empty? ? [[]] : choices.first.product(*choices[1..])
          assignments.map { |assignment| [assignment, tokens] }
        end

        def cheapest_sea_cost(route, legs)
          reduction = sea_reduction(route.phase) || 0
          sea_leg_assignments(route, legs).map do |assignment, tokens|
            legs.each_with_index.sum do |leg, index|
              at_leg = tokens.each_index.select { |token_index| assignment[token_index] == index }.map { |i| tokens[i] }
              zones = remaining_leg_zones(leg, at_leg, reduction)
              zones.is_a?(Array) ? zones.size : zones
            end
          end.min
        end

        def assigned_sea_pool_need(route, legs, tokens, assignment, reduction, pool)
          remaining = legs.each_with_index.map do |leg, index|
            at_leg = tokens.each_index.select { |token_index| assignment[token_index] == index }.map { |i| tokens[i] }
            remaining_leg_zones(leg, at_leg, reduction)
          end
          cost = remaining.sum { |zones| zones.is_a?(Array) ? zones.size : zones }
          crossing_zones = remaining.select { |zones| zones.is_a?(Array) }.flatten
          pa_eligible = port_authority_seas.to_h { |sea| [sea, [pool[sea], crossing_zones.count(sea)].min] }
          h_eligible = [pool[:h], cost].min
          stops = counted_stops(route).count { |stop| !stop.town? }
          SeaPoolNeed.new(cost, [stops + cost - city_limit_level(route.train), 0].max, pa_eligible, h_eligible)
        end

        def remaining_leg_zones(leg, tokens_at_leg, reduction)
          areas = leg.areas
          return [leg.units - (reduction * tokens_at_leg.size), 0].max unless areas

          front = tokens_at_leg.include?(leg.nodes[0]) ? reduction : 0
          back = tokens_at_leg.include?(leg.nodes[1]) ? reduction : 0
          trimmed = areas.drop(front)
          trimmed.first([trimmed.size - back, 0].max)
        end

        def city_limit_level(train)
          distance = train_distance(train)
          return distance if distance.is_a?(Numeric)

          (distance.find { |row| row['nodes'].include?('city') } || distance.first)['pay']
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

        def ferry_legs(connection_data)
          legs = {}
          land_stretches(connection_data).each do |paths|
            ferry_runs(paths).each do |before, run, after|
              leg = ferry_leg(before, run, after)
              legs[leg[0]] ||= leg[1] if leg
            end
          end
          legs.values
        end

        def land_stretches(connection_data)
          stretches = [[]]
          connection_data.each do |connection|
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
          [key, FerryLeg.new(entry[1], nodes)]
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
