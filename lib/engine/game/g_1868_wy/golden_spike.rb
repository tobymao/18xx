# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module GoldenSpike
        SPIKE = {
          northern: {
            start_desc: 'an Eastern offboard',
            start_hex_ids: %w[C27 E27 G27 K27 M27 N26],
            end_hex_meta: {
              'A9' => {
                exits: [1],
                bonus: 120,
                tile: 'Billings-a-0',
                west: 40,
                added_revenue: [10, 20, 20, 30],
                location_name: 'Billings',
              },
              'A11' => { exits: [1], bonus: 120, tile: 'Billings-b-0', west: 40, added_revenue: [10, 20, 20, 30] },
              'A15' => { exits: [1], bonus: 60, tile: 'Billings-c-0', west: 20, added_revenue: [10, 20, 20, 30] },
            },
            spike_hex_id: 'A1',
            event_calls: [],
          },

          golden: {
            start_desc: 'Omaha',
            start_hex_ids: ['M27'],
            end_hex_meta: {
              'M1' => { exits: [2], bonus: 180, tile: 'Ogden-0', west: 50, added_revenue: [0, 20, 30, 30] },
            },
            spike_hex_id: 'L0',
            event_calls: [:close_hell_on_wheels!],
          },
        }.freeze

        def close_hell_on_wheels!
          hell_on_wheels.close!
          @log << "#{hell_on_wheels.name} closes"
        end

        def setup_spikes
          SPIKE.keys.each do |spike|
            instance_variable_set("@#{spike}_spike_complete", false)

            SPIKE[spike][:hex] = nil
            SPIKE[spike][:spike_stop] = nil
            SPIKE[spike][:start_hexes] = nil
            SPIKE[spike][:end_hexes] = nil
          end

          hex_by_id('A9').neighbors[1] = hex_by_id('A1')
          hex_by_id('A11').neighbors[1] = hex_by_id('A1')
          hex_by_id('A15').neighbors[1] = hex_by_id('A1')
        end

        def spike_complete?(spike)
          instance_variable_get("@#{spike}_spike_complete")
        end

        def complete_spike!(spike)
          instance_variable_set("@#{spike}_spike_complete", true)
        end

        def check_spikes!(routes)
          SPIKE.keys.each { |spike| check_spike!(spike, routes) }
        end

        def check_spike!(spike, routes)
          return if spike_complete?(spike)

          event_spike!(spike) if routes.any? { |r| spike_route?(spike, r) }
        end

        def spike_start_hexes(spike)
          SPIKE[spike][:start_hexes] ||= SPIKE[spike][:start_hex_ids].map { |hex_id| hex_by_id(hex_id) }
        end

        def spike_end_hexes(spike)
          SPIKE[spike][:end_hexes] ||= SPIKE[spike][:end_hex_meta].keys.map { |hex_id| hex_by_id(hex_id) }
        end

        def spike_hex(spike)
          SPIKE[spike][:hex] ||= hex_by_id(SPIKE[spike][:spike_hex_id])
        end

        def spike_hex?(hex)
          SPIKE.keys.find { |spike| hex == spike_hex(spike) }
        end

        def spike_stop(spike)
          SPIKE[spike][:spike_stop] ||= spike_hex(spike).tile.towns.first
        end

        def spike_start_hex_on_route(spike, _route, stops)
          stops.find { |stop| spike_start_hexes(spike).include?(stop.hex) }&.hex
        end

        def spike_end_hex_on_route(spike, _route, stops)
          stops.find { |stop| spike_end_hexes(spike).include?(stop.hex) }&.hex
        end

        def spike_hex_available?(spike, &block)
          spike_start_hexes(spike).any?(&block) && spike_end_hexes(spike).any?(&block)
        end

        def spike_end_hex_path_to_spike(spike, route, stops)
          hex = spike_end_hex_on_route(spike, route, stops)
          hex.tile.paths.find { |p| p.exits == SPIKE[spike][:end_hex_meta][hex.id][:exits] }
        end

        def spike_end_hex_entry_paths(spike, route, stops)
          hex = spike_end_hex_on_route(spike, route, stops)
          hex.tile.paths.reject { |p| p.exits == SPIKE[spike][:end_hex_meta][hex.id][:exits] }
        end

        def spike_route?(spike, route)
          return false if spike_complete?(spike)

          found_start = found_end = found_spike = false
          route.visited_stops.each do |stop|
            hex = stop.hex
            found_start = true if !found_start && spike_start_hexes(spike).include?(hex)
            found_end = true if !found_end && spike_end_hexes(spike).include?(hex)
            found_spike = true if !found_spike && spike_hex(spike) == hex
          end

          found_start && found_end && found_spike
        end

        def completing_spike_on_other_route?(spike, route, _stops)
          return false if spike_complete?(spike)
          return false if spike_route?(spike, route)

          other_routes = route.routes.reject { |r| r == route }
          other_routes.any? { |r| spike_route?(spike, r) }
        end

        def check_connected(route, corporation)
          return if SPIKE.keys.find do |spike|
            next unless route.visited_stops.include?(spike_stop(spike))

            unless spike_start_hex_on_route(spike, route, route.visited_stops)
              start_desc = SPIKE[spike][:start_desc]
              raise GameError, "Route to #{spike.to_s.capitalize} Spike must start from #{start_desc}"
            end

            route.ordered_paths.each_cons(2).all? do |a, b|
              next true if a.connects_to?(b, corporation)

              if a.hex == b.hex
                path_to_spike = spike_end_hex_path_to_spike(spike, route, route.visited_stops)
                entry_paths = spike_end_hex_entry_paths(spike, route, route.visited_stops)

                (a == path_to_spike && entry_paths.include?(b)) ||
                  (b == path_to_spike && entry_paths.include?(a))
              else
                spike_hex_path = [a, b].find { |p| p.hex == spike_hex(spike) }
                end_hex_path = [a, b].find { |p| p == spike_end_hex_path_to_spike(spike, route, route.visited_stops) }
                spike_hex_path && end_hex_path
              end
            end
          end

          return if route.ordered_paths.each_cons(2).all? { |a, b| a.connects_to?(b, corporation) }

          raise GameError, 'Route is not connected'
        end

        def spike_route_bonuses(route, stops)
          SPIKE.keys.each do |spike|
            bonus = spike_completion_bonus(spike, route, stops)
            return bonus if bonus[:revenue].positive?

            bonus = spike_new_end_tile_bonus(spike, route, stops)
            return bonus if bonus[:revenue].positive?
          end

          { revenue: 0 }
        end

        def spike_completion_bonus(spike, route, stops)
          if spike_route?(spike, route)
            hex = spike_end_hex_on_route(spike, route, stops)
            revenue = SPIKE[spike][:end_hex_meta][hex.id][:bonus]
            { revenue: revenue, description: "#{spike.to_s.capitalize} Spike" }
          else
            { revenue: 0 }
          end
        end

        # when a Spike is complete, the train completing it runs its route
        # first, then the offboard hex is immediately upgraded, and other trains
        # running on that same turn get the new tile's revenue and East-West
        # bonus (if applicable); with this game engine, the route revenues must
        # be computed together, before laying the new tile, so calculate the
        # bonus the new tile would give here rather than actually laying and
        # using the new tile
        def spike_new_end_tile_bonus(spike, route, stops)
          return { revenue: 0 } if spike_complete?(spike)

          found_end = found_spike = false
          stops.each do |stop|
            found_end = true if !found_end && spike_end_hexes(spike).include?(stop.hex)
            found_spike = true if !found_spike && spike_hex(spike) == stop.hex
          end
          return { revenue: 0 } if !found_end || found_spike

          return { revenue: 0 } unless completing_spike_on_other_route?(spike, route, stops)

          hex = spike_end_hex_on_route(spike, route, stops)
          hex_meta = SPIKE[spike][:end_hex_meta][hex.id]
          added_revenues = hex_meta[:added_revenue]
          revenue =
            case @phase.name
            when '2'
              added_revenues[0]
            when '3', '4'
              added_revenues[1]
            when '5', '6'
              added_revenues[2]
            when '7', '8'
              added_revenues[3]
            end

          if (east = stops.find { |stop| stop.groups.include?('E') })
            east_rev = east.tile.icons.sum { |icon| icon.name.to_i }
            west_rev = hex_meta[:west]
            { revenue: revenue + east_rev + west_rev, description: "new #{hex.tile.location_name} tile + E/W" }
          else
            { revenue: revenue, description: "new #{hex.tile.location_name} tile" }
          end
        end

        def event_spike!(spike)
          @log << "-- Event: the #{spike.to_s.capitalize} Spike has been driven --"

          # remove the spike stop and name
          spike_meta = SPIKE[spike]
          hex = spike_hex(spike)
          hex.lay(tile_by_id("#{hex.id}-spike-0"))
          name = hex.tile.location_name.split(' /').first
          hex.tile.location_name = name
          @log << "the #{spike.to_s.capitalize} Spike stop is no longer available at #{name} (#{hex.id})"

          # upgrade the western offboard tile(s)
          spike_meta[:end_hex_meta].each do |hex_id, meta|
            hex = hex_by_id(hex_id)
            hex.lay(tile_by_id(meta[:tile]))

            name = hex.tile.location_name || meta[:location_name]
            @log << "#{name} (#{hex.id}) has been upgraded"
          end

          # any additional function calls listed
          spike_meta[:event_calls].each { |fn| send(fn) }

          complete_spike!(spike)
        end
      end
    end
  end
end
