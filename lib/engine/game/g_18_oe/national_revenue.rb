# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      class NationalRevenue
        def initialize(game, corporation)
          @game = game
          @corporation = corporation
        end

        def city_capacity
          @city_capacity ||= capacities.sum(&:first)
        end

        def doubled_capacity
          @doubled_capacity ||= trains.select { |train| train.multiplier == 2 }.sum { |train| @game.distance(train).first }
        end

        def town_capacity
          @town_capacity ||= capacities.sum(&:last)
        end

        def linked_city_values
          @linked_city_values ||= linked_values(city_stops, city_capacity)
        end

        def linked_town_values
          @linked_town_values ||= linked_values(town_stops, town_capacity)
        end

        def unlinked_city_count
          @unlinked_city_count ||= unlinked_count(city_stops, city_capacity, linked_city_values)
        end

        def unlinked_town_count
          @unlinked_town_count ||= unlinked_count(town_stops, town_capacity, linked_town_values)
        end

        def filler_city_count
          @filler_city_count ||= city_capacity - linked_city_values.size - unlinked_city_count
        end

        def filler_town_count
          @filler_town_count ||= town_capacity - linked_town_values.size - unlinked_town_count
        end

        def city_revenue
          items = linked_city_values + ([@game.national_filler_city_revenue] * filler_city_count)
          items.sum + items.sort.reverse.first(doubled_capacity).sum
        end

        def town_revenue
          linked_town_values.sum + (filler_town_count * @game.national_filler_town_revenue)
        end

        def pullman_revenue
          level = trains.filter_map(&:level).max
          level ? level * @game.pullman_bonus_per_level : 0
        end

        def total
          city_revenue + town_revenue + pullman_revenue
        end

        def city_stops
          @city_stops ||= zone_hexes.filter_map do |hex|
            nodes = hex.tile.cities + hex.tile.offboards
            next if nodes.empty?

            [hex, stop_value(nodes), nodes.any? { |node| linked?(node) } || sea_linked?(hex) || ferry_linked?(hex)]
          end
        end

        def town_stops
          @town_stops ||= zone_hexes.flat_map do |hex|
            hex.tile.towns.flat_map do |town|
              next [] if town == @game.hochberg_town

              town.stops.map { |stop| [hex, stop_value([stop]), linked?(town)] }
            end
          end
        end

        private

        def zone_hexes
          @zone_hexes ||= begin
            zone = @game.entity_track_rights_zone(@corporation)
            @game.class::NATIONAL_REGION_HEXES[zone].map { |id| @game.hex_by_id(id) }.compact
              .select { |hex| @game.region_for_hex(hex) == zone }
          end
        end

        def trains
          @trains ||= @corporation.trains.reject { |train| @game.pullman?(train) }
        end

        def capacities
          @capacities ||= trains.map { |train| @game.distance(train) }
        end

        def linked_values(stops, capacity)
          stops.select(&:last).map { |stop| stop[1] }.sort.reverse.first(capacity)
        end

        def unlinked_count(stops, capacity, linked)
          [capacity - linked.size, stops.count { |stop| !stop.last }].min
        end

        def stop_value(nodes)
          nodes.product(trains).map { |node, train| node.route_base_revenue(@game.phase, train) }.max || 0
        end

        def brandt_paths
          @brandt_paths ||= @game.brandt_paths
        end

        def linked?(node)
          node.walk(converging_path: false, skip_paths: brandt_paths) do |path, _, _|
            return true if path.nodes.any? { |other| other.hex != node.hex } || offshore_ferry?(path)
          end
          false
        end

        def offshore_ferry?(path)
          path.exits.any? do |exit|
            @game.ferry_links(path.hex.id, exit).any? { |(_, other_exit), _| other_exit == :offshore }
          end
        end

        def ferry_linked?(hex)
          @game.ferry_links(hex.id, :offshore).any? do |(other_id, exit), _|
            exit.is_a?(Integer) && @game.hex_by_id(other_id).paths[exit].any? { |path| !path.nodes.empty? }
          end
        end

        def sea_linked?(hex)
          return false if hex.tile.color != :red || !(ports = @game.class::PORTS[hex.id])

          exits = hex.tile.paths.flat_map(&:exits).uniq
          return false if exits.empty? || !exits.all? { |exit| ports.key?(exit) }

          seas = exits.select { |exit| ports[exit][:port] }.map { |exit| @game.port_sea_zone(hex.id, exit) }
          port_seas.any? { |id, sea| id != hex.id && seas.include?(sea) }
        end

        def port_seas
          @port_seas ||= begin
            found = []
            visited = {}
            visited_paths = {}
            zone_hexes.flat_map { |hex| hex.tile.cities }.reject { |city| city.paths.empty? }.each do |city|
              found << offshore_sea(city.hex)
              city.walk(visited: visited, visited_paths: visited_paths, converging_path: false) do |path, _, _|
                found.concat(arrow_seas(path))
                found.concat(path.nodes.select(&:city?).map { |node| offshore_sea(node.hex) })
              end
            end
            found.compact.uniq
          end
        end

        def arrow_seas(path)
          ports = @game.class::PORTS[path.hex.id] || {}
          path.exits.select { |exit| ports.dig(exit, :port) }.map { |exit| [path.hex.id, @game.port_sea_zone(path.hex.id, exit)] }
        end

        def offshore_sea(hex)
          return unless @game.class::PORTS.dig(hex.id, :offshore, :port)

          [hex.id, @game.port_sea_zone(hex.id, :offshore)]
        end
      end
    end
  end
end
