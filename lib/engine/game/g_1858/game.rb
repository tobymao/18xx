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

        attr_accessor :private_closure_round
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

        def corporation_view(entity)
          return unless entity.minor?

          # Override the default rendering for private railway companies that
          # are owned by players. These would be rendered as minor companies
          # (with treasury, trains and revenue). Instead render them in the same
          # way as private companies that are owned by the bank.
          'private_railway'
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

          stubs.each { |tile:, stub:| tile.stubs.delete(stub) }
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
            # The initial stock round isn't *quite* a normal stock round,
            # you cannot start public companies in the first stock round.
            # This difference is handled in exchange_corporations().
            stock_round
          end
        end

        def round_description(name, round_number = nil)
          return 'Private Closure Round' if name == 'Closure'

          super
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1858::Step::Exchange,
            G1858::Step::HomeToken,
            G1858::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
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

        def new_closure_round(round_num)
          @log << '-- Private Closure Round --'
          closure_round(round_num)
        end

        def closure_round(round_num)
          G1858::Round::Closure.new(self, [
            G1858::Step::HomeToken,
            G1858::Step::PrivateClosure,
          ], round_num: round_num)
        end

        def next_round!
          @private_closure_round = :done if @private_closure_round == :in_progress

          @round =
            if @private_closure_round == :next
              new_closure_round(@round.round_num)
            else
              case @round
              when Engine::Round::Stock
                @operating_rounds = @phase.operating_rounds
                reorder_players
                new_operating_round
              when Engine::Round::Operating, G1858::Round::Closure
                if @round.round_num < @operating_rounds
                  new_operating_round(@round.round_num + 1)
                else
                  @turn += 1
                  new_stock_round
                end
              end
            end
        end

        # Returns all operating entities, both minors and corporations
        def operators
          @minors + @corporations
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

        def private_description(minor)
          private_company(minor).desc
        end

        def private_revenue(minor)
          format_currency(private_company(minor).revenue)
        end

        def private_value(minor)
          format_currency(private_company(minor).value)
        end

        def purchase_company(player, company, price)
          player.spend(price, @bank) unless price.zero?

          player.companies << company
          company.owner = player

          minor = private_minor(company)
          return unless minor # H&G doesn't have an associated minor.

          minor.owner = player
          minor.float!
        end

        # Finds the cities that can be tokened by a public company that is
        # being formed from a private railway company.
        def reserved_cities(corporation, company)
          cities.select do |city|
            # Some cities (Zaragoza, Seville, Córdoba) have two private companies
            # that share the space, so we need to check that there is an available
            # space for the corporation to place a token.
            city.reserved_by?(company) && city.tokenable?(corporation, free: true)
          end
        end

        def place_home_token(corporation)
          return [] if corporation.tokens.any?(&:used)

          super
        end

        def home_token_locations(corporation)
          if corporation.companies.any?
            # This corporation is being formed from a private company. Its first
            # token is in one of the city spaces reserved for the private.
            company = corporation.companies.first
            home_cities = reserved_cities(corporation, company)
            raise GameError, "No available token slots for #{company.id}" if home_cities.empty?

            home_cities.map(&:hex)
          else
            # When starting a public company after the start of phase 5 it can
            # choose any unoccupied city space for its first token.
            hexes.select do |hex|
              hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
            end
          end
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

        def submit_revenue_str(routes, _show_subsidy)
          corporation = current_entity
          train_revenue = super
          return train_revenue if corporation.companies.none?

          private_revenue = format_revenue_currency(corporation.companies.sum(&:revenue))
          "#{train_revenue} train + #{private_revenue} private revenue"
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
          @private_closure_round = :next
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
          trains.select { |train| %i[6H 3M].include?(train.name) }
                .each { |train| train.rusts_on = purchased_train.sym }
          rust_trains!(purchased_train)
        end

        def convert!(corporation)
          return unless corporation.corporation?
          return unless corporation.type == :medium

          @log << "#{corporation.name} converts to a 10-share company"
          corporation.type = :large
          corporation.float_percent = 20

          shares = @_shares.values.select { |share| share.corporation == corporation }
          shares.each { |share| share.percent /= 2 }
          corporation.share_holders.transform_values! { |percent| percent / 2 }

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
          ['Public companies', @corporations.reject(&:ipoed)]
        end

        def unowned_purchasable_companies(_entity)
          @companies.filter { |company| !company.closed? && company.owner == @bank }
        end

        def bank_sort(entities)
          minors, corporations = entities.partition(&:minor?)
          minors.sort_by { |m| PRIVATE_ORDER[m.id] } + corporations.sort_by(&:name)
        end

        def exchange_for_partial_presidency?
          true
        end

        # Returns true if there is a city token space that is available to be
        # used by a public company started from this private railway company.
        # This can only be false for one of the private railway companies that
        # share reservations on a city (Sevilla, Córdoba or Zaragoza) if the
        # other company has been used to token that city, and the tile has not
        # yet been upgraded to green.
        def company_reservation_available?(company)
          cities.any? do |city|
            city.reserved_by?(company) && (city.tokens.compact.size < city.slots)
          end
        end

        # Returns the par price for a public company started from a private
        # railway. Throws an error if called on a private that cannot be used
        # to start a public company.
        def par_price(company)
          unless company.abilities.any? { |ability| ability.type == :exchange }
            raise GameError, "#{company.sym} cannot start a public company as it does not have a home city"
          end

          @stock_market.par_prices.max_by do |share_price|
            share_price.price <= company.value ? share_price.price : 0
          end
        end

        def exchange_corporations(exchange_ability)
          # Can't start public companies in the first stock round.
          return [] if @turn == 1

          entity = exchange_ability.owner
          if exchange_ability.corporations == 'ipoed'
            # A private railway can be exchanged for a share in any public company
            # that can trace a route to any of the private's home hexes.
            super.select { |corporation| corporation_private_connected?(corporation, entity) }
          elsif par_price(entity).price > current_entity.cash
            # Can't afford to start a public company using this private.
            []
          elsif !company_reservation_available?(entity) # rubocop: disable Lint/DuplicateBranch
            # There is no currently available token space for this company.
            []
          else
            # Can exchange the private railway for any unstarted public company.
            corporations.reject(&:ipoed)
          end
        end

        # Returns true if there is a valid route from any of the corporation's
        # tokens to any of the private railway's home hexes, or if a token is in
        # one of the private's home hexes.
        def corporation_private_connected?(corporation, minor)
          return false if corporation.closed?
          return false unless corporation.floated?

          @graph_broad.reachable_hexes(corporation).any? { |hex, _| home_hex?(minor, hex) } ||
            @graph_metre.reachable_hexes(corporation).any? { |hex, _| home_hex?(minor, hex) } ||
            corporation.placed_tokens.any? { |token| home_hex?(minor, token.city.hex) }
        end

        def payout_companies
          return if private_closure_round == :in_progress

          # Private railways owned by public companies don't pay out.
          exchanged_companies = @companies.select { |company| company.owner&.corporation? }
          super(ignore: exchanged_companies.map(&:id))
        end

        def close_company(company)
          owner = company.owner
          message = "#{company.id} closes."
          unless owner == @bank
            message += " #{owner.name} receives #{format_currency(company.value)}."
            @bank.spend(company.value, owner)
          end
          company.close!
          @log << message
        end

        # Closes the private railway companies owned by a public company,
        # paying their face value to the public company's treasury.
        def close_companies(corporation)
          return unless corporation.corporation?

          # The corporation.companies array is modified by company.close!, so we
          # need to take a copy rather than iterating over original array.
          companies = corporation.companies.dup
          companies.each { |company| close_company(company) }
        end

        # Closes both the company and minor parts of a private railway. Can be
        # called using either one as its argument.
        def close_private(entity)
          company = private_company(entity)
          minor = private_minor(entity)

          release_stubs(minor)
          minor&.close!
          close_company(company)
        end

        def entity_can_use_company?(_entity, _company)
          # Don't show abilities buttons in a stock round for the companies
          # owned by the player.
          false
        end
      end
    end
  end
end
