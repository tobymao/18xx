# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'stock_market'
require_relative '../../loan'
require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative '../interest_on_loans'
require_relative '../stubs_are_restricted'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1867
      class Game < Game::Base
        include_meta(G1867::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 15_000

        CERT_LIMIT = { 2 => 21, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 420, 4 => 315, 5 => 252, 6 => 210 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze

        COLUMN_MARKET = [
          %w[35
             40
             45
             50x
             55x
             60x
             65x
             70p
             80p
             90p
             100pC
             110pC
             120pC
             135pC
             150zC
             165zCm
             180z
             200z
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540],
           ].freeze

        GRID_MARKET = [['',
                        '',
                        '',
                        '',
                        '135',
                        '150',
                        '165mC',
                        '180',
                        '200z',
                        '220',
                        '245',
                        '270',
                        '300',
                        '330',
                        '360',
                        '400',
                        '440',
                        '490',
                        '540'],
                       ['',
                        '',
                        '',
                        '110',
                        '120',
                        '135',
                        '150mC',
                        '165z',
                        '180z',
                        '200',
                        '220',
                        '245',
                        '270',
                        '300',
                        '330',
                        '360',
                        '400',
                        '440',
                        '490'],
                       ['',
                        '',
                        '90',
                        '100',
                        '110',
                        '120',
                        '135pmC',
                        '150z',
                        '165',
                        '180',
                        '200',
                        '220',
                        '245',
                        '270',
                        '300',
                        '330',
                        '360',
                        '400',
                        '440'],
                       ['',
                        '70',
                        '80',
                        '90',
                        '100',
                        '110p',
                        '120pmC',
                        '135',
                        '150',
                        '165',
                        '180',
                        '200'],
                       %w[60 65 70 80 90p 100p 110mC 120 135 150],
                       %w[55 60 65 70p 80p 90 100mC 110],
                       %w[50 55 60x 65x 70 80],
                       %w[45 50x 55x 60 65],
                       %w[40 45 50 55],
                       %w[35 40 45]].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            on: '3',
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_companies export_train],
            on: '4',
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies export_train],
            on: '5',
            operating_rounds: 2,
          },
          {
            name: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            on: '6',
            operating_rounds: 2,
            status: ['export_train'],
          },
          {
            name: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            on: '7',
            operating_rounds: 2,
            status: ['export_train'],
          },
          {
            name: '8',
            train_limit: { major: 2 },
            tiles: %i[yellow green brown gray],
            on: '8',
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 225,
            rusts_on: '6',
            num: 7,
            events: [{ 'type' => 'green_minors_available' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 350,
            rusts_on: '8',
            num: 4,
            events: [{ 'type' => 'majors_can_ipo' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 550,
            num: 4,
            events: [{ 'type' => 'minors_cannot_start' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 2,
            events: [{ 'type' => 'nationalize_companies' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 1000,
            num: 6,
            events: [{ 'type' => 'signal_end_game' },
                     { 'type' => 'minors_nationalized' },
                     { 'type' => 'trainless_nationalization' },
                     { 'type' => 'train_trade_allowed' }],
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 600,
            num: 20,
            available_on: '8',
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
          {
            name: '5+5E',
            distance: [{ 'nodes' => ['offboard'], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[city town], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1500,
            num: 20,
            available_on: '8',
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
        ].freeze

        HOME_TOKEN_TIMING = :par
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always # mostly true, needs custom code
        POOL_SHARE_DROP = :none
        SELL_MOVEMENT = :down_block_pres
        ALL_COMPANIES_ASSIGNABLE = true
        SELL_AFTER = :operate
        SELL_BUY_ORDER = :sell_buy
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        GAME_END_CHECK = { bank: :current_or, final_phase: :one_more_full_or_set }.freeze

        BONUS_CAPITALS = %w[F16 L12 O7].freeze
        BONUS_REVENUE = 'D2'

        CERT_LIMIT_CHANGE_ON_BANKRUPTCY = true

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'export_train' => ['Train Export to CN',
                             'At the end of each OR the next available train will be exported
                            (given to the CN, triggering phase change as if purchased)'],
        ).freeze

        # Two lays with one being an upgrade, second tile costs 20
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        LIMIT_TOKENS_AFTER_MERGER = 2
        MINIMUM_MINOR_PRICE = 50

        EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                    'Game Ends 3 ORs after purchase/export'\
                                                                    ' of first 8 train'],
                                              'green_minors_available' => ['Green Minors become available'],
                                              'majors_can_ipo' => ['Majors can be started'],
                                              'minors_cannot_start' => ['Minors cannot start'],
                                              'minors_nationalized' => ['Minors are nationalized'],
                                              'nationalize_companies' =>
                                              ['Nationalize Private Companies',
                                               'Private companies close, paying their owner their value'],
                                              'train_trade_allowed' =>
                                              ['Train trade in allowed',
                                               'Trains can be traded in for 50% towards Phase 8 trains'],
                                              'trainless_nationalization' =>
                                              ['Trainless Nationalization',
                                               'Operating Trainless Minors are nationalized'\
                                               ', Operating Trainless Majors may nationalize']).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'Minor Corporation Par',
                                              par_2: 'Major Corporation Par',
                                              par: 'Major/Minor Corporation Par',
                                              convert_range: 'Price range to convert minor to major',
                                              max_price: 'Maximum price for a minor').freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :orange, par_2: :green, convert_range: :blue).freeze
        CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze
        # A token is reserved for Montreal is reserved for nationalization
        NATIONAL_RESERVATIONS = ['L12'].freeze
        GREEN_CORPORATIONS = %w[BBG LPS QLS SLA TGB THB].freeze
        TRAINS_REMOVE_2_PLAYER = { '2' => 3, '3' => 2, '4' => 1, '5' => 1, '6' => 1, '7' => 1 }.freeze

        include InterestOnLoans
        include CompanyPriceUpToFace
        include StubsAreRestricted

        # Minors are done as corporations with a size of 2

        attr_reader :trainless_major

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def interest_rate
          5 # constant
        end

        def game_market
          @optional_rules&.include?(:grid_market) ? self.class::GRID_MARKET : self.class::COLUMN_MARKET
        end

        def init_stock_market
          G1867::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def init_corporations(stock_market)
          major_min_price = stock_market.par_prices.map(&:price).min
          minor_min_price = MINIMUM_MINOR_PRICE
          self.class::CORPORATIONS.map do |corporation|
            Corporation.new(
              min_price: corporation[:type] == :major ? major_min_price : minor_min_price,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end
        end

        def available_programmed_actions
          [Action::ProgramMergerPass, Action::ProgramBuyShares, Action::ProgramSharePass]
        end

        def merge_rounds
          [G1867::Round::Merger]
        end

        def merge_corporations
          @corporations.select { |c| c.floated? && c.type == :minor }
        end

        def calculate_corporation_interest(corporation)
          @interest[corporation] = corporation.loans.size
        end

        def calculate_interest
          # Number of loans interest is due on is set before taking loans in that OR
          @interest.clear
          @corporations.each { |c| calculate_corporation_interest(c) }
          calculate_corporation_interest(@national)
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
          entity.type == :major ? 5 : 2
        end

        def home_token_locations(corporation)
          # Can only place home token in cities that have no other tokens.
          # Minors can go in a disconnected Toronto/Montreal station, but Majors
          # cannot.
          open_locations = hexes.select do |hex|
            case corporation.type
            when :minor
              hex.tile.cities.any? { |c| c.tokenable?(corporation, free: true) && c.tokens.none? }
            when :major
              hex.tile.cities.any? { |c| c.tokenable?(corporation, free: true) } &&
                hex.tile.cities.all? { |c| c.tokens.none? { |t| t&.type == :normal } }
            end
          end

          return open_locations if corporation.type == :minor

          if (unconnected = unconnected_hexes(open_locations)).empty?
            open_locations
          else
            unconnected
          end
        end

        def unconnected_hexes(locs)
          locs.reject do |hex|
            hex.tile.cities.any? do |city|
              city.paths.any? do |path|
                path.walk do |current|
                  next if path == current
                  break true if current.node?
                end
              end
            end
          end
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          super(
            share_holder,
            corporation,
            shares: shares || share_holder.shares_of(corporation).select { |share| share.percent.positive? },
          )
        end

        def take_loan(entity, loan)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          name = entity.name
          amount = loan.amount - 5
          @log << "#{name} takes a loan and receives #{format_currency(amount)}"
          @bank.spend(amount, entity)
          entity.loans << loan
          @loans.delete(loan)
        end

        def repay_loan(entity, loan)
          @log << "#{entity.name} pays off a loan for #{format_currency(loan.amount)}"
          entity.spend(loan.amount, bank)

          entity.loans.delete(loan)
          @loans << loan
        end

        def can_take_loan?(entity)
          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            @loans.any?
        end

        def buying_power(entity, full: false)
          return entity.cash unless full
          return entity.cash unless entity.corporation?

          # Loans are actually generate $5 less than when taken out.
          entity.cash + ((maximum_loans(entity) - entity.loans.size) * (@loan_value - 5))
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def sorted_corporations
          # Corporations sorted by some potential game rules
          ipoed, others = corporations.partition(&:ipoed)

          # hide non-ipoed majors until phase 4
          others.reject! { |c| c.type == :major } unless @show_majors
          ipoed.sort + others
        end

        def unstarted_corporation_summary
          unipoed = (@corporations + @future_corporations).reject(&:ipoed)
          minor = unipoed.select { |c| c.type == :minor }
          major = unipoed.select { |c| c.type == :major }
          ["#{minor.size} minor, #{major.size} major", [@national]]
        end

        def show_value_of_companies?(_owner)
          true
        end

        def nationalization_loan_movement(corporation)
          corporation.loans.each do
            stock_market.move_left(corporation)
            stock_market.move_left(corporation)
          end
        end

        def nationalization_transfer_assets(corporation); end

        def nationalize!(corporation)
          return if !corporation.floated? || !@corporations.include?(corporation)

          @log << "#{corporation.name} is nationalized"

          repay_loan(corporation, corporation.loans.first) while corporation.cash >= @loan_value && !corporation.loans.empty?

          # Move once automatically
          old_price = corporation.share_price
          stock_market.move_left(corporation)

          nationalization_loan_movement(corporation)
          nationalization_transfer_assets(corporation)
          log_share_price(corporation, old_price)

          # Payout players for shares
          per_share = corporation.share_price.price
          total_payout = corporation.total_shares * per_share
          payouts = {}
          @players.each do |player|
            amount = player.num_shares_of(corporation) * per_share
            next if amount.zero?

            payouts[player] = amount
            @bank.spend(amount, player)
          end

          if payouts.any?
            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')

            @log << "#{corporation.name} settles with shareholders #{format_currency(total_payout)} = "\
                    "#{format_currency(per_share)} (#{receivers})"
          end

          # Rules say if not enough tokens remain, do it in highest payout then randomly
          # We'll treat random as in hex order
          corporation.tokens.select(&:used)
          .sort_by { |t| [t.city.max_revenue, t.city.hex.id] }
          .reverse_each do |token|
            city = token.city
            token.remove!

            next if city.tile.cities.any? do |c|
                      c.tokens.any? do |t|
                        t&.corporation == @national && t&.type != :neutral
                      end
                    end

            new_token = @national.next_token
            next unless new_token

            # Remove national token reservations if any
            city.tile.cities.each { |c| c.remove_reservation!(@national) }

            if @national_reservations.include?(city.hex.id)
              @national_reservations.delete(city.hex.id)
            elsif @national.tokens.count { |t| !t.used } == @national_reservations.size
              # Don't place if only reservations are left
              next
            end

            city.place_token(@national, new_token, check_tokenable: false)
          end

          # Close corp (minors close, majors reset)
          if corporation.type == :minor
            close_corporation(corporation)
          else
            reset_corporation(corporation)
            @round.force_next_entity! if @round.current_entity == corporation
          end
        end

        def place_639_token(tile)
          return unless @national_reservations.any?
          return if tile.cities.any? { |c| c.tokened_by?(@national) }
          return unless (new_token = @national.next_token)

          @log << "#{@national.name} places a token on #{tile.hex.location_name}"
          @national_reservations.delete(tile.hex.id)
          # Montreal only has the one city, given it should be reserved then next token should be valid
          tile.cities.first.place_token(@national, new_token, check_tokenable: false)
        end

        def revenue_for(route, stops)
          revenue = super

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          route.corporation.companies.each do |company|
            abilities(company, :hex_bonus) do |ability|
              revenue += stops.map { |s| s.hex.id }.uniq&.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
            end
          end

          # Quebec, Montreal and Toronto
          capitals = stops.find { |stop| self.class::BONUS_CAPITALS.include?(stop.hex.name) }
          # Timmins
          timmins = stops.find { |stop| stop.hex.name == self.class::BONUS_REVENUE }

          revenue += 40 * (route.train.multiplier || 1) if capitals && timmins

          revenue
        end

        def can_go_bankrupt?(player, corporation)
          total_emr_buying_power(player, corporation).negative?
        end

        def total_emr_buying_power(player, _corporation)
          liquidity(player, emergency: true)
        end

        def total_rounds(name)
          # Return the total number of rounds for those with more than one.
          # Merger exists twice since it's logged as the long form, but shown on the UI in the short form
          @operating_rounds if ['Operating', 'Merger', 'Merger and Conversion', 'Acquisition'].include?(name)
        end

        def corporation_size(entity)
          # For display purposes is a corporation small, medium or large
          CORPORATION_SIZES[entity.total_shares]
        end

        def corporation_size_name(entity)
          entity.type == :national ? 'Nat’l' : entity.type.capitalize
        end

        def compute_stops(route)
          # 1867 should always have two distances, one with a pay of zero, the other with the full distance.
          visits = route.visited_stops
          distance = route.train.distance
          return [] if visits.empty?

          mandatory_distance = distance.find { |d| d['pay'].positive? }

          # Find all the mandatory stops
          mandatory_stops, optional_stops = visits.partition { |node| mandatory_distance['nodes'].include?(node.type) }

          # Only both with the extra step if it's not all mandatory
          return mandatory_stops if mandatory_stops.size == mandatory_distance['pay']

          need_token = mandatory_stops.none? { |stop| stop.tokened_by?(route.corporation) }

          remaining_stops = mandatory_distance['pay'] - mandatory_stops.size

          # Allocate optional stops, combination returns nothing if stops doesn't cover the remaining stops
          combinations = optional_stops.combination(remaining_stops.to_i).to_a
          combinations = [optional_stops] if combinations.empty?
          stops, revenue = combinations.map do |stops|
            # Make sure this set of stops is legal
            # 1) At least one stop must have a token (for 5+5E train)
            next if need_token && stops.none? { |stop| stop.tokened_by?(route.corporation) }

            all_stops = mandatory_stops + stops
            [all_stops, revenue_for(route, all_stops)]
          end.compact.max_by(&:last)

          revenue ||= 0

          return stops if revenue.positive?
        end

        def post_train_buy
          postevent_trainless_nationalization! if @trainless_nationalization
        end

        def player_value(player)
          share_prices = {}

          player.cash + player.companies.sum(&:value) + player.shares.sum do |cert|
            corp = cert.corporation
            next 0 unless corp.ipoed

            share_prices[corp] ||=
              if corp.loans.empty?
                corp.share_price.price
              else
                # corporations with loans will move to the left once per loan when
                # the game is over
                stock_market.find_share_price(corp, [:left] * corp.loans.size).price
              end

            share_prices[corp] * cert.num_shares
          end
        end

        def end_game!(player_initiated: false)
          return if @finished

          logged_drop = false
          @corporations.each do |corporation|
            next if corporation.loans.empty?

            @log << '-- Loans are "paid off" by moving share price left one step per loan --' unless logged_drop
            logged_drop = true

            old_price = corporation.share_price

            (num_loans = corporation.loans.size).times do
              stock_market.move_left(corporation)
              @loans << corporation.loans.pop
            end
            log_share_price(corporation, old_price, num_loans, log_steps: true)
          end

          super
        end

        def game_end_check
          @game_end_check ||= super
        end

        private

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1867::Step::SingleItemAuction,
          ])
        end

        def stock_round
          G1867::Round::Stock.new(self, [
            G1867::Step::MajorTrainless,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1867::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          calculate_interest
          G1867::Round::Operating.new(self, [
            G1867::Step::MajorTrainless,
            Engine::Step::BuyCompany,
            G1867::Step::RedeemShares,
            G1867::Step::Track,
            G1867::Step::Token,
            Engine::Step::Route,
            G1867::Step::Dividend,
            # The blocking buy company needs to be before loan operations
            [G1867::Step::BuyCompanyPreloan, { blocks: true }],
            G1867::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1867::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          current_phase = phase.name.to_i
          depot.export! if current_phase >= 4 && current_phase <= 7
          post_train_buy
        end

        def new_or!
          if @round.round_num < @operating_rounds
            new_operating_round(@round.round_num + 1)
          else
            @turn += 1
            or_set_finished
            new_stock_round
          end
        end

        def next_round!
          clear_interest_paid
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if phase.name.to_i < 3 || phase.name.to_i >= 8
                new_or!
              else
                @log << "-- #{round_description('Merger', @round.round_num)} --"
                G1867::Round::Merger.new(self, [
                  G1867::Step::MajorTrainless,
                  G1867::Step::PostMergerShares, # Step C & D
                  G1867::Step::ReduceTokens, # Step E
                  Engine::Step::DiscardTrain, # Step F
                  G1867::Step::Merge,
                ], round_num: @round.round_num)
              end
            when G1867::Round::Merger
              new_or!
            when init_round.class
              reorder_players
              new_stock_round
            end
        end

        def init_loans
          @loan_value = 50
          # 16 minors * 2, 8 majors * 5
          Array.new(72) { |id| Loan.new(id, @loan_value) }
        end

        def loan_value(_entity = nil)
          @loan_value
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        def add_neutral_tokens
          @green_tokens = []
          logo = '/logos/1867/neutral.svg'
          @hexes.each do |hex|
            case hex.id
            when 'D2'
              token = Token.new(@national, price: 0, logo: logo, simple_logo: logo, type: :neutral)
              hex.tile.cities.first.exchange_token(token)
              @green_tokens << token
            when 'L12'
              token = Token.new(@national, price: 0, logo: logo, simple_logo: logo, type: :neutral)
              hex.tile.cities.last.exchange_token(token)
              @green_tokens << token
            when 'F16'
              hex.tile.cities.first.exchange_token(@national.tokens.first)
            end
          end
        end

        def setup_preround
          setup_for_2_players if @players.size == 2
        end

        def setup_for_2_players
          # Only been tested for 1861, but Ian think's it'll work for 1867.
          @log << '1867 has not been tested for 2 players.' if instance_of?(G1867::Game)

          # 70% not 60%
          @corporations.each { |c| c.max_ownership_percent = 70 if c.max_ownership_percent == 60 }

          # Remove trains
          TRAINS_REMOVE_2_PLAYER.each do |train_name, count|
            trains = depot.upcoming.select { |t| t.name == train_name }.reverse.take(count)

            trains.each { |t| depot.forget_train(t) }
          end

          # Standard game, remove 2 privates randomly
          removal_companies = @companies.reject { |c| c.id == '3' }.sort_by { rand }.take(2)
          @log << "Following companies are removed #{removal_companies.map(&:id).join(', ')}"
          removal_companies.each { |company| @companies.delete(company) }
        end

        def setup
          @interest = {}
          setup_company_price_up_to_face

          # Hide the special 3 company
          @hidden_company = company_by_id('3')

          # CN corporation only exists to hold tokens
          @national = @corporations.find { |c| c.type == :national }
          @national.ipoed = true
          @national.shares.clear
          @national.shares_by_corporation[@national].clear

          @national_reservations = self.class::NATIONAL_RESERVATIONS.dup
          @corporations.delete(@national)
          add_neutral_tokens

          # Move green and majors out of the normal list
          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end
          @show_majors = false
        end

        def event_green_minors_available!
          @log << 'Green minors are now available'

          # Can now lay on the 3
          @hidden_company.close!
          # Remove the green tokens
          @green_tokens.map(&:remove!)

          # All the corporations become available, as minors can now merge/convert to corporations
          @corporations += @future_corporations
          @future_corporations = []
        end

        def event_majors_can_ipo!
          @log << 'Majors can now be started'
          @show_majors = true
          # Done elsewhere
        end

        def event_train_trade_allowed!; end

        def event_minors_cannot_start!
          @corporations, removed = @corporations.partition do |corporation|
            corporation.owned_by_player? || corporation.type != :minor
          end

          hexes.each do |hex|
            hex.tile.cities.each do |city|
              city.reservations.reject! { |reservation| removed.include?(reservation) }
            end
          end

          @log << 'Minors can no longer be started' if removed.any?
        end

        def event_minors_nationalized!
          # Given minors have a train limit of 1, this shouldn't cause the order to be disrupted.
          corporations, removed = @corporations.partition do |corporation|
            corporation.type != :minor
          end
          @log << 'Minors nationalized' if removed.any?
          removed.sort.each { |c| nationalize!(c) }
          @corporations = corporations
        end

        def event_signal_end_game!
          # There's always 3 ORs after the 8 train is bought
          @final_operating_rounds = 3
          # Hit the game end check now to set the correct turn
          game_end_check
          @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
        end

        def event_trainless_nationalization!
          # Store flag, has to be done after the trains are rusted
          @trainless_nationalization = true
        end

        def postevent_trainless_nationalization!
          trainless = @corporations.select { |c| c.operated? && c.trains.none? }.sort

          @trainless_major = []
          trainless.each do |c|
            case c.type
            when :major
              @trainless_major << c
            when :minor
              nationalize!(c)
            end
          end

          @trainless_major = @trainless_major.sort
          @trainless_nationalization = false
        end

        def event_nationalize_companies!
          @log << '-- Event: Private companies are nationalized --'

          @companies.each do |company|
            next if company.owner == @national
            next if company == @hidden_company
            next if company.closed?

            @bank.spend(company.value, company.owner)

            @log << "#{company.name} nationalized from #{company.owner.name} for #{format_currency(company.value)}"
            company.owner.companies.delete(company)
            company.owner = @national
            @national.companies << company
          end
        end
      end
    end
  end
end
