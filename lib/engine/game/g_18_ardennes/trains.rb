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

        def route_distance_str(route)
          towns = route.visited_stops.count(&:town?)
          cities = route.visited_stops.count(&:city?)
          port = route.visited_stops.any?(&:offboard?)

          distance = port ? '⚓' : ''
          distance += cities.to_s
          distance += "+#{towns}" if towns.positive? && route.train.name != '5D'
          distance
        end

        def revenue_for(route, stops)
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

          FERRY_BONUS[route.train.name]
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
          tokens.size * (north_south && east_west ? 60 : 30)
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
      end
    end
  end
end
