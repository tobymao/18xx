# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'round/operating'

module Engine
  module Game
    module G1817WO
      class Game < G1817::Game
        include_meta(G1817WO::Meta)

        attr_reader :new_zealand_city

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 16, 3 => 13, 4 => 11, 5 => 9 }.freeze

        STARTING_CASH = { 2 => 330, 3 => 240, 4 => 195, 5 => 168 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '54' => 'unlimited',
          '57' => 'unlimited',
          '62' => 'unlimited',
          '63' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '592' => 'unlimited',
          '593' => 'unlimited',
          '597' => 'unlimited',
          '611' => 'unlimited',
          '619' => 'unlimited',
          'X00' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'X30' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
          },
        }.freeze

        LOCATION_NAMES = {
          'C2' => 'Prince of Wales Fort',
          'D7' => 'Amazonia',
          'G4' => 'Mare Nostrum',
          'G8' => 'Beginnings',
          'I2' => 'Brrrrrrrrrr!',
          'I6' => 'New Pittsburgh',
          'K4' => 'Dynasties',
          'K8' => 'Terra Australis',
          'A2' => 'Gold Rush',
          'A6' => "Kingdom of Hawai'i",
          'D9' => 'Antarctica',
          'F1' => 'Vikings',
          'H9' => 'Libertalia',
          'J9' => 'You are lost',
          'L1' => 'Gold Rush',
          'L9' => 'Nieuw Zeeland',
          'C4' => 'NYC',
        }.freeze

        MARKET = [
          %w[0l
             0a
             0a
             0a
             40
             45
             50p
             55s
             60p
             65p
             70s
             80p
             90p
             100p
             110p
             120s
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['no_new_shorts'],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 48 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 2 },
                  {
                    name: '3',
                    distance: 3,
                    price: 250,
                    rusts_on: '6',
                    num: 7,
                    events: [{ 'type' => 'nieuw_zeeland_available' }],
                  },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 5 },
                  { name: '5', distance: 5, price: 600, num: 3 },
                  { name: '6', distance: 6, price: 750, num: 2 },
                  { name: '7', distance: 7, price: 900, num: 2 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 32,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        COMPANIES = [
          {
            name: 'Pittsburgh Steel Mill',
            value: 40,
            revenue: 0,
            desc: "Owning corp may place special 'New Pittsburgh' yellow tile "\
                  'during tile-laying, regardless of connectivity.  The hex is not reserved, and the '\
                  'power is lost if another company builds there first.',
            sym: 'PSM',
            abilities: [
            {
              type: 'tile_lay',
              hexes: ['I6'],
              tiles: ['X00'],
              when: 'track',
              owner_type: 'corporation',
              count: 1,
              closed_when_used_up: true,
              consume_tile_lay: true,
              special: true,
            },
          ],
            color: nil,
          },
          {
            name: 'Mountain (Ocean) Engineers',
            value: 40,
            revenue: 0,
            desc: 'Owning company receives $20 after laying a yellow tile in a '\
                  'mountain (ocean) hex.  Any fees must be paid first.',
            sym: 'ME',
            abilities: [
              {
                type: 'tile_income',
                income: 20,
                terrain: 'lake',
                owner_type: 'corporation',
                owner_only: true,
              },
            ],
            color: nil,
          },
          {
            name: 'Ohio Bridge Company',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning corp '\
                  'in Mare Nostrum or Dynasties max one token per city, regardless '\
                  'of connectivity.  Allows owning corp to skip $10 river fee '\
                  'when placing yellow tiles.',
            sym: 'OBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: %w[G4 K4],
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Train Station',
            value: 80,
            revenue: 0,
            desc: 'Provides an additional station marker for the owning corp, awarded at time of purchase',
            sym: 'TS',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Minor Coal Mine',
            value: 30,
            revenue: 0,
            desc: 'Comes with one coal mine marker.  When placing a yellow tile '\
                  'in a ocean hex next to a revenue location, can place token to '\
                  'avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  '\
                  'Hexes pay $10 extra revenue and do not count as a stop.  May '\
                  'not start or end a route at a coal mine. C8 may not have a coal mine.',
            sym: 'MINC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B7 E4 E2 F9 I8 K6 L5],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Coal Mine',
            value: 60,
            revenue: 0,
            desc: 'Comes with two coal mine markers.  When placing a yellow tile '\
                  'in a mountain hex next to a revenue location, can place token '\
                  'to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  '\
                  'Hexes pay $10 extra revenue and do not count as a stop.  May '\
                  'not start or end a route at a coal mine. C8 may not have a coal mine.',
            sym: 'CM',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B7 E4 E2 F9 I8 K6 L5],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
            color: nil,
          },
          {
            name: 'Major Mail Contract',
            value: 120,
            revenue: 0,
            desc: 'Pays owning corp $20 at the start of each operating round, '\
                  'as long as the company has at least one train.',
            sym: 'MAJM',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 20,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'A&S',
            name: 'Alton & Southern Railway',
            logo: '1817/AS',
            simple_logo: '1817/AS.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ee3e80',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'Belt',
            name: 'Belt Railway of Chicago',
            logo: '1817/Belt',
            simple_logo: '1817/Belt.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#f2a847',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'Bess',
            name: 'Bessemer and Lake Erie Railroad',
            logo: '1817/Bess',
            simple_logo: '1817/Bess.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#16190e',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'B&A',
            name: 'Boston and Albany Railroad',
            logo: '1817/BA',
            simple_logo: '1817/BA.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ef4223',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'DL&W',
            name: 'Delaware, Lackawanna and Western Railroad',
            logo: '1817/DLW',
            simple_logo: '1817/DLW.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#984573',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'GT',
            name: 'Grand Trunk Western Railroad',
            logo: '1817/GT',
            simple_logo: '1817/GT.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#e48329',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'H',
            name: 'Housatonic Railroad',
            logo: '1817/H',
            simple_logo: '1817/H.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#bedef3',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'ME',
            name: 'Morristown and Erie Railway',
            logo: '1817/ME',
            simple_logo: '1817/ME.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ffdea8',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PSNR',
            name: 'Pittsburgh, Shawmut and Northern Railroad',
            logo: '1817/PSNR',
            simple_logo: '1817/PSNR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#0a884b',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'R',
            name: 'Rutland Railroad',
            logo: '1817/R',
            simple_logo: '1817/R.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#165633',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'UR',
            name: 'Union Railroad',
            logo: '1817/UR',
            simple_logo: '1817/UR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#003d84',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'WC',
            name: 'West Chester Railroad',
            logo: '1817/WC',
            simple_logo: '1817/WC.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#984d2d',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B3
               B5
               C6
               D3
               D5
               E6
               E8
               F3
               F5
               G2
               G6
               H1
               H5
               H7
               J5
               J7
               L3
               L7] => '',
            %w[B7 C8 E2 E4 F9 I8 K6 L5] =>
                   'upgrade=cost:15,terrain:lake',
            %w[H3 I4 J3] => 'upgrade=cost:10,terrain:water',
            %w[B1 F7 K2] => 'upgrade=cost:20',
            ['C2'] => 'city=revenue:0;upgrade=cost:15,terrain:lake',
            %w[G8 I2 I6 K8] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;upgrade=cost:20',
            %w[G4 K4] => 'city=revenue:0;upgrade=cost:10,terrain:water',
          },
          gray: {
            ['J1'] => 'path=a:0,b:1;path=a:1,b:5;path=a:0,b:5',
            ['A6'] =>
            'city=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:_0,b:5',
            ['F1'] =>
            'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:1,b:_0;path=a:5,b:_0',
            ['H9'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:_0,b:4',
            ['L9'] => 'city=revenue:0',
          },
          yellow: {
            ['C4'] =>
                        'city=revenue:40;city=revenue:40;path=a:2,b:_0;path=a:5,b:_1;label=NY;upgrade=cost:20',
          },
          red: {
            ['A2'] =>
                     'offboard=revenue:yellow_30|green_50|brown_20|gray_60;path=a:4,b:_0',
            ['D9'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:4,b:_0',
            ['J9'] =>
            'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:3,b:_0;path=a:4,b:_0',
            ['L1'] =>
            'offboard=revenue:yellow_30|green_50|brown_20|gray_60;path=a:1,b:_0',
          },
        }.freeze

        LAYOUT = :flat

        SEED_MONEY = 100
        EVENTS_TEXT = G1817::Game::EVENTS_TEXT.merge('nieuw_zeeland_available' => ['Nieuw Zealand opens for new IPOs'])
        MAX_LOAN = 65
        LOANS_PER_INCREMENT = 3

        def setup_preround
          super
          @pittsburgh_private = @companies.find { |c| c.id == 'PSM' }
        end

        def setup
          super
          @new_zealand_city = hexes.find { |hex| hex.location_name == 'Nieuw Zeeland' }.tile.cities[0]
          # Put an 1867 style green token in the New Zealand hex
          @green_token = Token.new(nil, price: 0, logo: '/logos/1817/nz.svg', type: :neutral)
          @new_zealand_city.exchange_token(@green_token)
        end

        def event_nieuw_zeeland_available!
          # Remove the 1867-style green token from the New Zealand hex
          @log << 'Corporations can now be IPOed in Nieuw Zeeland'
          @green_token.remove!
        end

        def interest_owed(entity)
          return super unless corp_has_new_zealand?(entity)
          # A corporation with a token in new zealand gets $20 if it doesn't have any loans
          return -20 unless entity.loans.size.positive?

          # Otherwise it gets interest for one loan paid for free
          interest_owed_for_loans(entity.loans.size - 1)
        end

        def corp_has_new_zealand?(corporation)
          corporation.tokens.any? { |token| token.city == @new_zealand_city }
        end

        def tokenable_location_exists?
          # Using hexes > tile > cities because simply using cities also gets cities
          # that are on tiles not yet laid.
          hexes.any? { |h| h.tile.cities.any? { |c| c.tokens.count(&:nil?).positive? } }
        end

        def can_place_second_token(corporation)
          return false if !tokenable_location_exists? || !corp_has_new_zealand?(corporation)

          # Does the corp have a second token already?
          corporation.tokens[1] && !corporation.tokens[1].city
        end

        # This must be idempotent.
        def place_second_token(corporation)
          return unless can_place_second_token(corporation)

          hex = hex_by_id(corporation.coordinates)

          tile = hex&.tile
          if !tile || (tile.reserved_by?(corporation) && tile.paths.any?)

            # If the tile does not have any paths at the present time, clear up the ambiguity when the tile is laid
            # otherwise the entity must choose now.
            @log << "#{corporation.name} must choose city for home token"

            hexes =
              if hex
                [hex]
              else
                home_token_locations(corporation)
              end

            @round.pending_tokens << {
              entity: corporation,
              hexes: hexes,
              token: corporation.find_token_by_type,
            }

            @round.clear_cache!
            return
          end

          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          token = corporation.find_token_by_type
          return unless city.tokenable?(corporation, tokens: token)

          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token)
        end

        def home_token_locations(corporation)
          # Cannot place a home token in Nieuw Zeeland until phase 3
          return super unless %w[2 2+].include?(@phase.name)

          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city != new_zealand_city }
          end
        end

        # Override InterestOnLoans.pay_interest! so that we can pay "negative" interest for New Zealand
        def pay_interest!(entity)
          owed = interest_owed(entity)
          # This is here so that the log message does not get duplicated.
          if corp_has_new_zealand?(entity) && entity.loans.size.positive?
            @log << "#{entity.name}'s token in Nieuw Zeeland covers one loan's worth of interest"
          end
          return super unless owed.negative?

          # Negative interest -> corporation has New Zealand
          @log << "#{entity.name} gets $20 for having a token in Nieuw Zeeland and no loans"
          entity.spend(owed, bank, check_cash: false, check_positive: false)
          nil
        end

        def operating_round(round_num)
          @interest_fixed = nil
          @interest_fixed = interest_rate
          # Revaluate if private companies are owned by corps with trains
          @companies.each do |company|
            next unless company.owner

            abilities(company, :revenue_change, time: 'has_train') do |ability|
              company.revenue = company.owner.trains.any? ? ability.revenue : 0
            end
          end

          G1817WO::Round::Operating.new(self, [
            G1817::Step::Bankrupt,
            G1817::Step::CashCrisis,
            G1817::Step::Loan,
            G1817::Step::SpecialTrack,
            G1817::Step::Assign,
            G1817::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1817::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1817::Step::BuyTrain,
          ], round_num: round_num)
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1817WO::Step::HomeToken,
            G1817WO::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
