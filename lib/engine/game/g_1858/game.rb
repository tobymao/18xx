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

        attr_reader :graph_broad, :graph_metre

        GAME_END_CHECK = { bank: :current_or }.freeze
        BANKRUPTCY_ALLOWED = false

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze

        MUST_BUY_TRAIN = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_OTHER_VALUE = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false
        EBUY_SELL_MORE_THAN_NEEDED = false
        EBUY_SELL_MORE_THAN_NEEDED_LIMITS_DEPOT_TRAIN = true
        EBUY_OWNER_MUST_HELP = true
        EBUY_CAN_SELL_SHARES = false

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        def setup
          # We need three different graphs for tracing routes for entities:
          #  - @graph_broad traces routes along broad and dual gauge track.
          #  - @graph_metre traces routes along metre and dual gauge track.
          #  - @graph uses any track. This is going to include illegal routes
          #    (using both broad and metre gauge track) but will just be used
          #    by things like the auto-router where the route will get rejected.
          @graph_broad = Graph.new(self, skip_track: :narrow)
          @graph_metre = Graph.new(self, skip_track: :broad)

          # The rusting event for 6H/4M trains is triggered by the sale of the
          # fifth phase 7 train, so track the number of these sold.
          @phase7_trains_bought = 0

          # Setup private companies for auction
          @companies.each { |company| company.owner = @bank }
        end

        def clear_graph_for_entity(_entity)
          @graph.clear
          @graph_broad.clear
          @graph_metre.clear
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
            G1858::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1858::Step::Track,
            G1858::Step::Token,
            Engine::Step::Route,
            G1858::Step::Dividend,
            G1858::Step::DiscardTrain,
            G1858::Step::BuyTrain,
            G1858::Step::IssueShares,
          ], round_num: round_num)
        end

        def purchase_company(player, company, price)
          player.spend(price, @bank) unless price.zero?

          player.companies << company
          company.owner = player

          # minor = @game.minors.find { |m| m.id == company.id }
          # minor.owner = player
          # minor.float!
        end

        def home_token_locations(corporation)
          # When starting a public company after the start of phase 5 it can
          # choose any unoccupied city space for its first token.
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def express_train?(train)
          %w[E D].include?(train.name[-1])
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
                    'terrain discount for metre gauge track'
            cost - discount
          else
            cost
          end
        end

        def route_distance_str(route)
          train = route.train

          if hex_train?(train)
            "#{route_distance(route)}H"
          else
            towns = route.visited_stops.count(&:town?)
            cities = route_distance(route) - towns
            if express_train?(train)
              cities.to_s
            else
              "#{cities}+#{towns}"
            end
          end
        end

        def event_green_privates_available!
          @log << '-- Event: Green private companies can be started --'
          # Don't need to change anything, the check in buyable_bank_owned_companies
          # will let these companies be auctioned in future stock rounds.
        end

        def event_corporations_convert!
          @log << '-- Event: All 5-share public companies must convert to 10-share companies --'
          @corporations.select { |c| c.type == :medium }.each { |c| convert!(c) }
        end

        def event_privates_close!
          @log << '-- Event: Private companies will close at the end of this operating round --'
          # TODO: implement this
        end

        def buy_train(operator, train, price = nil)
          super
          return if @phase7_trains_bought >= 5
          return unless %w[7E 6M 5D].include?(train.name)

          @phase7_trains_bought += 1
          ordinal = %w[First Second Third Fourth Fifth][@phase7_trains_bought - 1]
          @log << "#{ordinal} phase 7 train has been bought"
          rust_phase4_trains!(train) if @phase7_trains_bought == 5
        end

        def rust_phase4_trains!(purchased_train)
          trains.select { |train| %i[6H 3M].include?(train.name) }
                .each { |train| train.rusts_on = purchased_train.sym }
          rust_trains!(purchased_train)
        end

        def convert!(corporation)
          return unless corporation.corporation?
          return unless corporation.type == :medium

          @log << "#{corporation.name} converts to a 10-share company"
          corporation.type = :large

          shares = @_shares.values.select { |share| share.corporation == corporation }
          shares.each { |share| share.percent /= 2 }

          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          new_shares.each do |share|
            add_new_share(share)
          end
          new_shares
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def buyable_bank_owned_companies
          super.filter { |company| company.color == :yellow || @phase.status.include?('green_privates') }
        end

        def unowned_purchasable_companies(_entity)
          @companies.filter { |company| !company.closed? && company.owner == @bank }
        end
      end
    end
  end
end
