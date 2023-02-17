# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative '../base'
require_relative '../../loan'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1848
      class Game < Game::Base
        attr_reader :sydney_adelaide_connected, :boe, :private_closed_triggered, :take_out_loan_triggered,
                    :can_buy_trains, :com_can_operate

        include_meta(G1848::Meta)
        include Map
        include CitiesPlusTownsRouteDistanceStr

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 20, 4 => 17, 5 => 14, 6 => 12 }.freeze

        CERT_LIMIT_RECEIVERSHIP = {
          3 => { 1 => 18, 2 => 16, 3 => 14, 4 => 12, 5 => 10 },
          4 => { 1 => 15, 2 => 13, 3 => 11, 4 => 10, 5 => 9 },
          5 => { 1 => 13, 2 => 12, 3 => 10, 4 => 9, 5 => 8 },
          6 => { 1 => 11, 2 => 10, 3 => 9, 4 => 8, 5 => 7 },
        }.freeze

        CERT_LIMIT_RECEIVERSHIP_REDUCTION = { 3 => 2, 4 => 2, 5 => 1, 6 => 1 }.freeze

        STARTING_CASH = { 3 => 840, 4 => 630, 5 => 510, 6 => 430 }.freeze

        K_BONUS = { 0 => 0, 1 => 0, 2 => 50, 3 => 100, 4 => 150, 5 => 200 }.freeze

        BOE_STARTING_CASH = 2000

        BOE_STARTING_PRICE = 70

        BOE_ROW = 6

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        EBUY_PRES_SWAP = false

        EBUY_CAN_SELL_SHARES = false

        CERT_LIMIT_INCLUDES_PRIVATES = false

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        EBUY_CORP_LOANS_RECEIVERSHIP = true

        DISCARDED_TRAINS = :remove

        TRACK_RESTRICTION = :permissive

        MARKET = [
          %w[0c
             70
             80
             90
             100
             110
             120
             140
             160
             190
             220
             250
             280
             320
             360
             400
             450e],
          %w[0c
             60
             70
             80
             90
             100p
             110
             130
             150
             180
             210
             240
             270
             310
             350
             390
             440],
          %w[0c
             50
             60
             70
             80
             90p
             100
             120
             140
             170
             200
             230
             260
             300],
          %w[0c 40 50 60 70 80p 90 110 130 160 190],
          %w[0c 30 40 50 60 70p 80 100 120],
          %w[0c 20 30 40 50 60 70],
          %w[70r
             80r
             90r
             100r
             110r
             120r
             130r
             140r
             150r
             160r
             170r
             180r
             195r
             210r
             225r
             240r
             260e
             280r
             300r
             320r
             340r],
        ].freeze

        MARKET_TEXT = {
          par: 'Par value',
          repar: 'Bank of England share value',
          close: 'Receivership',
          endgame: 'End game trigger',
        }.freeze

        GAME_END_REASONS_TEXT = {
          bank: 'The bank runs out of money',
          stock_market: 'Corporation hit max stock value or Bank of England has given 16 or more loans',
          custom: 'Fifth corporation is in receivership',
        }.freeze

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend paid', '1 →'],
            ['Loan taken - Corporation', '2 ←'],
            ['Additional loans taken during forced train buy', '3 ←'],
            ['Loan granted - BOE', '1 →'],
            ['One or more shares sold (Except BOE)', '1 ↓'],
            ['Corporation sold out at end of SR', '1 ↑'],
          ]
        end

        GAME_END_CHECK = { bank: :full_or, stock_market: :full_or, custom: :full_or }.freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '8',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 6,
            variants: [
              {
                name: '2+',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 120,
              },
            ],
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: '6',
            num: 5,
            variants: [
              {
                name: '3+',
                distance:
                [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                 { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 230,
              },
            ],
            events: [{ 'type' => 'take_out_loans' },
                     { 'type' => 'lay_second_tile' },
                     { 'type' => 'can_buy_trains' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            rusts_on: '8',
            num: 4,
            variants: [
              {
                name: '4+',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 340,
              },
            ],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 500,
            num: 3,
            variants: [
              {
                name: '5+',
                distance:
                [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                 { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 550,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            num: 2,
            variants: [
              {
                name: '6+',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 660,
              },
            ],
            events: [{ 'type' => 'com_operates' }],
          },

          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 20,
            variants: [
              {
                name: 'D',
                distance: 999,
                price: 1100,
                num: 20,
                discount: { '4' => 300, '4+' => 300 },
              },
            ],
          },
          {
            name: '2E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 200,
            num: 10,
            available_on: '5',
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
                  'take_out_loans' => ['Corporations can take out loans'],
                  'lay_second_tile' => ['Corporations can lay a second tile'],
                  'com_operates' =>
                  ['COM operates without Sydney-Adelaide connection'],
                  'can_buy_trains' => ['Corporations can buy trains from other corporations']
                ).freeze

        COMPANIES = [
          {
            sym: 'P1',
            name: "Melbourne & Hobson's Bay Railway Company",
            value: 30,
            min_price: 1,
            max_price: 40,
            revenue: 5,
            desc: 'No special abilities. Can be bought for £1-£40',
          },
          {
            sym: 'P2',
            name: 'Oodnadatta Railway',
            value: 70,
            min_price: 1,
            max_price: 80,
            revenue: 10,
            desc: 'Owning Public Company or its Director may build one (1) free tile on a desert hex (marked by'\
                  ' a cactus icon). This power does not go away after a 5/5+ train is purchased. Can be bought for £1-£80 ',
            abilities: [
                    {
                      type: 'tile_lay',
                      discount: 40,
                      hexes: %w[B3 B7 B9 C2 C4 C8 E6 E8],
                      tiles: %w[7 8 9],
                      count: 1,
                      reachable: true,
                      consume_tile_lay: true,
                      owner_type: 'corporation',
                      when: 'owning_corp_or_turn',
                    },
                    {
                      type: 'tile_lay',
                      discount: 40,
                      hexes: %w[B3 B7 B9 C2 C4 C8 E6 E8],
                      tiles: %w[7 8 9],
                      count: 1,
                      reachable: true,
                      consume_tile_lay: true,
                      owner_type: 'player',
                      when: 'owning_player_or_turn',
                    },
                  ],
          },
          {
            sym: 'P3',
            name: 'Tasmanian Railways',
            value: 110,
            min_price: 1,
            max_price: 140,
            revenue: 15,
            desc: 'The Tasmania tile can be placed by a Public Company on one of the two blue hexes (I8, I10). This is in'\
                  " addition to the company's normal build that turn. Can be bought for £1-£140",
            abilities: [
                    {
                      type: 'tile_lay',
                      hexes: %w[I8 I10],
                      tiles: %w[241],
                      owner_type: 'corporation',
                      when: 'owning_corp_or_turn',
                      special: true,
                      count: 1,
                      free: true,
                    },
                  ],

          },
          {
            sym: 'P4',
            name: 'The Ghan',
            value: 170,
            discount: 0,
            min_price: 1,
            max_price: 220,
            revenue: 20,
            desc: 'Owning Public Company or its Director may receive a one-time discount of £100 on the purchase'\
                  ' of a 2E (Ghan) train. This power does not go away after a 5/5+ train is purchased. Can be bought for £1-£220',
            abilities: [
                    {
                      type: 'train_discount',
                      discount: 100,
                      trains: ['2E'],
                      count: 1,
                      owner_type: 'corporation',
                      when: 'buying_train',
                    },
                    {
                      type: 'train_discount',
                      discount: 100,
                      trains: ['2E'],
                      count: 1,
                      owner_type: 'player',
                      when: 'buying_train',
                    },
                  ],

          },
          {
            sym: 'P5',
            name: 'Trans-Australian Railway',
            value: 170,
            revenue: 25,
            desc: 'The owner receives a 10% share in the QR. Cannot be bought by a corporation',
            abilities: [{ type: 'shares', shares: 'QR_1' },
                        { type: 'no_buy' }],
          },
          {
            sym: 'P6',
            name: 'North Australian Railway',
            value: 230,
            revenue: 30,
            desc: "The owner receives a Director's Share share in the CAR, which must start at a par value of £100."\
                  ' Cannot be bought by a corporation. Closes when CAR purchases its first train.',
            abilities: [{ type: 'shares', shares: 'CAR_0' },
                        { type: 'no_buy' },
                        { type: 'close', when: 'bought_train', corporation: 'CAR' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BOE',
            name: 'Bank of England',
            logo: '1848/BOE',
            simple_logo: '1848/BOE.alt',
            tokens: [],
            text_color: 'black',
            type: 'bank',
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'antiqueWhite',
          },
          {
            sym: 'CAR',
            name: 'Central Australian Railway',
            logo: '1848/CAR',
            simple_logo: '1848/CAR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'E4',
            color: 'black',
          },
          {
            sym: 'VR',
            name: 'Victorian Railways',
            logo: '1848/VR',
            simple_logo: '1848/VR.alt',
            tokens: [0, 40, 100],
            coordinates: 'H11',
            text_color: 'black',
            color: '#ffe600',
          },
          {
            sym: 'NSW',
            name: 'New South Wales Railways',
            logo: '1848/NSW',
            simple_logo: '1848/NSW.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F17',
            text_color: 'black',
            color: '#ff9027',
          },
          {
            sym: 'SAR',
            name: 'South Australian Railway',
            logo: '1848/SAR',
            simple_logo: '1848/SAR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G6',
            color: '#9e2a97',
          },
          {
            sym: 'COM',
            name: 'Commonwealth Railways',
            logo: '1848/COM',
            simple_logo: '1848/COM.alt',
            tokens: [0, 0, 100, 100, 100],
            text_color: 'black',
            color: '#cfc5a2',
          },
          {
            sym: 'FT',
            name: 'Federal Territory Railway',
            logo: '1848/FT',
            simple_logo: '1848/FT.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G14',
            text_color: 'black',
            color: '#55c3ec',
          },
          {
            sym: 'WA',
            name: 'West Australian Railway',
            logo: '1848/WA',
            simple_logo: '1848/WA.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'D1',
            color: '#ee332a',
          },
          {
            sym: 'QR',
            name: "Queensland Gov't Railway",
            logo: '1848/QR',
            simple_logo: '1848/QR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'B19',
            color: '#399c42',
          },
        ].freeze

        TILE_LAYS = [{ lay: true, upgrade: true }].freeze
        EXTRA_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        def tile_lays(_entity)
          @extra_tile_lay ? EXTRA_TILE_LAYS : TILE_LAYS
        end

        def event_lay_second_tile!
          @log << 'Corporations can now perform a second tile lay'
          @extra_tile_lay = true
        end

        def event_take_out_loans!
          @log << 'Corporations can now take out loans'
          @take_out_loan_triggered = true
        end

        def event_com_operates!
          @log << 'COM operates even without Sydney-Adelaide connection'
          @com_can_operate = true
        end

        def event_can_buy_trains!
          @log << 'Corporations can buy trains from other corporations'
          @can_buy_trains = true
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          @private_closed_triggered = true
          @companies.each do |company|
            unused_ability = company.all_abilities.any? { |ability| ability.type != :no_buy && !ability.used? }
            if unused_ability
              # reduce revenue to 0, keep company around, can't be bought if owned by player
              company.revenue = 0
              no_buy = Engine::Ability::NoBuy.new(type: 'no_buy')
              company.add_ability(no_buy)
            else
              # close company
              @log << "#{company.name} closes"
              company.close!
            end
          end
        end

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :operate

        def setup
          @sydney_adelaide_connected = false

          @boe = @corporations.find { |c| c.type == :bank }
          @boe.ipoed = true
          @boe.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool
            )
          end
          @boe.owner = @share_pool
          @boe.cash = BOE_STARTING_CASH
          @stock_market.set_par(@boe, lookup_boe_price(BOE_STARTING_PRICE))
          @extra_tile_lay = false
          @close_corp_count = 0
          @player_corp_close_count = Hash.new { |h, k| h[k] = 0 }
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1848::Step::DutchAuction,
          ])
        end

        def stock_round
          G1848::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1848::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1848::Round::Operating.new(self, [
            G1848::Step::CheckCOMFormation,
            G1848::Step::TakeLoanBuyCompany,
            G1848::Step::CashCrisis,
            G1848::Step::TasmaniaTile,
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1848::Step::SpecialTrack,
            G1848::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1848::Step::BlockingLoan,
            G1848::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1848::Step::SpecialBuyTrain,
            G1848::Step::BuyTrain,
            [G1848::Step::TakeLoanBuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          G1848::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def operating_order
          @corporations.select(&:floated?).sort.partition { |c| c.type == :bank }.flatten
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return ['241'].include?(to.name) if selected_company&.sym == 'P3'

          super
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          # tile 241, tasmania  is valid in all phases
          return true if tile.name == '241'

          super
        end

        def dummy_corp
          # dummy corp is used for graph to find adelaide (to connect to sydney for starting COM)
          @dummy_corp ||= Engine::Corporation.new(name: 'Dummy Corp', sym: 'Dummy Corp', tokens: [], coordinates: 'G6')
        end

        def tasmania
          @tasmania ||= company_by_id('P3')
        end

        def ghan
          @ghan ||= company_by_id('P4')
        end

        def sydney
          @sydney ||= hex_by_id('F17')
        end

        def adelaide
          @adelaide ||= hex_by_id('G6')
        end

        def check_for_sydney_adelaide_connection
          graph = Graph.new(self, home_as_token: true, no_blocking: true)
          graph.compute(dummy_corp)
          graph.reachable_hexes(dummy_corp).include?(sydney)
        end

        def event_com_connected!
          @sydney_adelaide_connected = true
        end

        def place_home_token(entity)
          return super unless entity.name == 'COM'
          return unless can_com_operate?
          return if entity.tokens.first&.used

          # COM places home tokens... regardless as to whether there is space for them
          [sydney, adelaide].each do |home_hex|
            city = home_hex.tile.cities[0]
            slot = city.available_slots.positive? ? 0 : city.slots
            home_token = entity.tokens.find { |token| !token.used && token.price.zero? }
            city.place_token(entity, home_token, free: true, check_tokenable: false, cheater: slot)
          end
        end

        def can_com_operate?
          @sydney_adelaide_connected || @com_can_operate
        end

        def crowded_corps
          # 2E does not create a crowded corp
          @crowded_corps ||= corporations.select do |c|
            c.trains.count { |t| t.name != '2E' } > train_limit(c)
          end
        end

        def must_buy_train?(entity)
          # 2E does not count as compulsory train purchase
          entity.trains.reject { |t| t.name == '2E' }.empty? &&
            !depot.depot_trains.empty? && @graph.route_info(entity)&.dig(:route_train_purchase)
        end

        # for 3 players corp share limit is 70%
        def corporation_opts
          @players.size == 3 ? { max_ownership_percent: 70 } : {}
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          super(bundle, allow_president_change: pres_change_ok?(bundle.corporation), swap: nil)
        end

        def pres_change_ok?(corporation)
          corporation != @boe
        end

        def after_buy_company(player, company, _price)
          # share_price = 100
          # # NOTE: This should only ever be P6
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.president
                stock_market.set_par(share.corporation, stock_market.par_prices.find { |p| p.price == 100 })
                share_pool.buy_shares(player, share, exchange: :free)
                after_par(share.corporation)
              else
                share_pool.buy_shares(player, share, exchange: :free)
              end
              ability.use!
            end
          end
        end

        def lookup_boe_price(p)
          @stock_market.market[BOE_ROW].each do |sp|
            return sp if sp.price == p
          end
        end

        # loans

        def maximum_loans(entity)
          entity == @boe ? 20 : 5
        end

        def init_loans
          @loan_value = 100
          Array.new(20) { |id| Loan.new(id, @loan_value) }
        end

        def can_pay_interest?(_entity, _extra_cash = 0)
          false
        end

        def interest_owed(_entity)
          0
        end

        def market_share_limit(corporation = nil)
          return 100 if corporation == @boe

          MARKET_SHARE_LIMIT
        end

        def can_take_loan?(entity, ebuy: nil)
          return true if ebuy

          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            !@loans.empty? &&
            @take_out_loan_triggered
        end

        def take_loan(entity, loan, ebuy: nil)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity, ebuy: ebuy)

          old_price = entity.share_price
          boe_old_price = @boe.share_price
          @boe.spend(loan.amount, entity)
          loan_taken_stock_market_movement(entity, loan, ebuy: ebuy)
          log_share_price(entity, old_price)
          log_share_price(@boe, boe_old_price)
          entity.loans << loan
          @boe.loans << loan
          @loans.delete(loan)
        end

        def loan_taken_stock_market_movement(entity, loan, ebuy: nil)
          @log << "#{entity.name} takes a loan and receives #{format_currency(loan.amount)}"
          2.times { @stock_market.move_left(entity) }
          @stock_market.move_left(entity) if ebuy
          @stock_market.move_right(boe)
        end

        def perform_ebuy_loans(entity, remaining)
          ebuy = true
          while remaining.positive? && entity.share_price.price != 0
            # if at max loans, company goes directly into receiverhsip
            if @loans.empty?
              @log << "There are no more loans available to force buy a train, #{entity.name} goes into receivership"
              r, _c = entity.share_price.coordinates
              @stock_market.move(entity, r, 0)
              break
            end
            loan = @loans.first
            take_loan(entity, loan, ebuy: ebuy)
            remaining -= loan.amount
          end
        end

        # routing logic
        def visited_stops(route)
          modified_gauge_changes = get_modified_gauge_distance(route)
          added_stops = modified_gauge_changes.positive? ? Array.new(modified_gauge_changes) { Engine::Part::City.new('0') } : []
          route_stops = super
          route_stops_2e = route_stops.select { |stop| stop.tokened_by?(route.train.owner) || ghan_visited?(stop) }
          route.train.name == '2E' ? route_stops_2e : route_stops + added_stops
        end

        def check_distance(route, visits, _train = nil)
          return super if route.train.name != '2E' || ghan_visited?(visits.first) || ghan_visited?(visits.last)

          raise GameError, 'Route must include Alice Springs'
        end

        def get_modified_gauge_distance(route)
          gauge_changes = edge_crossings(route)
          modifier = route.train.name.include?('+') ? 1 : 0
          gauge_changes - modifier
        end

        def edge_crossings(route)
          sum = route.paths.sum do |path|
            path.edges.sum do |edge|
              edge_is_a_border(edge) ? 1 : 0
            end
          end
          # edges are double counted
          sum / 2
        end

        def edge_is_a_border(edge)
          edge.hex.tile.borders.any? { |border| border.edge == edge.num }
        end

        def revenue_for(route, stops)
          super + K_BONUS[k_sum(route, stops)]
        end

        def k_sum(route, stops)
          return 0 if route.train.name == '2E' || !stops

          stops.count { |rl| rl.hex&.tile&.label&.to_s == 'K' || rl.hex&.tile&.future_label&.label.to_s == 'K' }
        end

        def revenue_str(route)
          return super unless k_sum(route, route.stops) > 1

          k_sum_string = ' + k'
          (k_sum(route, route.stops) - 1).times { k_sum_string += '-k' }
          super + k_sum_string
        end

        def compute_stops(route, train = nil)
          train ||= route.train
          visits = route.visited_stops
          distance = train.distance
          return visits if distance.is_a?(Numeric)
          return [] if visits.empty?

          # distance is an array of hashes defining how many locations of
          # each type can be hit. A 2+2 train (4 locations, at most 2 of
          # which can be cities) looks like this:
          #   [ { nodes: [ 'town' ],                     pay: 2},
          #     { nodes: [ 'city', 'town', 'offboard' ], pay: 2} ]
          # Stops use the first available slot, so for each stop in this case
          # we'll try to put it in a town slot if possible and then
          # in a city/town/offboard slot.
          distance = distance.sort_by { |types, _| types.size }

          max_num_stops = [distance.sum { |h| h['pay'] }, visits.size].min

          max_num_stops.downto(1) do |num_stops|
            # to_i to work around Opal bug
            stops, revenue = visits.combination(num_stops.to_i).map do |stops|
              # Make sure this set of stops is legal
              # 1) At least one stop must have a token (if enabled)
              next if train.requires_token && stops.none? { |stop| stop.tokened_by?(route.corporation) }

              # 2) if 2E one stop must be alice springs
              next if train.name == '2E' && stops.none? { |stop| ghan_visited?(stop) }

              # 3) We can't ask for more revenue centers of a type than are allowed
              types_used = Array.new(distance.size, 0) # how many slots of each row are filled

              next unless stops.all? do |stop|
                row = distance.index.with_index do |h, i|
                  h['nodes'].include?(stop.type) && types_used[i] < h['pay']
                end

                types_used[row] += 1 if row
                row
              end

              [stops, revenue_for(route, stops)]
            end.compact.max_by(&:last)

            revenue ||= 0

            # We assume that no stop collection with m < n stops could be
            # better than a stop collection with n stops, so if we found
            # anything usable with this number of stops we return it
            # immediately.
            return stops if revenue.positive?
          end

          []
        end

        # recievership

        def close_corporation(corporation, quiet: false)
          @close_corp_count += 1
          @player_corp_close_count[corporation.owner] += 1

          # boe gets all the tokens
          corporation.tokens.each do |token|
            next unless token.used

            boe_token = Engine::Token.new(@boe)
            token.swap!(boe_token, check_tokenable: false)
            @boe.tokens << boe_token
          end

          # shareholders compensated
          per_share = corporation.par_price.price
          payouts = {}
          @players.each do |player|
            next if corporation.president?(player)

            amount = player.num_shares_of(corporation) * per_share
            next if amount.zero?

            payouts[player] = amount
            corporation.spend(amount, player, check_cash: false, borrow_from: corporation.owner)
          end

          unless payouts.empty?
            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')

            @log << "#{corporation.name} settles with shareholders "\
                    "#{format_currency(per_share)} per share (#{receivers})"
          end

          # cert limit adjustments
          players_size = @players.size
          @cert_limit = CERT_LIMIT_RECEIVERSHIP[players_size][@close_corp_count]

          # remove trains on 2nd and 5th company
          depot.export! if @close_corp_count == 2 || @close_corp_count == 5

          super
        end

        def custom_end_game_reached?
          @close_corp_count >= 5
        end

        def init_cert_limit
          return super unless @cert_limit.is_a?(Numeric)

          @cert_limit
        end

        def cert_limit(player = nil)
          if @cert_limit.is_a?(Numeric) && player
            # player cert limit needs to be reduced
            @cert_limit - (@player_corp_close_count[player] * CERT_LIMIT_RECEIVERSHIP_REDUCTION[@players.size])
          else
            @cert_limit
          end
        end

        def init_train_handler
          trains = game_trains.flat_map do |train|
            Array.new((train[:num] || num_trains(train))) do |index|
              Train.new(**train, index: index)
            end
          end

          G1848::Depot.new(trains, self)
        end

        def ghan_visited?(visited_node)
          return false unless visited_node

          GHAN_HEXES.include?(visited_node&.hex&.name)
        end

        def entity_can_use_company?(entity, company)
          # company abilities only work once they can be bought
          return false unless can_use_company_ability?

          super
        end

        def can_use_company_ability?
          @phase.status.include?('can_buy_companies') || private_closed_triggered
        end

        def corporation_show_interest?
          false
        end

        def ability_used!(company)
          company.all_abilities.dup.each { |ab| company.remove_ability(ab) }
        end

        def first_column?(entity)
          return unless entity.corporation?

          _r, c = entity.share_price.coordinates
          c == 1
        end

        def next_round!
          reset_company_values if @round.is_a?(Engine::Round::Auction)
          super
        end

        def reset_company_values
          companies.each do |comp|
            comp.value = 0
            comp.discount = 0
          end
        end
      end
    end
  end
end
