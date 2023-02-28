# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)
        include G1858::Map
        include G1858::Entities
        include G1858::Market
        include G1858::Trains
        include StubsAreRestricted

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

        MINOR_TILE_LAYS = [
          { lay: true, upgrade: false },
          { lay: true, upgrade: false, cost: 20, cannot_reuse_same_hex: true },
        ].freeze
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        def init_optional_rules(optional_rules)
          rules = super

          # Quick start variant doesn't work for two players.
          rules -= [:quick_start] if two_player?

          # The alternate set of private packets can only be used with the
          # quick start variant.
          rules -= [:set_b] unless rules.include?(:quick_start)

          rules
        end

        def corporation_opts
          two_player? ? { max_ownership_percent: 70 } : {}
        end

        def option_quick_start?
          optional_rules.include?(:quick_start)
        end

        def option_quick_start_packets
          if optional_rules.include?(:set_b)
            QUICK_START_PACKETS_B
          else
            QUICK_START_PACKETS_A
          end
        end

        def setup_preround
          # Companies need to be owned by the bank to be available for auction
          @companies.each { |company| company.owner = @bank }
        end

        def setup
          # We need three different graphs for tracing routes for entities:
          #  - @graph_broad traces routes along broad and dual gauge track.
          #  - @graph_metre traces routes along metre and dual gauge track.
          #  - @graph uses any track. This is going to include illegal routes
          #    (using both broad and metre gauge track) but will just be used
          #    by things like the auto-router where the route will get rejected.
          @graph_broad = Graph.new(self, skip_track: :narrow, home_as_token: true)
          @graph_metre = Graph.new(self, skip_track: :broad, home_as_token: true)

          # The rusting event for 6H/4M trains is triggered by the number of
          # phase 7 trains purchased, so track the number of these sold.
          @phase7_trains_bought = 0
          @phase7_train_trigger = two_player? ? 3 : 5

          @unbuyable_companies = []
          setup_unbuyable_privates

          @stubs = setup_stubs
        end

        # Some private railways cannot be bought in the two-player variant:
        # five from P2–P17 and two from P18–P22.
        def setup_unbuyable_privates
          return unless two_player?

          batch1, batch2 = @minors.partition { |minor| minor.color == :yellow }
          random = Random.new(rand)
          reserved = (batch1.sample(5, random: random) +
                      batch2.sample(2, random: random))
          @log << "These private companies cannot be bought in this game: #{reserved.map(&:id).join(', ')}"

          rx = /(P\d+)\. .*\. (Home hex.*)\. .*/
          reserved.each do |minor|
            company = private_company(minor)
            company.desc = company.desc.sub(rx, '\1. \2. Cannot be purchased in this game.')
            @unbuyable_companies << company
          end
        end

        # Create stubs along the routes of the private railways.
        def setup_stubs
          stubs = Hash.new { |k, v| k[v] = [] }
          @minors.each do |minor|
            next unless minor.coordinates.size > 1

            home_hexes = hexes.select { |hex| minor.coordinates.include?(hex.coordinates) }
            home_hexes.each do |hex|
              tile = hex.tile
              next unless tile.color == :white

              hex.neighbors.each do |edge, neighbor|
                next unless home_hexes.include?(neighbor)

                stub = Engine::Part::Stub.new(edge)
                tile.stubs << stub
                stubs[minor] << { tile: tile, stub: stub }
              end
            end
          end

          stubs
        end

        # Removes the stubs from the private railway's home hexes.
        def release_stubs(minor)
          stubs = @stubs[minor]
          return unless stubs

          stubs.each { |tile_stub| tile_stub[:tile].stubs.delete(tile_stub[:stub]) }
          @stubs.delete(minor)
        end

        def clear_graph_for_entity(_entity)
          @graph.clear
          @graph_broad.clear
          @graph_metre.clear
        end

        def clear_token_graph_for_entity(entity)
          clear_graph_for_entity(entity)
        end

        def init_round
          if option_quick_start?
            quick_start
            operating_round(1)
          else
            stock_round
          end
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::HomeToken,
            G1858::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num = 1)
          @round_num = round_num
          Engine::Round::Operating.new(self, [
            G1858::Step::Track,
            G1858::Step::Token,
            G1858::Step::Route,
            G1858::Step::Dividend,
            G1858::Step::DiscardTrain,
            G1858::Step::BuyTrain,
            G1858::Step::IssueShares,
          ], round_num: round_num)
        end

        # Returns the company object for a private railway given its associated
        # minor object. If passed a company then returns that company.
        def private_company(entity)
          return entity if entity.company?

          @companies.find { |company| company.sym == entity.id }
        end

        # Returns the minor object for a private railway given its associated
        # company object. If passed a minor then returns that minor.
        def private_minor(entity)
          return entity if entity.minor?

          @minors.find { |minor| minor.id == entity.sym }
        end

        # Returns true if the hex is this private railway's home hex.
        def home_hex?(operator, hex)
          operator.coordinates.include?(hex.coordinates)
        end

        def tile_lays(entity)
          entity.corporation? ? TILE_LAYS : MINOR_TILE_LAYS
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

        def routes_revenue(routes)
          super + @round.current_operator.companies.sum(&:revenue)
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
          return 0 if entity.minor? && home_hex?(entity, hex)

          cost = tile.upgrades[0].cost
          return cost unless metre_gauge_upgrade(tile, hex.tile)

          discount = cost / 2
          log_cost_discount(entity, nil, discount, :terrain)
          cost - discount
        end

        def tile_cost_with_discount(_tile, _hex, entity, _spender, cost)
          return cost if @round.gauges_added.one? # First tile lay.
          return cost unless @round.gauges_added.include?([:narrow])

          discount = 10
          log_cost_discount(entity, nil, discount, :tile_lay)
          cost - discount
        end

        def log_cost_discount(entity, _ability, discount, reason = :terrain)
          return unless discount.positive?

          @log << "#{entity.name} receives a #{format_currency(discount)} " \
                  "#{reason == :terrain ? 'terrain' : 'second tile'} " \
                  'discount for metre gauge track'
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

        def submit_revenue_str(routes, _show_subsidy)
          corporation = current_entity
          return super if corporation.companies.empty?

          total_revenue = routes_revenue(routes)
          private_revenue = corporation.companies.sum(&:revenue)
          train_revenue = total_revenue - private_revenue
          "#{format_revenue_currency(train_revenue)} train + " \
            "#{format_revenue_currency(private_revenue)} private revenue"
        end

        def buy_train(operator, train, price = nil)
          bought_from_depot = (train.owner == @depot)
          super
          return if @phase7_trains_bought >= @phase7_train_trigger
          return unless bought_from_depot
          return unless %w[7E 6M 5D].include?(train.name)

          @phase7_trains_bought += 1
          ordinal = %w[First Second Third Fourth Fifth][@phase7_trains_bought - 1]
          @log << "#{ordinal} phase 7 train has been bought"
          rust_phase4_trains!(train) if @phase7_trains_bought == @phase7_train_trigger
        end

        def rust_phase4_trains!(purchased_train)
          trains.select { |train| %w[6H 3M].include?(train.name) }
                .each { |train| train.rusts_on = purchased_train.sym }
          rust_trains!(purchased_train, purchased_train.owner)
        end

        def buyable_bank_owned_companies
          available_colors = [:yellow]
          available_colors << :green if @phase.status.include?('green_privates')
          @companies.select do |company|
            !company.closed? && (company.owner == @bank) &&
              available_colors.include?(company.color) &&
              !@unbuyable_companies.include?(company)
          end
        end

        def unstarted_corporation_summary
          # Don't show minors in the list of bank-owned entities, their
          # associated private company will be listed.
          unstarted = @corporations.reject(&:ipoed)
          [unstarted.size, unstarted]
        end

        def unowned_purchasable_companies(_entity)
          @companies.filter { |company| !company.closed? && company.owner == @bank }
        end

        def bank_sort(entities)
          minors, corporations = entities.partition(&:minor?)
          minors.sort_by { |m| PRIVATE_ORDER[m.id] } + corporations.sort_by(&:name)
        end

        def payout_companies
          return if private_closure_round == :in_progress

          # Private railways owned by public companies don't pay out.
          exchanged_companies = @companies.select { |company| company.owner&.corporation? }
          super(ignore: exchanged_companies.map(&:id))
        end

        def entity_can_use_company?(_entity, _company)
          # Don't show abilities buttons in a stock round for the companies
          # owned by the player.
          false
        end

        def operated_operators
          # Don't include minors in the route history selector as they do not
          # have any routes to show.
          @corporations.select(&:operated?)
        end
      end
    end
  end
end
