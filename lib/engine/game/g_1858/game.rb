# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)
        include G1858::Map
        include G1858::Entities
        include G1858::Market
        include G1858::Trains
        include CitiesPlusTownsRouteDistanceStr

        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive

        # FIXME: second tile lay only costs 10 if either first or second lay
        # only adds metre gauge track.
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        def setup
          super
        end

        def init_round
          # FIXME: the initial stock round isn't *quite* a normal stock round,
          # you cannot start public companies in the first stock round.
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1858::Step::HomeToken,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Track,
            G1858::Step::Token,
            Engine::Step::Route,
            G1858::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1858::Step::BuyTrain,
            G1858::Step::IssueShares,
          ], round_num: round_num)
        end

        def home_token_locations(corporation)
          # When starting a public company after the start of phase 5 it can
          # choose any unoccupied city space for its first token.
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def hex_train?(train)
          train.name[-1] == 'H'
        end

        def metre_gauge_train?(train)
          train.name[-1] == 'M'
        end

        def hex_edge_cost(conn)
          conn[:paths].each_cons(2).sum do |a, b|
            a.hex == b.hex ? 0 : 1
          end
        end

        def check_distance(route, _visits)
          if hex_train?(route.train)
            limit = route.train.distance
            distance = route_distance(route)
            raise GameError, "#{distance} is too many hex edges for #{route.train.name} train" if distance > limit
          else
            super
          end
        end

        def route_distance(route)
          if hex_train?(route.train)
            route.chains.sum { |conn| hex_edge_cost(conn) }
          else
            route.visited_stops.sum(&:visit_cost)
          end
        end

        def check_other(route)
          check_track_type(route)
        end

        def check_track_type(route)
          track_types = route.chains.flat_map { |item| item[:paths] }.flat_map(&:track).uniq

          if metre_gauge_train?(route.train)
            raise GameError, 'Route cannot contain broad gauge track' if track_types.include?(:broad)
          elsif track_types.include?(:narrow)
            raise GameError, 'Route cannot contain metre gauge track'
          end
        end

        def revenue_for(route, stops)
          revenue = super
          revenue /= 2 if route.train.obsolete
          revenue
        end

        def metre_gauge_upgrade(old_tile, new_tile)
          # Check if the only new track on the tile is metre gauge
          old_track = old_tile.paths.map(&:track)
          new_track = new_tile.paths.map(&:track)
          old_track.each { |t| new_track.slice!(new_track.index(t) || new_track.size) }
          new_track.uniq == [:narrow]
        end

        def upgrade_cost(tile, hex, entity, _spender)
          return 0 if tile.upgrades.empty?

          cost = tile.upgrades[0].cost
          if metre_gauge_upgrade(tile, hex.tile)
            discount = cost / 2
            @log << "#{entity.name} receives a #{format_currency(discount)} " \
                    "terrain discount for metre gauge track"
            cost - discount
          else
            cost
          end
        end
      end
    end
  end
end
