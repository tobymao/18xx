# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'graph'
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
        EBUY_FROM_OTHERS = :never
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false
        EBUY_SELL_MORE_THAN_NEEDED = false
        EBUY_SELL_MORE_THAN_NEEDED_SETS_PURCHASE_MIN = true
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

        GRAPH_CLASS = G1858::Graph

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
          optional_rules.include?(:quick_start_a) || optional_rules.include?(:quick_start_b)
        end

        def option_quick_start_packets
          if optional_rules.include?(:quick_start_b)
            QUICK_START_PACKETS_B
          else
            QUICK_START_PACKETS_A
          end
        end

        def setup_preround
          # Private railway companies need to be owned by the bank to be
          # available for auction.
          @companies.each do |company|
            company.owner = @bank if private_railway?(company)
          end
        end

        def setup
          # We need three different graphs for tracing routes for entities:
          #  - @graph_broad traces routes along broad and dual gauge track.
          #  - @graph_metre traces routes along metre and dual gauge track.
          #  - @graph uses any track. This is going to include illegal routes
          #    (using both broad and metre gauge track) but will just be used
          #    by things like the auto-router where the route will get rejected.
          @graph_broad = self.class::GRAPH_CLASS.new(self, skip_track: :narrow, home_as_token: true)
          @graph_metre = self.class::GRAPH_CLASS.new(self, skip_track: :broad, home_as_token: true)

          # The rusting event for 6H/4M trains is triggered by the number of
          # grey trains purchased, so track the number of these sold.
          @grey_trains_bought = 0

          @unbuyable_companies = []
          setup_unbuyable_privates

          @stubs = setup_stubs
        end

        # Some private railways cannot be bought in the two-player variant:
        # five from P2–P17 and two from P18–P22.
        def setup_unbuyable_privates
          return unless two_player?

          batch1, batch2 = @minors.partition { |minor| minor.color == :yellow }
          reserved = (batch1.sort_by { rand }.take(5) +
                      batch2.sort_by { rand }.take(2))
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

                stub = Engine::Part::Stub.new(edge, :future)
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
            G1858::Step::Exchange,
            G1858::Step::ExchangeApproval,
            G1858::Step::HomeToken,
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

        def new_closure_round(round_num)
          @log << '-- Private Closure Round --'
          closure_round(round_num)
        end

        def closure_round(round_num)
          G1858::Round::Closure.new(self, [
            G1858::Step::ExchangeApproval,
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

        # Returns true if the company object represents a private railway
        # company and false if not. Needed for 1858 India which has 'normal'
        # privates as well as the private railways.
        def private_railway?(_company)
          true
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
          return if corporation.companies.empty?

          # We need to restrict home token locations to cities where the
          # private railway company being used to start the corporation had
          # reservations. This is to prevent the possibility of a token going
          # in the wrong Madrid city if there are unreserved slots available.
          cities = reserved_cities(corporation, corporation.companies.first)
          @round.pending_tokens.first[:cities] = cities
        end

        def home_token_locations(corporation)
          if corporation.companies.empty?
            # When starting a public company after the start of phase 5 it can
            # choose any unoccupied city space for its first token.
            hexes.select do |hex|
              hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
            end
          else
            # This corporation is being formed from a private company. Its first
            # token is in one of the city spaces reserved for the private.
            company = corporation.companies.first
            home_cities = reserved_cities(corporation, company)
            raise GameError, "No available token slots for #{company.id}" if home_cities.empty?

            home_cities.map(&:hex)
          end
        end

        # Returns true if the hex is this private railway's home hex.
        # The gauge parameter is only used when this method is called from
        # `corporation_private_connected?`. It is set to :broad or :narrow
        # when testing whether this hex is part of the broad or narrow gauge
        # graph. 1858 ignores the value of this parameter.
        def home_hex?(operator, hex, _gauge = nil)
          operator.coordinates.include?(hex.coordinates)
        end

        def tile_lays(entity)
          entity.corporation? ? TILE_LAYS : MINOR_TILE_LAYS
        end

        def express_train?(train)
          %w[E D].include?(train.name[-1])
        end

        def hex_train?(train)
          train.distance.is_a?(Integer)
        end

        def metre_gauge_train?(train)
          train.track_type == :narrow
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

        def skip_route_track_type(train)
          metre_gauge_train?(train) ? :broad : :narrow
        end

        def routes_revenue(routes)
          super + @round.current_operator
                        .companies.select { |c| private_railway?(c) }
                        .sum(&:revenue)
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
          companies = corporation.companies.select { |c| private_railway?(c) }
          return super if companies.empty?

          total_revenue = routes_revenue(routes)
          private_revenue = companies.sum(&:revenue)
          train_revenue = total_revenue - private_revenue
          "#{format_revenue_currency(train_revenue)} train + " \
            "#{format_revenue_currency(private_revenue)} private revenue"
        end

        def event_green_privates_available!
          @log << '-- Event: Green private companies can be started --'
          # Don't need to change anything, the check in buyable_bank_owned_companies
          # will let these companies be auctioned in future stock rounds.
        end

        def event_corporations_convert!
          @log << '-- Event: All 5-share public companies must convert to 10-share companies --'
          @corporations.select { |c| c.type == :'5-share' }.each { |c| convert!(c) }
        end

        def event_privates_close!
          @log << '-- Event: Private companies will close at the end of this operating round --'
          @private_closure_round = :next
        end

        def buy_train(operator, train, price = nil)
          bought_from_depot = (train.owner == @depot)
          super
          return if @grey_trains_bought >= phase4_train_trigger
          return unless bought_from_depot
          return unless self.class::GREY_TRAINS.include?(train.name)

          @grey_trains_bought += 1
          ordinal = %w[First Second Third Fourth Fifth Sixth Seventh][@grey_trains_bought - 1]
          @log << "#{ordinal} grey train has been bought"
          maybe_rust_wounded_trains!(@grey_trains_bought, train)
        end

        def maybe_rust_wounded_trains!(grey_trains_bought, purchased_train)
          rust_wounded_trains!(%w[6H 3M], purchased_train) if grey_trains_bought == phase4_train_trigger
        end

        def rust_wounded_trains!(train_names, purchased_train)
          trains.select { |train| train_names.include?(train.name) }
                .each { |train| train.rusts_on = purchased_train.sym }
          rust_trains!(purchased_train, purchased_train.owner)
        end

        def convert!(corporation, quiet: false)
          return unless corporation.corporation?
          return unless corporation.type == :'5-share'

          @log << "#{corporation.name} converts to a 10-share company" unless quiet
          corporation.type = :'10-share'
          corporation.float_percent = 20

          shares = @_shares.values.select { |share| share.corporation == corporation }
          shares.each { |share| share.percent /= 2 }
          corporation.share_holders.transform_values! { |percent| percent / 2 }

          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          new_shares.each do |share|
            add_new_share(share)
          end
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def private_batches_available(phase)
          batches = [:private_batch1]
          batches << :private_batch2 if phase.status.include?('green_privates')
          batches
        end

        def buyable_bank_owned_companies
          available_batches = private_batches_available(@phase)
          @companies.select do |company|
            !company.closed? && (company.owner == @bank) &&
              available_batches.include?(company.type) &&
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

          @graph_broad.reachable_hexes(corporation).any? { |hex, _| home_hex?(minor, hex, :broad) } ||
            @graph_metre.reachable_hexes(corporation).any? { |hex, _| home_hex?(minor, hex, :narrow) } ||
            corporation.placed_tokens.any? { |token| home_hex?(minor, token.city.hex) }
        end

        def payout_companies
          return if private_closure_round == :in_progress

          # Private railways owned by public companies don't pay out.
          exchanged_companies = @companies.select do |company|
            private_railway?(company) && company.owner&.corporation?
          end
          super(ignore: exchanged_companies.map(&:id))
        end

        def close_corporation(corporation, quiet: false)
          super

          # Closed corporations can be restarted.
          @corporations << reset_corporation(corporation)
        end

        def reset_corporation(corporation)
          corporation = super(corporation)

          # The corporation will be restarted as a five-share corporation. It
          # might need to be converted to a ten-share corporation.
          convert!(corporation, quiet: true) if @phase.tiles.include?(:brown)

          corporation
        end

        # Finds any reservation abilities for a hex that have custom icons,
        # and clears these icons. This is to be used for the cities which have
        # two private railway companies competing for the same slots. Once one
        # there is no longer competition for a slot (either because one of the
        # reservation abilities is used, or the city is upgraded to two slots)
        # then the default reservation display is needed to show a single
        # company's name.
        def clear_reservation_icons(hex)
          hex.tile.cities.each do |city|
            city.reservations.compact.each do |entity|
              entity.all_abilities.each do |ability|
                next unless ability.type == :reservation
                next unless ability.hex == hex.coordinates
                next unless ability.icon

                ability.icon = nil
              end
            end

            # If there's still a single slot in the city and one of the two
            # companies reserving the slot has closed, make sure that its
            # reservation is pointing to this slot. Without this the city's
            # reservations array could be [nil, company] and no reservation
            # would be shown on the map.
            city.reservations.compact! if city.reservations.size > city.slots
          end
        end

        # Removes all of the icons on the map for a private railway company.
        # Also resets reservation icons in the private's home cities.
        def delete_icons(company)
          icon_name = company.sym.delete('&')
          @hexes.each do |hex|
            hex.tile.icons.reject! { |icon| icon.name == icon_name }
          end

          minor = private_minor(company)
          return unless minor

          minor.coordinates.each do |coord|
            clear_reservation_icons(hex_by_id(coord))
          end
        end

        def close_company(company)
          return unless private_railway?(company)

          owner = company.owner
          message = "#{company.id} closes."
          unless owner == @bank
            message += " #{owner.name} receives #{format_currency(company.value)}."
            @bank.spend(company.value, owner)
          end
          company.close!
          @log << message
          delete_icons(company)
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

        def operated_operators
          # Don't include minors in the route history selector as they do not
          # have any routes to show.
          @corporations.select(&:operated?)
        end

        def after_lay_tile(_hex, _tile, _entity); end
      end
    end
  end
end
