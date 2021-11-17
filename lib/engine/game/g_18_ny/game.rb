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

        SELL_BUY_ORDER = :sell_buy_or_buy_sell

        GAME_END_CHECK = { banrkupt: :immediate, bank: :full_or, custom: :full_or }.freeze

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
                  { name: '4H', num: 6, distance: 4, price: 200, rusts_on: '5DE', events: [{ 'type' => 'float_30' }] },
                  { name: '6H', num: 4, distance: 6, price: 300, rusts_on: 'D', events: [{ 'type' => 'float_40' }] },
                  {
                    name: '12H',
                    num: 2,
                    distance: 12,
                    price: 600,
                    events: [{ 'type' => 'float_50' }, { 'type' => 'close_companies' }, { 'type' => 'nyc_formation' }],
                  },
                  { name: '12H', num: 1, distance: 12, price: 600, events: [{ 'type' => 'capitalization_round' }] },
                  {
                    name: '5DE',
                    num: 2,
                    distance: [{ nodes: %w[city offboard town], pay: 5, visit: 99, multiplier: 2 }],
                    price: 800,
                    events: [{ 'type' => 'float_60' }],
                  },
                  { name: 'D', num: 20, distance: 99, price: 1000 }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'float_30' => ['30% to Float', 'Corporations must have 30% of their shares sold to float'],
          'float_40' => ['40% to Float', 'Corporations must have 40% of their shares sold to float'],
          'float_50' => ['50% to Float', 'Corporations must have 50% of their shares sold to float'],
          'float_60' =>
            ['60% to Float', 'Corporations must have 60% of their shares sold to float and receive full capitalization'],
          'nyc_formation' => ['NYC Formation', 'NYC formation triggered'],
          'capitalization_round' =>
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
          @float_percent = 20
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

        def nyc_corporation
          @nyc_corporation ||= corporation_by_id('NYC')
        end

        def albany_hex
          @albany_hex ||= hex_by_id('F20')
        end

        def active_minors
          operating_order.select { |c| c.type == :minor && c.floated? }
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
            G18NY::Step::Bankrupt,
            G18NY::Step::CheckCoalConnection,
            G18NY::Step::CheckNYCFormation,
            G18NY::Step::BuyCompany,
            G18NY::Step::ReplaceTokens,
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
            G18NY::Step::AcquireCorporation,
            [G18NY::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def new_nyc_formation_round(round_num)
          form_nyc_corporation if @nyc_formation_state == :round_one
          G18NY::Round::NYCFormation.new(self, [
            G18NY::Step::MergeWithNYC,
          ], round_num: round_num)
        end

        def next_round!
          clear_interest_paid

          @round =
            case @round
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
                else
                  @turn += 1
                  new_stock_round
                end
              end
            when G18NY::Round::NYCFormation
              @turn += 1
              nyc_formation_round_complete
              new_stock_round
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
          @float_percent = 50
          non_floated_corporations do |c|
            c.float_percent = @float_percent
            c.capitalization = :full
            c.spend(c.cash, @bank) if c.cash.positive?
          end
        end

        def event_nyc_formation!
          return if @nyc_formation_state

          @log << "-- Event: #{EVENTS_TEXT['nyc_formation'][1]} --"
          @nyc_formation_state = :round_one

          @log << 'No further minor corporations may be started'
          @corporations.select { |c| c.type == :minor && !c.floated? && !c.closed? }.each(&:close!)
        end

        def event_capitalization_round!
          @log << "-- Event: #{EVENTS_TEXT['capitalization_round'][1]} --"
        end

        def non_floated_corporations
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

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def can_buy_presidents_share_directly_from_market?
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

        def non_blocking_graph
          @non_block_graph ||= Graph.new(self, no_blocking: true, home_as_token: true)
        end

        def albany_and_buffalo_connected?
          @buffalo_corp ||=
            Engine::Corporation.new(name: 'Buffalo', sym: 'BUF', tokens: [], coordinates: 'E3')

          non_blocking_graph.clear_graph_for(@buffalo_corp)
          non_blocking_graph.connected_hexes(@buffalo_corp).key?(albany_hex)
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

          revenue += connection_bonus_revenue(@round.current_operator)
          revenue += coal_revenue(@round.current_operator)

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
          return unless (ability = abilities(entity, :connection_bonus))

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

        def add_coal_token_ability(entity, revenue: 10)
          entity.add_ability(G18NY::Ability::CoalRevenue.new(type: :coal_revenue, bonus_revenue: revenue))
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

        def must_buy_train?(entity)
          return false if entity.type == :minor

          super
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
            @log << "#{entity.name} pays #{corporation.owner.name} #{format_currency(cost)}"
            entity.spend(cost, corporation.owner)
          else
            corporation.share_holders.keys.each do |sh|
              next if sh == corporation

              cost = share_price * sh.num_shares_of(corporation) * multiplier
              @log << "#{entity.name} pays #{sh.name} #{format_currency(cost)}"
              entity.spend(share_price * sh.num_shares_of(corporation), sh)
            end
          end

          transfer_assets(corporation, entity)

          # Loans
          unless corporation.loans.empty?
            num_to_payoff = [entity.cash / loan_face_value, corporation.loans.size].min
            @log << "#{entity.name} pays off #{num_to_payoff} of #{corporation.name}'s loans"
            entity.spend(num_to_payoff * loan_face_value, @bank)

            if (remaining_loans = corporation.loans.size - num_to_payoff).positive?
              @log << "#{entity.name} takes on #{remaining_loans} loan#{remaining_loans == 1 ? '' : 's'}" \
                      " corporation #{corporation.name}"
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

        def complete_acquisition(_entity, corporation)
          @round.acquisition_corporations = []
          close_corporation(corporation, quiet: true)
        end

        def transfer_assets(from, to)
          if from.cash.positive?
            @log << "#{to.name} acquires #{format_currency(from.cash)}"
            from.spend(from.cash, to)
          end

          from.companies.each do |company|
            @log << "#{to.name} acquires #{company.name}"
            company.owner = to
            to.companies << company
          end
          from.companies.clear

          unless from.trains.empty?
            trains_str = from.trains.map(&:name).join(', ')
            @log << "#{to.name} acquires a #{trains_str}"
            from.trains.dup.each { |t| buy_train(to, t, :free) }
          end

          return unless (revenue = coal_revenue(from)).positive?

          @log << "#{to.name} acquires #{format_currency(revenue)} in coal revenue"

          if (ability = abilities(to, :coal_revenue))
            ability.bonus_revenue += revenue
          else
            add_coal_token_ability(to, revenue: revenue)
          end
        end

        #
        # NYC Formation Round Logic
        #

        def nyc_formation_triggered?
          @nyc_formation_state
        end

        def form_nyc_corporation
          # Calculate NYC par price
          minors = minors_connected_to_albany
          nyc_calculated_value = (minors.sum { |minor| minor.share_price.price } * 2 / minors.size.to_f)
          par_prices = @stock_market.share_prices_with_types(%i[par_2]).to_h do |sp|
            [sp, (sp.price - nyc_calculated_value).abs]
          end
          closest_par = par_prices.values.min
          nyc_par_price = par_prices.select { |_sp, delta| delta == closest_par }.keys.max_by(&:price)

          # Form the NYC
          @log << "#{nyc_corporation.name} forms with a share price of #{format_currency(nyc_par_price.price)}"
          nyc_corporation.floatable = true
          nyc_corporation.float_percent = @float_percent
          @stock_market.set_par(nyc_corporation, nyc_par_price)
          after_par(nyc_corporation)
        end

        def nyc_formation_round_complete
          nyc_formation_take_loans
          if @nyc_formation_state == :round_one
            @nyc_formation_state = :round_two
          else
            liquidate_remaining_minors
            @nyc_formation_state = :complete
          end
        end

        def minors_connected_to_albany
          non_blocking_graph.clear

          active_minors.select do |minor|
            # Minor 1 and 2 are always considered connected
            next true if %w[1 2].include?(minor.id)

            non_blocking_graph.connected_hexes(minor).key?(albany_hex)
          end
        end

        def nyc_merger_cost(entity)
          (entity.share_price.price * 2) - nyc_corporation.share_price.price
        end

        def merge_into_nyc(entity)
          @first_nyc_owner ||= entity.owner

          @log << "#{entity.name} merges into #{nyc_corporation.name}"
          nyc_corporation.num_treasury_shares.zero? ? exchange_for_bank_share(entity) : exchange_for_nyc_share(entity)
          entity.close!
        end

        def exchange_for_nyc_share(entity)
          owner = entity.owner
          cost = nyc_merger_cost(entity)
          if cost.negative?
            owner.spend(cost, nyc_corporation, check_cash: false)
          elsif cost.positive?
            nyc_corporation.spend(cost.abs, owner, check_cash: false)
          end
          @share_pool.transfer_shares(ShareBundle.new(@nyc_corporation.available_share), owner)

          transfer_assets(entity, nyc_corporation)

          # Transfer token
          token = Token.new(nyc_corporation, price: 20)
          nyc_corporation.tokens << token

          home_hex = hex_by_id(entity.coordinates)
          if nyc_corporation.tokens.map(&:hex).include?(home_hex)
            @log << "#{nyc_corporation.name} already has token at #{home_hex.name} (#{home_hex.location_name}) and " \
                    ' instead gains an extra token on charter'
          else
            home_token = entity.tokens.find { |t| t.hex == home_hex }
            home_token.swap!(token)
            @log << "#{nyc_corporation.name} gains a token at #{home_hex.name} (#{home_hex.location_name})"
          end
        end

        def nyc_formation_take_loans
          take_loan(nyc_corporation) while nyc_corporation.cash.negative?
        end

        def exchange_for_bank_share(entity)
          owner = entity.owner
          cost = nyc_merger_cost(entity)
          if cost.negative?
            owner.spend(cost, @bank, check_cash: false)
          elsif cost.positive?
            @bank.spend(cost.abs, owner)
          end
          @share_pool.transfer_shares(ShareBundle.new(@share_pool.shares_of(nyc_corporation).first), owner)
          @log << "#{entity.name} assets go to the bank"
        end

        def liquidate_remaining_minors
          active_minors.each do |minor|
            @stock_market.move_left(minor)
            liquidation_price = minor.share_price.price * 2
            @log << "#{minor.name} is liquidated for #{format_currency(liquidation_price)}"
            minor.close!
          end
        end
      end
    end
  end
end
