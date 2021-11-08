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

        attr_reader :privates_closed
        attr_accessor :stagecoach_token

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :operate

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        SELL_BUY_ORDER = :sell_buy

        GAME_END_CHECK = { banrkupt: :immediate, bank: :full_or, custom: :immediate }.freeze

        ALL_COMPANIES_ASSIGNABLE = true

        CLOSED_CORP_TRAINS_REMOVED = false

        TRACK_RESTRICTION = :permissive

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
          %w[60 65 70 75x 80p 90 100 110 125 150 175 200 230 260 300 350
             400],
          %w[55 60 65 70x 75p 80 90 100 110 125 150 175],
          %w[50 55 60 65x 70p 75 80 90 100 110 125],
          %w[40 50 55 60x 65p 70 75 80 90 100],
          %w[30 40 50 55x 60 65 70 75 80],
          %w[20 30 40 50x 55 60 65 70],
          %w[10 20 30 40 50 55 60],
          %w[0c 10 20 30 40 50],
          %w[0c 0c 10 20 30],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'Minor Corporation Par',
                                              par: 'Major Corporation Par')
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :gray, par: :red).freeze

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
            name: '5DE',
            on: '5DE',
            train_limit: { major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: { major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2H', num: 11, distance: 2, price: 100, rusts_on: '6H' },
                  { name: '4H', num: 6, distance: 4, price: 200, rusts_on: '5DE', events: [{ type: 'float_30' }] },
                  { name: '6H', num: 4, distance: 6, price: 300, rusts_on: 'D', events: [{ type: 'float_40' }] },
                  {
                    name: '12H',
                    num: 2,
                    distance: 12,
                    price: 600,
                    events: [{ type: 'float_50' }, { type: 'close_companies' }, { type: 'nyc_formation' }],
                  },
                  { name: '12H', num: 1, distance: 12, price: 600, events: [{ type: 'capitalization_round' }] },
                  {
                    name: '5DE',
                    num: 2,
                    distance: [{ nodes: %w[city offboard town], pay: 5, visit: 99, multiplier: 2 }],
                    price: 800,
                    events: [{ type: 'float_60' }],
                  },
                  { name: 'D', num: 20, distance: 99, price: 1000 }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          float_30: ['30% to Float', 'Companies must have 30% of their shares sold to float'],
          float_40: ['40% to Float', 'Companies must have 40% of their shares sold to float'],
          float_50: ['50% to Float', 'Companies must have 50% of their shares sold to float'],
          float_60:
            ['60% to Float', 'Companies must have 60% of their shares sold to float and receive full capitalization'],
          nyc_formation: ['NYC Formation', 'Triggers the formation of the NYC'],
          capitalization_round:
            ['Capitalization Round', 'Special Capitalization Round before next Stock Round'],
        ).freeze

        ERIE_CANAL_ICON = 'canal'
        CONNECTION_BONUS_ICON = 'connection_bonus'
        COAL_ICON = 'coal'

        ASSIGNMENT_TOKENS = {
          'connection_bonus' => '/icons/18_ny/connection_bonus.svg',
          'coal' => '/icons/18_ny/coal.svg',
        }.freeze

        CONNECTION_BONUS_HEXES =
          %w[A13 A19 A23 B12 C11 C23 C25 D0 D18 D20 E9 F10 F12 G9 G13 G19 G21 G25 I19 I23 J18 J22 J26 K19].freeze
        COAL_LOCATIONS = [%w[F0 G1], %w[H2 H4], %w[H6 H8 H10], ['H12'], %w[I13 J14], %w[K15 K17]].freeze

        def setup
          @interest = {}
          @stagecoach_token =
            Token.new(nil, logo: '/logos/18_ny/stagecoach.svg', simple_logo: '/logos/18_ny/stagecoach.alt.svg')
          init_connection_bonuses
          init_coal_tokens
        end

        def init_connection_bonuses
          CONNECTION_BONUS_HEXES.each { |hex_id| hex_by_id(hex_id).assign!(CONNECTION_BONUS_ICON) }
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

        def init_stock_market
          G18NY::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
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
          G18NY::Round::Operating.new(self, [
            G18NY::Step::StagecoachExchange,
            Engine::Step::BuyCompany,
            G18NY::Step::CheckCoalConnection,
            G18NY::Step::EmergencyMoneyRaising,
            G18NY::Step::SpecialTrack,
            G18NY::Step::SpecialToken,
            G18NY::Step::Track,
            G18NY::Step::Token,
            G18NY::Step::Route,
            G18NY::Step::Dividend,
            G18NY::Step::LoanInterestPayment,
            G18NY::Step::LoanRepayment,
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialBuyTrain,
            G18NY::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def next_round!
          clear_interest_paid
          super
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
          non_floated_companies { |c| c.float_percent = 30 }
        end

        def event_float_40!
          @log << "-- Event: #{EVENTS_TEXT['float_40'][1]} --"
          non_floated_companies { |c| c.float_percent = 40 }
        end

        def event_float_50!
          @log << "-- Event: #{EVENTS_TEXT['float_50'][1]} --"
          non_floated_companies { |c| c.float_percent = 50 }
        end

        def event_float_60!
          @log << "-- Event: #{EVENTS_TEXT['float_60'][1]} --"
          non_floated_companies do |c|
            c.float_percent = 60
            c.capitalization = :full
            c.spend(c.cash, @bank) if c.cash.positive?
          end
        end

        def event_nyc_formation!
          @log << "-- Event: #{EVENTS_TEXT['nyc_formation'][1]} --"
        end

        def event_capitalization_round!
          @log << "-- Event: #{EVENTS_TEXT['capitalization_round'][1]} --"
        end

        def non_floated_companies
          @corporations.each { |c| yield c unless c.floated? }
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

        def check_sale_timing(_entity, corporation)
          return true if corporation.name == 'NYC'

          super
        end

        def can_par?(corporation, _parrer)
          return false if corporation.name == 'NYC'

          super
        end

        def can_hold_above_limit?(_entity)
          true
        end

        def float_corporation(corporation)
          super
          # TODO: verify NYC will not be affected
          return unless corporation.capitalization == :full

          @log << 'Remaining shares placed in the market'
          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation)), @share_pool)
        end

        #
        # Operating round logic
        #

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
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

          super
        end

        def town_to_city_upgrade?(from, to)
          return false unless @phase.tiles.include?(:green)

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

        def upgrades_to_correct_label?(from, to)
          # Handle hexes that change from standard tiles to special city tiles
          case from.hex.name
          when 'E3'
            return true if to.name == 'X35'
            return false if to.color == :gray
          when 'D8'
            return true if to.name == 'X13'
            return false if to.color == :green
          when 'D12'
            return true if to.name == 'X24'
            return false if to.color == :brown
          when 'K19'
            return true if to.name == 'X21'
            return false if to.color == :brown
          end

          super
        end

        def legal_tile_rotation?(entity, hex, tile)
          # NYC tiles have a specific rotation
          return tile.rotation.zero? if hex.id == 'J20' && %w[X11 X22].include?(tile.name)

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

        def route_distance(route)
          # Count hex edges
          route.chains.sum { |conn| conn[:paths].each_cons(2).sum { |a, b| a.hex == b.hex ? 0 : 1 } }
        end

        def route_distance_str(route)
          "#{route_distance(route)}H"
        end

        def check_distance(route, _visits)
          limit = route.train.distance
          distance = route_distance(route)
          raise GameError, "#{distance} is too many hex edges for #{route.train.name} train" if distance > limit
        end

        def revenue_for(route, stops)
          super + (stops.count { |stop| stop.hex.assigned?(CONNECTION_BONUS_ICON) } * 10)
        end

        def revenue_str(route)
          str = super

          if (num_bonuses = route.stops.count { |stop| stop.hex.assigned?(CONNECTION_BONUS_ICON) }).positive?
            str += " + #{num_bonuses} Connection Bonus#{num_bonuses == 1 ? '' : 'es'}"
          end

          str
        end

        def routes_revenue(routes)
          revenue = super
          revenue += connection_bonus_revenue(current_entity)
          revenue += coal_revenue(current_entity)

          revenue
        end

        def connection_bonus_revenue(entity)
          abilities(entity, :connection_bonus)&.bonus_revenue || 0
        end

        def claim_connection_bonus(entity, hex)
          @log << "#{entity.name} claims the connection bonus at #{hex.name} (#{hex.location_name})"
          hex.remove_assignment!('connection_bonus')
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
          return unless (ability = @game.abilities(entity, :connection_bonus))

          entity.remove_ability(ability)
        end

        def coal_revenue(entity)
          abilities(entity, :coal_revenue)&.bonus_revenue || 0
        end

        def connected_coal_hexes(entity)
          return if @coal_locations.empty?

          graph.connected_hexes(entity).keys & @coal_locations.flatten
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

        def add_coal_token_ability(entity, _num_tokens)
          entity.add_ability(G18NY::Ability::CoalRevenue.new(type: :coal_revenue, bonus_revenue: 10))
        end

        def coal_location_name(location)
          location.find(&:location_name)&.location_name
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
          salvage_train(train)
          super
        end

        def remove_train(train)
          owner = train.owner
          super
          return unless owner&.corporation?

          remove_connection_bonus_ability(owner) if owner.trains.size.zero? && current_entity != owner
        end

        def init_loans
          @loan_value = 50
          # 11 minors * 2, 8 majors * 10
          Array.new(102) { |id| Loan.new(id, @loan_value) }
        end

        def interest_rate
          5
        end

        def calculate_corporation_interest(corporation)
          @interest[corporation] = corporation.loans.size
        end

        def calculate_interest
          # Number of loans interest is due on is set before taking loans in that OR
          @interest.clear
          @corporations.each { |c| calculate_corporation_interest(c) }
        end

        def emergency_issuable_bundles(corp)
          bundles = bundles_for_corporation(corp, corp)

          num_issuable_shares = [5 - corp.num_market_shares, corp.num_player_shares].min
          bundles.reject { |bundle| bundle.num_shares > num_issuable_shares }.sort_by(&:price)
        end

        def interest_owed_for_loans(loans)
          interest_rate * loans
        end

        def loans_due_interest(entity)
          @interest[entity] || 0
        end

        def interest_owed(entity)
          interest_rate * loans_due_interest(entity)
        end

        def maximum_loans(entity)
          entity.num_player_shares
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
          entity.corporation? && entity.loans.size < maximum_loans(entity)
        end

        def buying_power(entity, full: false)
          return entity.cash unless full
          return entity.cash unless entity.corporation?

          num_loans = maximum_loans(entity) - entity.loans.size
          entity.cash + (num_loans * loan_value(entity))
        end
      end
    end
  end
end
