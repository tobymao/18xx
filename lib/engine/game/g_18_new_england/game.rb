# frozen_string_literal: true

require_relative 'meta'
#require_relative 'stock_market'
require_relative '../base'

module Engine
  module Game
    module G18NewEngland
      class Game < Game::Base
        include_meta(G18NewEngland::Meta)

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

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13}.freeze

        STARTING_CASH = { 3 => 400, 4 => 280, 5 => 280}.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          "3": 5,
          "4": 5,
          "6": 8,
          "7": 5,
          "8": 18,
          "9": 15,
          "58": 5,
          "14": 4,
          "15": 4,
          "16": 2,
          "19": 2,
          "20": 2,
          "23": 5,
          "24": 5,
          "25": 4,
          "26": 2,
          "27": 2,
          "28": 2,
          "29": 2,
          "30": 2,
          "31": 2,
          "87": 4,
          "88": 4,
          "204": 4,
          "207": 1,
          "619": 4,
          "622": 1,
          "39": 2,
          "40": 2,
          "41": 2,
          "42": 2,
          "43": 2,
          "44": 2,
          "45": 2,
          "46": 2,
          "47": 2,
          "63": 7,
          "70": 2,
          "611": 3,
          "216": 2,
          "911": 4
        }.freeze

        LOCATION_NAMES = {
          "B12": "Campbell Hall",
          "B2": "Syracuse",
          "C3": "Albany",
          "C5": "Hudson",
          "C9": "Rhinecliff",
          "C11": "Poughkeepsie",
          "C17": "White Plains",
          "C19": "New York",
          "D4": "New Lebanon",
          "E13": "Danbury",
          "E15": "Stamford",
          "F2": "Burlington",
          "F4": "Pittsfield",
          "F14": "Bridgeport",
          "G11": "Middletown",
          "G13": "New Haven",
          "H4": "Greenfield",
          "H6": "Northampton",
          "H8": "Springfield",
          "H10": "Hartford",
          "H14": "Saybrook",
          "I13": "New London",
          "J6": "Worcester",
          "J14": "Westerly",
          "K1": "New Hampshire",
          "K3": "Fitchburg",
          "K5": "Leominster",
          "L4": "Lowell and Wilmington",
          "L8": "Woonsocket",
          "L10": "Providence",
          "M1": "Portland",
          "M5": "Boston",
          "M7": "Quincy",
          "O11": "Cape Cod"
        }.freeze

        MARKET = [
          %w[35,
             40,
             45,
             50,
             55,
             60,
             65,
             70,
             80,
             90,
             100p,
             110p,
             120p,
             130p,
             145p,
             160p,
             180p,
             200p,
             220,
             240,
             260,
             280,
             310,
             340,
             380,
             420,
             460,
             500],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: '4',
            tiles: %i[ yellow ],
            operating_rounds: 2
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[ yellow green ],
            operating_rounds: 2
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[ yellow green ],
            operating_rounds: 2
          },
          {
            name: '5',
            on: '5E',
            train_limit: 3,
            tiles: %i[ yellow green brown ],
            operating_rounds: 2
          },
          {
            name: '6',
            on: '6E',
            train_limit: 2,
            tiles: %i[ yellow green brown ],
            operating_rounds: 2
          },
          {
            name: '8',
            on: '8E',
            train_limit: 2,
            tiles: %i[ yellow green brown gray ],
            operating_rounds: 2
          },
          #    status: ['can_buy_companies'],
          #    status: %w[can_buy_companies export_train],
          #    status: %w[can_buy_companies export_train],
        ].freeze

        TRAINS = [
          {
            name: "2",
            distance: 2,
            price: 100,
            rusts_on: 4,
            num: 10,
          },
          {
            name: "3",
            distance: 3,
            price: 180,
            rusts_on: "6E",
            num: 7,
          },
          {
            name: "4",
            distance: 4,
            price: 300,
            rusts_on: "8E",
            num: 4,
          },
          {
            name: "5E",
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: "6E",
            distance: 6,
            price: 600,
            num: 3
          },
          {
            name: "8E",
            distance: 8,
            price: 800,
            num: 20
          }
        ].freeze

        COMPANIES = [
          {
            "name": "Delaware and Raritan Canal",
            "value": 20,
            "revenue": 5,
            "desc": "No special ability. Blocks hex K3 while owned by a player.",
            "sym": "D&R",
            "abilities": [
              {
                "type": "blocks_hexes",
                "owner_type": "player",
                "hexes": [
                  ""
                ]
              }
            ]
          },
          {
            "float_percent": 60,
            "sym": "B&A",
            "name": "Boston and Albany Railroad",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "red"
          },
          {
            "float_percent": 60,
            "sym": "B&M",
            "name": "Boston and Maine Railroad",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "green"
          },
          {
            "float_percent": 60,
            "sym": "CN",
            "name": "Canadian National Railway",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "yellow",
            "text_color": "black"
          },
          {
            "float_percent": 60,
            "sym": "CVT",
            "name": "Central Vermont Railway",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "purple"
          },
          {
            "float_percent": 60,
            "sym": "D&H",
            "name": "Delaware and Hudson Railway",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "darkBlue"
          },
          {
            "float_percent": 60,
            "sym": "NYC",
            "name": "New York Central Railroad",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "black"
          },
          {
            "float_percent": 60,
            "sym": "NYNHH",
            "name": "New York, New Haven and Hartford Railroad",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "orange"
          },
          {
            "float_percent": 60,
            "sym": "P&W",
            "name": "Providence and Worcester Railroad",
            "logo": "18_chesapeake/PRR",
            "tokens": [
              0,
              40,
              80
            ],
            "coordinates": "",
            "color": "brown"
          }
        ].freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[ B16 B6 C13 D10 D12 D14 D16 D2 D6 D8 E3 G3 G7 G9 I11
                I3 I9 J10 J12 J4 J8 K11 K13 K7 L2 M11 M9 N10 N8 O9 L6] => '',
            %w[ E11 E5 E7 E9 F10 F12 F6 F8 G5 I5 I7 ] => 'upgrade=cost:40,terrain:mountainr',
            %w[ B10 B14 B18 B8 C15 C7 H12 H2 K9 M3 ] => 'upgrade=cost:20,terrain:water',
            %w[ C17 C9 D4 F14 G11 H14 H6 J14 K5 L8 ] => 'town:revenue:0',
            %w[ C5 E15 F12 F4 I13 ] => 'city:revenue:0',
            %w[ B12 E13 H4 ] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[ M7 ] => 'town=revenue:20;city=revenue:20',
            %w[ N4] => 'town=revenue:0;upgrade=cost:20,terrain:water',
          },
          yellow: {
            %w[L10] => 'city=revenue:30;path=a:_0,b:2;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y',
            %w[ C3 ] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=Y',
            %w[ C11 ] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:3',
            %w[ G13 ] => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:_0,b:1;path=a:_1,b:3;path=a:_2,b:5;label=NH',
            %w[ H10 ] => 'city=revenue:30;path=a:_0,b:1;path=a:_0,b:2;label=H', 
            %w[ H8 ] => 'city=revenue:20;city=revenue:20;path=a:_0,b:1;path=a:_1,b:3',
            %w[ J6 ] => 'city=revenue:20;path=a:_0,b:4;path=a:_0,b:5',
            %w[ K3 ] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;upgrade=cost:20,terrain:water',
            %w[ L4 ] => 'city=revenue:20;town=revenue=10',
            %w[ M5 ] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=B',
          },
          gray: {
            %w[ A13 ] => 'path=a:4,b:5',
            %w[ B4 ] => 'path=a:4,b:5',
            %w[ A13 ] => 'path=a:4,b:5',
            %w[ E17 ] => 'path=a:2,b:3',
            %w[ G15 ] => 'path=a:2,b:3;path=a:3,b:4',
            %w[ O11] => 'town=revenue:40;path=a:2,b:_0;path=a:_0,b:3',
          },
          red: {
            %w[ B2 ] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:5,b:_0',
            %w[ C19 ] => 'city=revenue:yellow_40|green_50|brown_70|gray_100;path=a:2,b:_0;path=a:3,b:_0',
            %w[ F2 ] => 'city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            %w[ K1 ] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:5,b:_0',
            %w[ M1 ] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat

        HOME_TOKEN_TIMING = :float
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always # mostly true, needs custom code
        POOL_SHARE_DROP = :none
        SELL_MOVEMENT = :down_block_pres
        ALL_COMPANIES_ASSIGNABLE = true
        SELL_AFTER = :operate
        SELL_BUY_ORDER = :sell_buy
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        GAME_END_CHECK = { bank: :current_or, custom: :one_more_full_or_set }.freeze

        HEX_WITH_O_LABEL = %w[J12].freeze
        HEX_UPGRADES_FOR_O = %w[201 202 203 207 208 621 622 623 801 X8].freeze
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
                                              'majors_can_ipo' => ['Majors can be ipoed'],
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

        include InterestOnLoans
        include CompanyPriceUpToFace
        include StubsAreRestricted

        # Minors are done as corporations with a size of 2

        attr_reader :loan_value, :trainless_major

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def init_stock_market
          G1867::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
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

        def home_token_locations(corporation)
          # Can only place home token in cities that have no other tokens.
          open_locations = hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city.tokens.none? }
          end

          return open_locations if corporation.type == :minor

          # @todo: this may need optimizing when changing connections for loading.
          unconnected = open_locations.select { |hex| hex.connections.none? }
          if unconnected.none?
            open_locations
          else
            unconnected
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

        def buying_power(entity, full: false)
          return entity.cash unless full
          return entity.cash unless entity.corporation?

          # Loans are actually generate $5 less than when taken out.
          entity.cash
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def unstarted_corporation_summary
          unipoed = @corporations.reject(&:ipoed)
          minor = unipoed.select { |c| c.type == :minor }
          major = unipoed.select { |c| c.type == :major }
          ["#{minor.size} minor, #{major.size} major", [@national]]
        end

        def show_value_of_companies?(_owner)
          true
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

        def upgrades_to?(from, to, special = false)
          # O labelled tile upgrades to Ys until Grey
          return super unless self.class::HEX_WITH_O_LABEL.include?(from.hex.name)

          return false unless self.class::HEX_UPGRADES_FOR_O.include?(to.name)

          super(from, to, true)
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
            [Engine::Step::BuyCompany, blocks: true],
            G1867::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1867::Step::BuyTrain,
            [Engine::Step::BuyCompany, blocks: true],
          ], round_num: round_num)
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

        def round_end
          return Engine::Round::Operating if phase.name.to_i >= 8

          G1867::Round::Merger
        end

        def custom_end_game_reached?
          @final_operating_rounds
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        def setup

          # Hide the special 3 company
          @hidden_company = company_by_id('3')

          # Move green and majors out of the normal list
          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end
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
          @log << 'Majors can now be started via IPO'
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

        def event_signal_end_game!
          # There's always 3 ORs after the 8 train is bought
          @final_operating_rounds = 3
          # Hit the game end check now to set the correct turn
          game_end_check
          @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
        end

      end
    end
  end
end
