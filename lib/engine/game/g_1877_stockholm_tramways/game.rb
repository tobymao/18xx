# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1877StockholmTramways
      class Game < Game::Base
        include_meta(G1877StockholmTramways::Meta)
        include Entities
        include Map

        register_colors(black: '#000000')

        CURRENCY_FORMAT_STR = '%dkr'

        BANK_CASH = 99_999

        CERT_LIMIT = {
          3 => 16,
          4 => 12,
          5 => 10,
          6 => 9,
        }.freeze

        STARTING_CASH = {
          3 => 600,
          4 => 450,
          5 => 360,
          6 => 300,
        }.freeze

        MARKET = [
          %w[35 40 45
             50p 60p 70p 80p 90p 100p
             120 140 160 180 200
             240 280 320 360 400e],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2H',
            distance: 2,
            price: 80,
            rusts_on: '4H',
            num: 6,
          },
          {
            name: '3H',
            distance: 3,
            price: 180,
            rusts_on: '8H',
            num: 5,
          },
          {
            name: '4H',
            distance: 4,
            price: 280,
            rusts_on: '10H',
            num: 4,
          },
          {
            name: '6H',
            distance: 6,
            price: 500,
            num: 2,
          },
          {
            name: '8H',
            distance: 8,
            price: 600,
            num: 2,
          },
          {
            name: '10H',
            distance: 10,
            price: 700,
            num: 32,
          },
        ].freeze

        CAPITALIZATION = :full
        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :after_ipo
        SELL_BUY_ORDER = :sell_buy
        MARKET_SHARE_LIMIT = 100
        MUST_BUY_TRAIN = :always

        GAME_END_CHECK = { stock_market: :current_round, custom: :current_or }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
           'sl_trigger' => ['SL Trigger', 'SL will form at end of OR, game ends at end of following OR set'],
         ).freeze

        def init_round
          stock_round
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1877StockholmTramways::Step::Dividend,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def game_route_revenue(stop, phase, train)
          return 0 unless stop

          stop.route_revenue(phase, train)
        end

        def check_overlap(routes) end

        def check_overlap_single(route)
          tracks = []

          route.paths.each do |path|
            a = path.a
            b = path.b

            tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
            tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

            # check track between edges and towns not in center
            # (essentially, that town needs to act like an edge for this purpose)
            if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
              tracks << [path.hex, a, path.lanes[0][1]]
            end
            if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
              tracks << [path.hex, b, path.lanes[1][1]]
            end
          end

          tracks.group_by(&:itself).each do |k, v|
            raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
          end
        end

        def hex_edge_cost(conn)
          conn[:paths].each_cons(2).sum do |a, b|
            a.hex == b.hex ? 0 : 1
          end
        end

        def route_distance(route)
          route.chains.sum { |conn| hex_edge_cost(conn) }
        end

        def route_distance_str(route)
          "#{route_distance(route)}H"
        end

        def check_distance(route, _visits)
          limit = route.train.distance
          distance = route_distance(route)
          raise GameError, "#{distance} is too many hex edges for #{route.train.name} train" if distance > limit
        end

        def check_other(route)
          check_overlap_single(route)
        end

        def stop_on_other_route?(this_route, stop)
          this_route.routes.each do |r|
            return false if r == this_route

            other_stops = r.stops
            return true if other_stops.include?(stop)
            return true unless (other_stops.flat_map(&:groups) & stop.groups).empty?
          end
          false
        end

        def revenue_for(route, stops)
          stops.sum do |stop|
            stop_on_other_route?(route, stop) ? 0 : game_route_revenue(stop, route.phase, route.train)
          end
        end

        def compute_other_paths(_, _)
          []
        end
      end
    end
  end
end
