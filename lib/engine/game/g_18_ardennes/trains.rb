# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Trains
        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, '5-share': 4, '10-share': 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, '5-share': 4, '10-share': 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 2, '5-share': 3, '10-share': 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 2, '5-share': 2, '10-share': 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: %w[6 4D],
            train_limit: { minor: 2, '5-share': 2, '10-share': 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            obsolete_on: '4',
            rusts_on: '4',
            distance: [{ 'nodes' => %w[city], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            num: 15,
            price: 100,
          },
          {
            name: '3',
            num: 7,
            rusts_on: '6',
            distance: [{ 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 200,
          },
          {
            name: '4',
            num: 5,
            distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 400,
          },
          {
            name: '5',
            num: 3,
            distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 500,
          },
          {
            name: '6',
            num: 30,
            distance: [{ 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            variants: [
              {
                name: '4D',
                distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 99 },
                           { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
                multiplier: 2,
                price: 800,
                discount: {
                  '4' => 200,
                  '5' => 200,
                  '6' => 200,
                },
              },
            ],
          },
        ].freeze

        FERRY_BONUS = {
          '2': 20,
          '3': 30,
          '4': 40,
          '5': 50,
          '6': 60,
          '4D': 80,
        }.freeze

        FERRY_PORTS = {
          'E3' => %w[E5],
          'F2' => %w[F4 G3],
          'G1' => %w[G3],
        }.freeze

        def check_other(route)
          # A single city and a port off-board area is not a valid route.
          return if visited_stops(route).count { |stop| !stop.offboard? } > 1

          raise RouteTooShort, 'Route must have at least 2 stops'
        end

        def visited_stops(route)
          return super unless route.train.name == '4D'

          # 4D trains ignore towns completely.
          super.reject(&:town?)
        end

        def route_distance_str(route)
          towns = route.visited_stops.count(&:town?)
          cities = route.visited_stops.count(&:city?)
          port = route.visited_stops.any?(&:offboard?)

          distance = port ? '⚓' : ''
          distance += cities.to_s
          distance += "+#{towns}" if towns.positive? && route.train.name != '4D'
          distance
        end

        def revenue_for(route, stops)
          # TODO: (maybe) I suspect that the calculation of the revenue for a
          # long 4D route is inefficient, and might cause slow auto-routing.
          # It might be worth pruning out some of the stops from the route
          # to avoid calling this method so often.
          super +
            ferry_bonus(route, stops) +
            mine_bonus(route, stops) +
            tee_bonus(route, stops)
        end

        def submit_revenue_str(routes, _show_subsidy)
          train_revenue = routes_revenue(routes)
          fort_revenue = fort_bonus(routes)

          return format_revenue_currency(train_revenue) if fort_revenue.zero?

          "#{format_revenue_currency(train_revenue)} + " \
            "#{format_revenue_currency(fort_revenue)} fort bonus"
        end

        def ferry_bonus(route, stops)
          return 0 unless stops.any?(&:offboard?)

          bonus = FERRY_BONUS[route.train.name]
          return bonus unless route.train.name == '4D'

          # For 4D trains we need to make sure that both the ferry off-board
          # area and the adjacent port are scored as part of the route.
          ferry_port_route?(route, stops) ? bonus : 0
        end

        def mine_bonus(route, stops)
          stops.inject(0) do |revenue, stop|
            coord = stop.hex.coordinates
            next revenue if !Map::MINE_HEXES.include?(coord) ||
              !route.train.owner.assignments.key?(coord)

            revenue + stop.route_revenue(route.phase, route.train)
          end
        end

        def tee_bonus(route, stops)
          north_south = stops.intersect?(north_nodes) &&
                        stops.intersect?(south_nodes)
          east_west = stops.intersect?(east_nodes) &&
                      stops.intersect?(west_nodes)
          return 0 if !north_south && !east_west

          tokens = route.train.owner.placed_tokens
                   .map(&:city).intersection(stops)
          token_bonus = (north_south && east_west ? 60 : 30)
          tokens.size * token_bonus * (route.train.multiplier || 1)
        end

        def extra_revenue(_entity, routes)
          fort_bonus(routes)
        end

        def fort_bonus(routes)
          return 0 if routes.empty?

          corporation = routes.first.train.owner
          forts = fort_tokens(corporation)
          return 0 if forts.zero?

          10 * forts * fort_destinations(corporation)
        end

        def must_buy_train?(entity)
          return super unless entity.type == :minor

          # Minors are not obliged to buy a train, and cannot enter emergency
          # fund raising.
          false
        end

        # Before rusting, check if this train individual should rust.
        def rust?(train, purchased_train)
          return false unless super
          return true unless train.name == '2'
          return true if train.owner == @depot

          operated_this_round?(train.owner)
        end

        # Before obsoleting, check if this specific train should obsolete.
        def obsolete?(train, purchased_train)
          super && !operated_this_round?(train.owner)
        end

        def operated_this_round?(entity)
          return false unless entity&.corporation?

          entity.operating_history.include?([@turn, @round.round_num])
        end

        # The 4D is only buyable by 10-share public companies that do not
        # already own a 4D.
        def can_buy_4d?(corporation)
          return false unless corporation.corporation?
          return false unless corporation.type == :'10-share'

          corporation.trains.none? { |train| train.name == '4D' }
        end

        def discountable_trains_for(corporation)
          # The 4D is the only train that can be bought with a discount.
          # Make sure the currently operating entity is allowed to buy one.
          return [] unless can_buy_4d?(corporation)

          super
        end

        # Checks for overlapping routes.
        # Throws an error if either a single route is reusing track, or two
        # different routes are using the same section of track.
        # 4D trains and normal trains can run along the same track, so no
        # error is thrown when these routes overlap.
        def check_overlap(routes)
          tracks_by_type = Hash.new { |h, k| h[k] = [] }

          routes.each do |route|
            route.paths.each do |path|
              a = path.a
              b = path.b

              tracks = tracks_by_type[train_type(route.train)]
              tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
              tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?
            end
          end

          tracks_by_type.each do |_type, tracks|
            tracks.group_by(&:itself).each do |k, v|
              raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
            end
          end
        end

        # This is called from Route.touch_node, when adding nodes to a route.
        # Any paths returned from this method cannot be added to the route.
        # As the 4D train can reuse track that other trains are running along,
        # this implementation only returns paths used by trains of the same
        # 'type' (normal/4D).
        def compute_other_paths(routes, route)
          routes.reject { |r| r == route || train_type(r.train) != train_type(route.train) }
                .map(&:paths)
                .flatten
        end

        private

        def train_type(train)
          train.name == '4D' ? :express : :normal
        end

        # Checks whether the scored stops on a route includes boths a ferry
        # off-board hex and its neighbouring port city, and that there is a
        # direct route between the two.
        def ferry_port_route?(route, stops)
          ferries = stops.select(&:offboard?)
          stops.any? do |port|
            ferries.any? do |ferry|
              port_hexes = FERRY_PORTS[ferry.hex.coordinates]
              next false unless port_hexes.include?(port.hex.coordinates)

              # The F2 off-board area has connections to both Brugge [F4] and
              # Dunkerque [G3]. We need to make sure that the train has gone
              # directly between the ferry hex and the port city that is being
              # counted for revenue.
              direct_path?(route.ordered_paths, ferry, port)
            end
          end
        end

        # Checks whether there is a direct connection between stop1 and stop2
        # without any intervening hexes.
        def direct_path?(ordered_paths, stop1, stop2)
          ordered_paths.each_cons(2) do |paths|
            return true if paths.map(&:stops).map(&:first).difference([stop1, stop2]).empty?
          end
          false
        end
      end
    end
  end
end
