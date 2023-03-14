# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'
require_relative 'stock_market'
require_relative '../../loan'
require_relative '../interest_on_loans'

module Engine
  module Game
    module G18NY
      class Game < Game::Base
        include_meta(G18NY::Meta)
        include G18NY::Entities
        include G18NY::Map
        include InterestOnLoans

        attr_reader :privates_closed, :first_nyc_owner
        attr_accessor :stagecoach_token, :capitalization_round

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :operate

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        SELL_BUY_ORDER = :sell_buy_or_buy_sell
        SELL_AFTER = :operate

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or, custom: :full_or }.freeze
        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'All but one corporation is closed',
        )

        ALL_COMPANIES_ASSIGNABLE = true

        CLOSED_CORP_TRAINS_REMOVED = false

        TRACK_RESTRICTION = :permissive

        NYC_TOKEN_COST = 40

        # Two lays with one being an upgrade. Tile lays cost 20
        TILE_COST = 20
        TILE_LAYS = [
          { lay: true, upgrade: true, cost: TILE_COST, cannot_reuse_same_hex: true },
          { lay: true, upgrade: :not_if_upgraded, cost: TILE_COST, cannot_reuse_same_hex: true },
        ].freeze

        def tile_lays(entity)
          return [self.class::TILE_LAYS.first] if entity.type == :minor

          self.class::TILE_LAYS
        end

        MARKET = [
          %w[70 75 80 90 100p 110 125 150 175 200 230 260 300 350 400
             450 500],
          %w[65 70 75 80x 90p 100 110 125 150 175 200 230 260 300 350
             400 450],
          %w[60 65 70 75x 80p 90 100 110 125 150 175 200z 230 260 300 350
             400],
          %w[55 60 65 70x 75p 80 90 100 110 125 150z 175z],
          %w[50 55 60 65x 70p 75 80 90 100 110z 125z],
          %w[40 50 55 60x 65p 70 75 80 90 100z],
          %w[30 40 50 55x 60 65 70 75 80],
          %w[20 30 40 50x 55 60 65 70],
          %w[10 20 30 40 50 55 60],
          %w[0c 10 20 30 40 50],
          %w[0c 0c 10 20 30],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Major Corporation Par',
                                              par_1: 'Minor Corporation Par',
                                              par_2: 'NYC Par')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :gray, par_2: :blue, par: :red).freeze

        PHASES = [
          {
            name: '2H',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '4H',
            on: '4H',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '4DE',
            on: '4DE',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2H', num: 11, distance: 2, price: 100, rusts_on: '6H' },
          { name: '4H', num: 6, distance: 4, price: 200, rusts_on: '4DE', events: [{ 'type' => 'float_30' }] },
          { name: '6H', num: 4, distance: 6, price: 300, rusts_on: 'D', events: [{ 'type' => 'float_40' }] },
          {
            name: '12H',
            num: 3,
            distance: 12,
            price: 600,
            events: [{ 'type' => 'float_50' }, { 'type' => 'close_companies' }, { 'type' => 'nyc_formation' },
                     { 'type' => 'capitalization_round', 'when' => 3 }],
          },
          {
            name: '4DE',
            num: 2,
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 99, 'multiplier' => 2 }],
            price: 800,
            events: [{ 'type' => 'float_60' }],
          },
          {
            name: 'D',
            num: 20,
            distance: 99,
            price: 1000,
            variants: [
              name: '5DE',
              distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 99, 'multiplier' => 2 }],
              price: 1000,
            ],
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'float_30' => ['30% to Float', 'Corporations must have 30% of their shares sold to float'],
          'float_40' => ['40% to Float', 'Corporations must have 40% of their shares sold to float'],
          'float_50' => ['50% to Float', 'Corporations must have 50% of their shares sold to float'],
          'float_60' =>
            ['60% to Float', 'Corporations must have 60% of their shares sold to float and receive full capitalization'],
          'nyc_formation' => ['NYC Formation', 'NYC formation triggered'],
          'capitalization_round' =>
            ['Capitalization Round', 'Trigger Special Capitalization Round'],
        ).freeze

        ERIE_CANAL_ICON = 'canal'
        CONNECTION_BONUS_ICON = 'connection_bonus'
        COAL_ICON = 'coal'

        ASSIGNMENT_TOKENS = {
          'connection_bonus' => '/icons/18_ny/connection_bonus.svg',
          'coal' => '/icons/18_ny/coal.svg',
        }.freeze

        def immediate_capitalization_round?
          @optional_rules.include?(:immediate_capitalization_round)
        end

        def setup
          @float_percent = 20
          @interest = {}
          @stagecoach_token =
            Token.new(nil, logo: '/logos/18_ny/stagecoach.svg', simple_logo: '/logos/18_ny/stagecoach.alt.svg')
          @original_nyc_corporation = nyc_corporation.dup
          @fully_capitalized_corporations = []
          init_connection_bonuses
          init_coal_tokens
        end

        def init_connection_bonuses
          hexes = self.class::CONNECTION_BONUS_HEXES
          hexes.each do |hex_id|
            hex_id = hex_id.first if hex_id.is_a?(Array)
            hex_by_id(hex_id).assign!(CONNECTION_BONUS_ICON)
          end
          @offboard_bonus_locations =
            hexes.select { |h| h.is_a?(Array) }.map { |a| a.map { |hex_id| hex_by_id(hex_id) } }
        end

        def init_coal_tokens
          @coal_locations = COAL_LOCATIONS.map { |loc| loc.map { |hex_id| hex_by_id(hex_id) } }
          @coal_locations.flat_map(&:last).each { |hex| hex.assign!(COAL_ICON) }
        end

        def erie_canal_private
          @erie_canal_private ||= @companies.find { |c| c.id == 'EC' }
        end

        def coal_fields_private
          @coal_fields_private ||= @companies.find { |c| c.id == 'PCF' }
        end

        def nyc_corporation
          @nyc_corporation ||= corporation_by_id('NYC')
        end

        def albany_hex
          @albany_hex ||= hex_by_id('F20')
        end

        def nyc_hex
          @nyc_hex ||= hex_by_id('J20')
        end

        def second_edition?
          true
        end

        def active_minors
          operating_order.select { |c| c.type == :minor && c.floated? }
        end

        def init_stock_market
          G18NY::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def init_share_pool
          G18NY::SharePool.new(self)
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18NY::Step::CompanyPendingPar,
            Engine::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G18NY::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          round = G18NY::Round::Operating.new(self, [
            G18NY::Step::CheckNYCFormation,
            G18NY::Step::BuyCompany,
            G18NY::Step::Bankrupt,
            G18NY::Step::EmergencyMoneyRaising,
            G18NY::Step::DiscardTrain,
            G18NY::Step::SpecialCapitalization,
            Engine::Step::HomeToken,
            G18NY::Step::ReplaceTokens,
            G18NY::Step::StagecoachExchange,
            G18NY::Step::ViewAcquirable,
            G18NY::Step::SpecialTrack,
            G18NY::Step::SpecialToken,
            G18NY::Step::AcquireCorporation,
            G18NY::Step::Track,
            G18NY::Step::Token,
            G18NY::Step::ClaimCoalToken,
            G18NY::Step::Route,
            G18NY::Step::Dividend,
            G18NY::Step::LoanInterestPayment,
            G18NY::Step::LoanRepayment,
            Engine::Step::SpecialBuyTrain,
            G18NY::Step::BuyTrain,
            G18NY::Step::AcquireCorporation,
            [G18NY::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)

          unless immediate_capitalization_round?
            round.steps.delete_if { |step| step.instance_of?(G18NY::Step::SpecialCapitalization) }
          end
          round
        end

        def new_nyc_formation_round(round_num)
          @log << "-- NYC Formation Round #{round_num} --"
          nyc_formation_share_price if round_num == 1
          G18NY::Round::NYCFormation.new(self, [
            G18NY::Step::Bankrupt,
            G18NY::Step::EmergencyMoneyRaising,
            G18NY::Step::MergeWithNYC,
            G18NY::Step::DiscardTrain,
          ], round_num: round_num)
        end

        def new_capitalization_round
          @log << '-- Capitalization Round --'
          G18NY::Round::Capitalization.new(self, [
            G18NY::Step::IssueShares,
          ])
        end

        def next_round!
          clear_interest_paid

          @round =
            case @round
            when G18NY::Round::NYCFormation
              nyc_formation_round_finished
              if @capitalization_round
                new_capitalization_round
              else
                @turn += 1
                new_stock_round
              end
            when G18NY::Round::Capitalization
              @capitalization_round = nil
              @turn += 1
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                or_set_finished
                if %i[round_one round_two].include?(@nyc_formation_state)
                  new_nyc_formation_round(@nyc_formation_state == :round_one ? 1 : 2)
                elsif @capitalization_round
                  new_capitalization_round
                else
                  @turn += 1
                  new_stock_round
                end
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def custom_end_game_reached?
          @corporations.count { |c| !c.closed? } <= 1
        end

        #
        # Events
        #

        def event_close_companies!
          super
          @privates_closed = true
        end

        def event_float_30!
          @log << "-- Event: #{EVENTS_TEXT['float_30'][1]} --"
          @float_percent = 30
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_float_40!
          @log << "-- Event: #{EVENTS_TEXT['float_40'][1]} --"
          @float_percent = 40
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_float_50!
          @log << "-- Event: #{EVENTS_TEXT['float_50'][1]} --"
          @float_percent = 50
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_float_60!
          @log << "-- Event: #{EVENTS_TEXT['float_60'][1]} --"
          @float_percent = 60
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_nyc_formation!
          return if @nyc_formation_state

          @log << "-- Event: #{EVENTS_TEXT['nyc_formation'][1]} --"
          @nyc_formation_state = :round_one

          @log << 'No further minor corporations may be started'
          @corporations.dup.each do |corp|
            next if corp.type != :minor || corp.floated? || corp.closed?

            @log << "#{corp.name} is removed from the game"
            close_corporation(corp, quiet: true)
          end
        end

        def event_capitalization_round!
          @log << "-- Event: #{EVENTS_TEXT['capitalization_round'][1]} --"
          @capitalization_round = true
          @full_capitalization = true
        end

        def non_floated_corporations
          @corporations.each { |c| yield c if c.type != :minor && !c.floated? }
        end

        def close_corporation(corporation, quiet: false)
          super
          @loans += corporation.loans
          corporation.loans.clear
          return unless corporation.tokens.include?(@stagecoach_token)

          @log << 'Stagecoach token removed from play'
          @stagecoach_token.destroy!
          @stagecoach_token = nil
        end

        def player_value(player)
          super - player.shares_by_corporation.sum { |corp, _| player.num_shares_of(corp) * corp.loans.size * 5 }
        end

        def bank_sort(corporations)
          minors, corps = corporations.partition { |c| c.type == :minor }
          minors.sort_by { |m| m.name.to_i } + super(corps)
        end

        #
        # Stock round logic
        #

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || entity.type != :major

          max_issuable = entity.num_player_shares - entity.num_market_shares
          return [] unless max_issuable.positive?

          bundles_for_corporation(entity, entity, shares: entity.shares_of(entity).first(max_issuable))
        end

        def redeemable_shares(entity)
          return [] if !entity.corporation? || entity.type != :major

          [@share_pool.shares_of(entity).find { |s| s.price <= entity.cash }&.to_bundle].compact
        end

        def check_sale_timing(_entity, bundle)
          return true if bundle.corporation == nyc_corporation && @nyc_formed

          super
        end

        def can_par?(corporation, _parrer)
          return false if corporation == nyc_corporation && !@nyc_formation_state
          return false if @turn == 1 && corporation.type != :minor && corporation.id != 'D&H'

          super
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def can_buy_presidents_share_directly_from_market?
          true
        end

        def can_fully_capitalize?(entity)
          return false if @nyc_formed && entity == nyc_corporation

          @full_capitalization &&
            entity.type != :minor &&
            !entity.operated? &&
            !corporation_fully_capitalized?(entity) &&
            entity.percent_of(entity) == 40
        end

        def corporation_fully_capitalized?(corporation)
          @fully_capitalized_corporations.include?(corporation)
        end

        def fully_capitalize_corporation(entity)
          entity.spend(entity.cash, @bank)
          @bank.spend(entity.par_price.price * entity.total_shares, entity)
          @share_pool.transfer_shares(ShareBundle.new(entity.shares_of(entity)), @share_pool)
          @fully_capitalized_corporations << entity
          @log << "#{entity.name} treasury is discarded and instead receives full capitalization " \
                  "of #{format_currency(entity.cash)}"
          @log << "#{entity.name}'s remaining shares are placed in the market"
        end

        def float_corporation(corporation)
          super

          fully_capitalize_corporation(corporation) if can_fully_capitalize?(corporation)
        end

        def liquidity(player, emergency: false)
          value = super
          if !nyc_corporation.operated? && @nyc_formed && !player.shares_of(nyc_corporation).empty?
            value += emergency ? value_for_sellable(player, nyc_corporation) : value_for_dumpable(player, nyc_corporation)
          end

          value
        end

        #
        # Operating round logic
        #

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def non_blocking_graph
          @non_block_graph ||= Graph.new(self, no_blocking: true, home_as_token: true)
        end

        def albany_and_buffalo_connected?
          @buffalo_corp ||=
            Engine::Corporation.new(name: 'Buffalo', sym: 'BUF', tokens: [], coordinates: 'E3')

          non_blocking_graph.clear_graph_for(@buffalo_corp)
          non_blocking_graph.reachable_hexes(@buffalo_corp)[albany_hex]
        end

        def home_token_locations(corporation)
          return super unless corporation == nyc_corporation
          return nil if corporation.tokens.any?(&:used)
          return [albany_hex] unless albany_hex.tile.cities[0].available_slots.zero?

          @cities.reject { |c| c.available_slots.zero? }.map { |c| c.tile.hex }
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used

          if second_edition? && corporation.id == 'NY&H'
            @log << "#{corporation.name} spends #{format_currency(NYC_TOKEN_COST)} on NYC token fee"
            corporation.spend(NYC_TOKEN_COST, @bank)
          end
          super
        end

        def tile_lay(_hex, old_tile, _new_tile)
          return unless old_tile.icons.any? { |icon| icon.name == ERIE_CANAL_ICON }

          @log << "#{erie_canal_private.name}'s revenue reduced from #{format_currency(erie_canal_private.revenue)}" \
                  " to #{format_currency(erie_canal_private.revenue - 10)}"
          erie_canal_private.revenue -= 10
          return if erie_canal_private.revenue.positive?

          @log << "#{erie_canal_private.name} closes"
          erie_canal_private.close!
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if town_to_city_upgrade?(from, to)
          return false if to.name == '448' && from.hex.neighbors.size != 4

          super
        end

        def town_to_city_upgrade?(from, to)
          case from.name
          when '3'
            to.name == '5'
          when '4'
            to.name == '57'
          when '58'
            to.name == '6'
          else
            false
          end
        end

        def legal_tile_rotation?(entity, hex, tile)
          # NYC tiles have a specific rotation
          return tile.rotation.zero? if hex.id == 'J20' && %w[X11 X22].include?(tile.name)
          return tile.rotation.zero? if second_edition? && hex.id == 'J20' && tile.name == 'X32'

          super
        end

        def upgrade_cost(tile, _hex, entity, spender)
          terrain_cost = tile.upgrades.sum(&:cost)
          discounts = 0

          # Tile discounts must be activated
          if entity.company? && (ability = entity.all_abilities.find { |a| a.type == :tile_discount })
            discounts = tile.upgrades.sum do |upgrade|
              next unless upgrade.terrains.include?(ability.terrain)

              discount = [upgrade.cost, ability.discount].min
              log_cost_discount(spender, ability, discount) if discount.positive?
              discount
            end
          end

          terrain_cost -= TILE_COST if terrain_cost.positive?
          terrain_cost - discounts
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          phase_color_cache ||= @phase.tiles
          if hex&.tile&.color == :yellow && hex.tile.towns.empty? == false && tile.color == :yellow
            return phase_color_cache.include?(:green)
          end

          super
        end

        def route_distance(route)
          # Count hex edges
          distance = route.chains.sum { |conn| conn[:paths].each_cons(2).sum { |a, b| a.hex == b.hex ? 0 : 1 } }
          # Springfield is considered one hex
          distance -= 1 if route.all_hexes.include?(hex_by_id('E25'))
          # Toronto is considered one hex
          distance -= 1 if second_edition? && route.all_hexes.include?(hex_by_id('E1'))
          distance
        end

        def route_distance_str(route)
          "#{route_distance(route)}H"
        end

        def check_distance(route, _visits)
          limit = route.train.distance
          limit = 99 if limit.is_a?(Array)
          distance = route_distance(route)
          raise GameError, "#{distance} is too many hex edges for #{route.train.name} train" if distance > limit
        end

        def compute_stops(route)
          return super unless route.train.name.include?('DE')

          stops = route.visited_stops
          return [] unless stops.any? { |stop| stop.tokened_by?(route.corporation) }

          if second_edition?
            # Only count revenue for tokened stops
            stops.select! { |stop| stop.tokened_by?(route.corporation) || stop.tile.color == :red }
          end
          count = route.train.distance.first['pay']
          stops = stops.combination(count).map { |s| [s, revenue_for(route, s)] }.max_by(&:last).first if stops.size > count
          stops
        end

        def revenue_for(route, stops)
          super + bonus_revenue(route.train, stops) + (route_connection_bonus_hexes(route, stops: stops).size * 10)
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map { |h| stop_hexes.include?(h) ? h&.name : "(#{h&.name})" }.join('-')
          if (bonus = bonus_revenue(route.train, stops)).positive?
            str += " + #{format_currency(bonus)}"
          end

          num_bonuses = route_connection_bonus_hexes(route).size
          str += " + #{num_bonuses} Connection Bonus#{num_bonuses == 1 ? '' : 'es'}" if num_bonuses.positive?

          str
        end

        def routes_revenue(routes)
          revenue = super

          revenue += connection_bonus_revenue(@round.current_operator)
          revenue += coal_revenue(@round.current_operator)

          revenue
        end

        def connection_bonus_revenue(entity)
          abilities(entity, :connection_bonus)&.bonus_revenue || 0
        end

        def bonus_revenue(train, stops)
          return 0 if train.name != 'D' || !second_edition?

          stops.count { |s| s.tile.color == :red } * 100
        end

        def route_connection_bonus_hexes(route, stops: nil)
          already_claimed = []
          stops ||= route.stops

          # Only return connection bonus hexes not counted by a previous route
          route.routes.each do |r|
            route_stops = r == route ? stops : r.stops
            hexes = potential_route_connection_bonus_hexes(r, stops: route_stops)
            return hexes.reject { |h| already_claimed.include?(h) } if r == route

            already_claimed.concat(hexes)
          end
        end

        def potential_route_connection_bonus_hexes(route, stops: nil)
          stops ||= route.stops
          stops.map do |stop|
            if stop.hex.tile.color == :red
              offboard_connection_bonus_hex(route, stop)
            elsif stop.hex.assigned?('connection_bonus')
              stop.hex
            end
          end.compact
        end

        def offboard_bonus_location_with_hex(hex)
          @offboard_bonus_locations.find { |l| l.include?(hex) }
        end

        def offboard_connection_bonus_hex(route, stop)
          hex = stop.hex
          if stop.hex.id == 'A21'
            # A21 is split between two locations. Determine which location by path exit.
            exit = route.paths.find { |path| path.hex == stop.hex }.exits.first
            hex = hex_by_id(exit.zero? ? 'A19' : 'A23')
          end

          offboard_bonus_location_with_hex(hex)&.first
        end

        def claim_connection_bonus(entity, hex)
          location_name = hex.location_name || offboard_bonus_location_with_hex(hex).find(&:location_name).location_name
          @log << "#{entity.name} claims the connection bonus at #{hex.name} (#{location_name})"
          hex.remove_assignment!('connection_bonus')
          @offboard_bonus_locations.delete(offboard_bonus_location_with_hex(hex)) if hex.tile.color == :red

          if (ability = abilities(entity, :connection_bonus))
            ability.bonus_revenue += 10
          else
            add_connection_bonus_ability(entity)
          end
        end

        def add_connection_bonus_ability(entity)
          entity.add_ability(G18NY::Ability::ConnectionBonus.new(type: :connection_bonus, bonus_revenue: 10))
        end

        def remove_connection_bonus_ability(entity)
          return unless (ability = abilities(entity, :connection_bonus))

          entity.remove_ability(ability)
        end

        def coal_revenue(entity)
          abilities(entity, :coal_revenue)&.bonus_revenue || 0
        end

        def connected_coal_hexes(entity)
          return if @coal_locations.empty?

          @coal_locations.map { |cl| (graph.reachable_hexes(entity).keys & cl)&.first }.compact
        end

        def claim_coal_token(entity, hex)
          claimed_location = @coal_locations.find { |loc| loc.include?(hex) }
          @log << "#{entity.name} claims the coal token at #{hex.name} (#{coal_location_name(claimed_location)})"
          claimed_location.each { |h| h.remove_assignment!(COAL_ICON) }
          @coal_locations.delete(claimed_location)

          if (ability = abilities(entity, :coal_revenue))
            ability.bonus_revenue += 10
          else
            add_coal_token_ability(entity)
          end
        end

        def add_coal_token_ability(entity, revenue: 10)
          entity.add_ability(G18NY::Ability::CoalRevenue.new(type: :coal_revenue, bonus_revenue: revenue))
        end

        def coal_location_name(location)
          location.find(&:location_name)&.location_name
        end

        def stagecoach_token_exchange_ability
          detailed_text = 'Owning corporation may replace the Stagecoach Token with one of its available tokens ' \
                          'for free during its operating turn by selecting the Stagecoach Token in F20 (Albany).'
          @sc_exchange_ability ||= Engine::Ability::Description.new(type: :description,
                                                                    description: 'Stagecoach Token Exchange',
                                                                    desc_detail: detailed_text)
        end

        def add_stagecoach_token_exchange_ability(entity)
          entity.add_ability(stagecoach_token_exchange_ability)
        end

        def remove_stagecoach_token_exchange_ability(entity)
          entity.remove_ability(stagecoach_token_exchange_ability)
        end

        def salvage_value(train)
          train.price / 4
        end

        def salvage_train(train)
          owner = train.owner
          @log << "#{owner.name} salvages a #{train.name} train for #{format_currency(salvage_value(train))}"
          @bank.spend(salvage_value(train), owner)
          @depot.reclaim_train(train)
        end

        def rust(train)
          salvage_train(train) unless train.from_depot?
          super
        end

        def remove_train(train)
          owner = train.owner
          super
          return unless owner&.corporation?

          remove_connection_bonus_ability(owner) if owner.trains.size.zero? && current_entity != owner
        end

        def must_buy_train?(entity)
          return false if entity.type == :minor

          super
        end

        def buy_train(operator, train, price = nil)
          super
          @round.active_train_loan = false if @round.respond_to?(:active_train_loan)
        end

        def init_loans
          @loan_value = 50
          # 11 minors * 2, 8 majors * 10
          Array.new(102) { |id| Loan.new(id, @loan_value) }
        end

        def interest_rate
          5
        end

        def emergency_issuable_bundles(corp)
          bundles = bundles_for_corporation(corp, corp)
          cash_needed = @depot.depot_trains.first.variants.map { |_, v| v[:price] }.max - corp.cash
          share_price = corp.share_price.price.to_f
          return [] if cash_needed.negative? || share_price.zero?

          max_issuable_shares = [5, corp.num_player_shares].min - corp.num_market_shares
          num_issuable_shares = [max_issuable_shares, (cash_needed / share_price).ceil].min
          bundles.reject { |bundle| bundle.num_shares > num_issuable_shares }.sort_by(&:price)
        end

        def interest_owed_for_loans(num_loans)
          interest_rate * num_loans
        end

        def loans_due_interest(entity)
          entity&.loans&.size || 0
        end

        def interest_owed(entity)
          interest_owed_for_loans(entity.loans.size)
        end

        def maximum_loans(entity)
          entity.num_player_shares
        end

        def loan_face_value
          @loan_value
        end

        def loan_value(entity = nil)
          @loan_value - (entity && interest_paid?(entity) ? interest_rate : 0)
        end

        def take_loan(entity, loan = loans.first)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          amount = loan_value(entity)
          @log << "#{entity.name} takes a loan and receives #{format_currency(amount)}"
          @bank.spend(amount, entity)
          entity.loans << loan
          @loans.delete(loan)

          initial_sp = entity.share_price.price
          @stock_market.move_left(entity)
          @log << "#{entity.name}'s share price changes from" \
                  " #{format_currency(initial_sp)} to #{format_currency(entity.share_price.price)}"
        end

        def repay_loan(entity, loan)
          @log << "#{entity.name} pays off a loan for #{format_currency(loan.amount)}"
          entity.spend(loan.amount, @bank, check_cash: false)
          entity.loans.delete(loan)
          @loans << loan

          initial_sp = entity.share_price.price
          @stock_market.move_right(entity)
          @log << "#{entity.name}'s share price changes from" \
                  " #{format_currency(initial_sp)} to #{format_currency(entity.share_price.price)}"
        end

        def num_emergency_loans(entity, debt)
          [maximum_loans(entity) - entity.loans.size, (debt / loan_value(entity).to_f).ceil].min
        end

        def can_take_loan?(entity)
          return true if nyc_corporation == entity && @nyc_formation_state != :complete

          entity.corporation? && entity.loans.size < maximum_loans(entity)
        end

        def buying_power(entity, full: false)
          return entity.cash unless full
          return entity.cash unless entity.corporation?

          num_loans = maximum_loans(entity) - entity.loans.size
          entity.cash + (num_loans * loan_value(entity))
        end

        def acquisition_candidates(entity)
          @corporations.select { |c| can_acquire?(entity, c) }
        end

        def can_acquire?(entity, corporation)
          return false if entity == corporation
          return false if corporation.closed? || !corporation.floated?

          acquisition_cost = acquisition_cost(entity, corporation)
          if (num_loans_over_the_limit = entity.loans.size + corporation.loans.size - maximum_loans(entity)).positive?
            acquisition_cost += num_loans_over_the_limit * loan_face_value
          end
          return false if acquisition_cost > entity.cash

          corporation_tokened_cities = corporation.tokens.select(&:used).map(&:city)
          !(graph.connected_nodes(entity).keys & corporation_tokened_cities).empty?
        end

        def acquisition_cost(entity, corporation)
          multiplier = acquisition_cost_multiplier(entity, corporation)
          return corporation.share_price.price * multiplier if corporation.type == :minor

          corporation.share_price.price * multiplier * (corporation.num_player_shares + corporation.num_market_shares)
        end

        def acquisition_cost_multiplier(entity, corporation)
          return entity.owner == corporation.owner ? 2 : 5 if corporation.type == :minor

          entity.owner == corporation.owner ? 1 : 3
        end

        def acquire_corporation(entity, corporation)
          @round.acquisition_corporations = [entity, corporation]
          acquisition_verb = entity.owner == corporation.owner ? 'merges with' : 'takes over'
          @log << "-- #{entity.name} #{acquisition_verb} #{corporation.name} --"

          # Pay for the acquisition
          share_price = corporation.share_price.price
          multiplier = acquisition_cost_multiplier(entity, corporation)
          if corporation.type == :minor
            cost = share_price * multiplier
            entity_to_pay = corporation.owner.share_pool? ? @bank : corporation.owner
            @log << "#{entity.name} pays #{entity_to_pay.name} #{format_currency(cost)}"
            entity.spend(cost, entity_to_pay)
          else
            corporation.share_holders.keys.each do |sh|
              next if sh == corporation
              next unless (num_shares = sh.num_shares_of(corporation)).positive?

              entity_to_pay = sh.share_pool? ? @bank : sh
              cost = share_price * num_shares * multiplier
              @log << "#{entity.name} pays #{entity_to_pay.name} #{format_currency(cost)}"
              entity.spend(cost, entity_to_pay)
            end
          end

          transfer_assets(corporation, entity)

          # Loans
          unless corporation.loans.empty?
            num_to_payoff = [(entity.cash / loan_face_value.to_f).floor, corporation.loans.size].min
            if num_to_payoff.positive?
              @log << "#{entity.name} pays off #{num_to_payoff} of #{corporation.name}'s loans"
              entity.spend(num_to_payoff * loan_face_value, @bank)
            end

            if (remaining_loans = corporation.loans.size - num_to_payoff).positive?
              @log << "#{entity.name} takes on #{remaining_loans} loan#{remaining_loans == 1 ? '' : 's'}" \
                      " from #{corporation.name}"
              @loans.concat(corporation.loans)
              corporation.loans.clear

              initial_sp = entity.share_price.price
              remaining_loans.times do
                loan = @loans.pop
                entity.loans << loan
                @stock_market.move_left(entity)
              end
              @log << "#{entity.name}'s share price changes corporation" \
                      " #{format_currency(initial_sp)} to #{format_currency(entity.share_price.price)}"
            end
          end

          # Tokens
          tokened_cities = entity.tokens.select(&:used).map(&:city)
          corporation.tokens.select(&:used).dup.each do |t|
            t.destroy! if tokened_cities.include?(t.city)
          end

          max_tokens = [entity.tokens.count { |t| !t.used }, corporation.tokens.count(&:used)].min
          if max_tokens.positive?
            @log << "#{entity.name} can replace up to #{max_tokens} of #{corporation.name}'s tokens"
          else
            complete_acquisition(entity, corporation)
          end
        end

        def complete_acquisition(entity, corporation)
          graph.clear_graph_for(entity)
          @round.acquisition_corporations = []
          close_corporation(corporation, quiet: true)
        end

        def transfer_assets(from, to)
          if from.cash.positive?
            @log << "#{to.name} acquires #{format_currency(from.cash)} from #{from.name}"
            from.spend(from.cash, to)
          end

          from.companies.each do |company|
            @log << "#{to.name} acquires #{company.name} from #{from.name}"
            company.owner = to
            to.companies << company
          end
          from.companies.clear

          unless from.trains.empty?
            trains_str = from.trains.map(&:name).join(', ')
            @log << "#{to.name} acquires a #{trains_str} from #{from.name}"
            from.trains.dup.each do |t|
              buy_train(to, t, :free)
              t.operated = true
            end
          end

          if from.tokens.include?(stagecoach_token)
            stagecoach_token.corporation = to
            from.tokens.delete(stagecoach_token)
            to.tokens << stagecoach_token
            @log << "#{to.name} acquires Stagecoach token from #{from.name}"
          end

          return unless (revenue = coal_revenue(from)).positive?

          @log << "#{to.name} acquires #{format_currency(revenue)} in coal revenue from #{from.name}"

          # Connection bonuses do not transfer
          remove_connection_bonus_ability(from)

          from.all_abilities.dup.each do |ability|
            if ability.type == :coal_revenue && (coal_ability = abilities(to, :coal_revenue))
              coal_ability.bonus_revenue += ability.bonus_revenue
            else
              from.remove_ability(ability)
              to.add_ability(ability)
            end
          end
        end

        #
        # NYC Formation Round Logic
        #

        def nyc_formation_triggered?
          @nyc_formation_state
        end

        def nyc_formation_share_price
          return @nyc_share_price if @nyc_share_price
          return if (minors = minors_connected_to_albany).empty?

          nyc_calculated_value = (minors.sum { |minor| minor.share_price.price } * 2 / minors.size.to_f).ceil
          par_prices = @stock_market.share_prices_with_types(%i[par_2]).to_h do |sp|
            [sp, (sp.price - nyc_calculated_value).abs]
          end
          closest_par = par_prices.values.min
          @nyc_share_price = par_prices.select { |_sp, delta| delta == closest_par }.keys.max_by(&:price)
          @log << "NYC formation share price is #{format_currency(@nyc_share_price.price)}"
        end

        def nyc_forming?
          @nyc_formation_state == :round_one || (@nyc_formation_state == :round_two && @nyc_formed)
        end

        def nyc_formed?
          @nyc_formed
        end

        def form_nyc
          # Form the NYC
          @log << '-- Event: NYC forms --'
          nyc_corporation.floatable = true
          nyc_corporation.float_percent = 10
          @stock_market.set_par(nyc_corporation, nyc_formation_share_price)
          nyc_corporation.ipoed = true
          @nyc_formed = true
        end

        def nyc_formation_round_finished
          # At least two minors required to form NYC
          if @nyc_formation_state == :round_one && !@nyc_formed
            @log << '-- Event: NYC formation fails --'
            @log << 'Any minors remaining after the next set of Operating Rounds will be liquidated'
            convert_nyc_into_regular_corporation
            @nyc_formation_state = :round_two
            return
          end

          nyc_formation_take_loans
          liquidate_remaining_minors if @nyc_formation_state == :round_two
          if @nyc_formation_state == :round_one && !nyc_corporation.owner
            @log << "#{@first_nyc_owner.name} is the pending president of NYC and is required to buy a second share " \
                    "of NYC during their first turn in the next Stock Round to gain the president's certificate"
          end

          @nyc_formation_state = @nyc_formation_state == :round_one ? :round_two : :complete
        end

        def convert_nyc_into_regular_corporation
          @log << "#{nyc_corporation.name} can now be parred as a normal corporation"
          nyc_corporation.floatable = true
          nyc_corporation.float_percent = @float_percent
        end

        def minors_connected_to_albany
          non_blocking_graph.clear

          active_minors.select do |minor|
            # Minor 1 and 2 are always considered connected
            next true if %w[1 2].include?(minor.id)

            non_blocking_graph.reachable_hexes(minor)[albany_hex]
          end
        end

        def nyc_merger_cost(entity)
          share_price = nyc_corporation.share_price&.price || nyc_formation_share_price.price
          (entity.share_price.price * 2) - share_price
        end

        def merge_into_nyc(entity)
          unless @first_nyc_owner
            form_nyc
            @first_nyc_owner = entity.owner
          end

          @log << "#{entity.name} merges into #{nyc_corporation.name}"
          nyc_corporation.num_treasury_shares.zero? ? exchange_for_bank_share(entity) : exchange_for_nyc_share(entity)
          close_corporation(entity, quiet: true)
        end

        def exchange_for_nyc_share(entity)
          owner = entity.owner
          cost = nyc_merger_cost(entity)
          if cost.negative?
            cost = cost.abs
            @log << "#{owner.name} pays #{nyc_corporation.name} #{format_currency(cost)} and receives 1 NYC share"
            owner.spend(cost, nyc_corporation, check_cash: false)
          elsif cost.positive?
            @log << "#{owner.name} receives #{format_currency(cost)} and 1 NYC share from #{nyc_corporation.name}"
            nyc_corporation.spend(cost, owner, check_cash: false)
          end
          @share_pool.transfer_shares(ShareBundle.new(@nyc_corporation.available_share), owner)

          transfer_assets(entity, nyc_corporation)

          # Transfer token
          token = Token.new(nyc_corporation, price: 20)
          # Workaround so the game thinks the home token has been laid
          used, unused = nyc_corporation.tokens.partition(&:used)
          nyc_corporation.tokens.replace(used + [token] + unused)

          home_hex = hex_by_id(entity.coordinates)
          if nyc_corporation.tokens.map(&:hex).include?(home_hex)
            @log << "#{nyc_corporation.name} already has token at #{home_hex.name} (#{home_hex.location_name}) and " \
                    ' instead gains an extra token on its charter'
          else
            home_token = entity.tokens.find { |t| t.hex == home_hex }
            home_token.swap!(token)
            @log <<
              "#{nyc_corporation.name} gains #{entity.name}'s token at #{home_hex.name} (#{home_hex.location_name})"
          end
        end

        def nyc_formation_take_loans
          take_loan(nyc_corporation) while nyc_corporation.cash.negative?
        end

        def exchange_for_bank_share(entity)
          owner = entity.owner
          cost = nyc_merger_cost(entity)
          if cost.negative?
            cost = cost.abs
            @log << "#{owner.name} pays the bank #{format_currency(cost)} and receives 1 NYC share"
            owner.spend(cost, @bank, check_cash: false)
          elsif cost.positive?
            @log << "#{owner.name} receives #{format_currency(cost)} and 1 NYC share from the bank"
            @bank.spend(cost.abs, owner)
          end
          @share_pool.transfer_shares(ShareBundle.new(@share_pool.shares_of(nyc_corporation).first), owner)
          @log << "#{entity.name} assets go to the bank"
        end

        def liquidate_remaining_minors
          active_minors.each do |minor|
            if minor.receivership?
              @log << "#{minor.name} is liquidated"
            else
              owner = minor.owner
              @stock_market.move_left(minor)
              liquidation_price = minor.share_price.price * 2
              @log << "#{minor.name} is liquidated and #{owner.name} receives #{format_currency(liquidation_price)} " \
                      'in compensation from the bank'
              @bank.spend(liquidation_price, owner)
            end
            close_corporation(minor, quiet: true)
          end
        end
      end
    end
  end
end
