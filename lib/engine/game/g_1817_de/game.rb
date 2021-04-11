# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require_relative '../g_1817/game'
require_relative 'meta'

module Engine
  module Game
    module G1817DE
      class Game < G1817::Game
        include_meta(G1817DE::Meta)

        CURRENCY_FORMAT_STR = '%d ℳ'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 21, 3 => 16, 4 => 13, 5 => 11, 6 => 9 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 315, 4 => 252, 5 => 210, 6 => 180 }.freeze

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
          '57' => 'unlimited',
          '63' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '581' => 'unlimited',
          '584' => 'unlimited',
          '592' => 'unlimited',
          '593' => 'unlimited',
          '597' => 'unlimited',
          '611' => 'unlimited',
          '619' => 'unlimited',

          'X1' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B-V',
          },

        }.freeze

        LOCATION_NAMES = {
          'E1' => 'Copenhagen',
          'A15' => 'Brussels',

          'B20' => 'Paris',
          'C25' => 'Bern',
          'J22' => 'Vienna',
          'J16' => 'Prague',
          'B8' => 'Amsterdam',

          'E7' => 'Bremen',

          'F6' => 'Hamburg',

          'D10' => 'Osnabrück',
          'I9' => 'Berlin',
          'F10' => 'Hannover',
          'H10' => 'Magdeburg',
          'B14' => 'Köln',
          'I13' => 'Leipzig',
          'J14' => 'Dresden',
          'D16' => 'Frankfurt',
          'G19' => 'Nürnberg',
          'E21' => 'Stuttgart',
          'H22' => 'Munich',
          'K7' => 'Warsaw',

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

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 31 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 3 },
                  { name: '3', distance: 3, price: 250, rusts_on: '6', num: 8 },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 6 },
                  { name: '5', distance: 5, price: 600, num: 4 },
                  { name: '6', distance: 6, price: 750, num: 3 },
                  { name: '7', distance: 7, price: 900, num: 2 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 30,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        COMPANIES = [

          {
            name: 'Mountain Engineers',
            value: 40,
            revenue: 0,
            desc: 'Owning company receives $20 after laying a yellow tile in a '\
                  'mountain hex.  Any fees must be paid first.',
            sym: 'ME',
            abilities: [
              {
                type: 'tile_income',
                income: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
                owner_only: true,
              },
            ],
            color: nil,
          },
          {
            name: 'Union Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge token that may be placed by the owning corp '\
                  'in Magdeburg or Frankfurt, max one token per city, regardless of '\
                  'connectivity. Allows owning corp to skip $10 river fee when '\
                  'placing yellow tiles.',
            sym: 'UBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: %w[H10 D16],
                count: 2,
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
                  'in a mountain hex next to a revenue location, can place token '\
                  'to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  '\
                  'Hexes pay $10 extra revenue and do not count as a stop.  May '\
                  'not start or end a route at a coal mine.',
            sym: 'MINC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[D14
                          D22

                          E15
                          G11],
                tiles: %w[7 8 9],
                free: false,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Major Coal Mine',
            value: 90,
            revenue: 0,
            desc: 'Comes with three coal mine markers.  When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'MAJC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[D14
                          D22

                          E15
                          G11],
                tiles: %w[7 8 9],
                free: false,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                count: 3,
              },
            ],
            color: nil,
          },
          {
            name: 'Minor Mail Contract',
            value: 60,
            revenue: 0,
            desc: 'Pays owning corp $10 at the start of each operating round, as '\
                  'long as the company has at least one train.',
            sym: 'MINM',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 10,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Major Mail Contract',
            value: 120,
            revenue: 0,
            desc: 'Pays owning corp $20 at the start of each operating round, as '\
                  'long as the company has at least one train.',
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
             sym: 'LD',
             name: 'Leipzig-Dresdner Bahn',
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
             sym: 'OB',
             name: 'Ostbayrische Bahn',
             logo: '1817/J',
             simple_logo: '1817/J.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             text_color: 'black',
             color: '#bedb86',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'NF',
             name: 'Nürnberg-Fürth',
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
             sym: 'BY',
             name: 'Bayrische Eisenbahn',
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
             sym: 'SX',
             name: 'Sächsische Eisenbahn',
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
             sym: 'BD',
             name: 'Badische Eisenbahn',
             logo: '1817/W',
             simple_logo: '1817/W.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#0095da',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'HE',
             name: 'Hessische Eisenbahn',
             logo: '1817/S',
             simple_logo: '1817/S.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#fff36b',
             text_color: 'black',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'WT',
             name: 'Württembergische Eisenbahn',
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
             sym: 'MS',
             name: 'Eisenbahn Mecklenburg Schwerin',
             logo: '1817/PLE',
             simple_logo: '1817/PLE.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#00afad',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'OL',
             name: 'Oldenburgische Eisenbahn',
             logo: '1817/PW',
             simple_logo: '1817/PW.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             text_color: 'black',
             color: '#bec8cc',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BM',
             name: 'Bergisch Märkische Bahn',
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
             sym: 'BP',
             name: 'Berlin Potsdamer Bahn',
             logo: '1817/SR',
             simple_logo: '1817/SR.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#e31f21',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'BS',
             name: 'Berlin Stettiner Bahn',
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
             sym: 'KM',
             name: 'Köln-Mindener Bahn',
             logo: '1817/WT',
             simple_logo: '1817/WT.alt',
             shares: [100],
             max_ownership_percent: 100,
             tokens: [0],
             always_market_price: true,
             color: '#e96f2c',
             reservation_color: nil,
           },
           {
             float_percent: 20,
             sym: 'MB',
             name: 'Magdeburger-Bahn',
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
            %w[D14
               D22
               D24
               E13
               E15
               G11
               G13
               G15] => 'upgrade=cost:15,terrain:mountain',
            %w[B12
               B16
               B18
               C11
               C13
               C17
               C19
               C7
               C9
               C23
               D12
               D6
               D8
               E11
               E19
               E23
               E5
               E9
               F12
               F14
               F16
               F18
               F20
               F22
               F24
               F8
               G17
               G23
               G7
               G9
               H12
               H14
               H16
               H18
               H24
               H4
               I11
               I15
               I3
               I5
               I7
               I19
               I23
               J10
               J12
               J4
               J6
               J8
               K11
               K13
               K9] => '',

            %w[D10
               E7
               E21
               F10
               F6
               G19
               H22
               I13
               I9
               J14] => 'city=revenue:0',
            %w[B14
               D16

               H10] => 'city=revenue:0;upgrade=cost:10,terrain:water',

            %w[C15 D18
               D20
               E17
               E3
               F4
               G21
               G5
               H20
               H6
               H8
               I21
               J20] => 'upgrade=cost:10,terrain:water',

          },
          red: {
            ['B20'] =>
                     'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:3,b:_0',
            ['C25'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:3,b:_0',
            ['J22'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:1,b:_0',
            ['K7'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:1,b:_0',
            ['J16'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:3,b:_0',
            ['B8'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:5,b:_0',
            ['E1'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:0,b:_0',

            ['A15'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:5,b:_0',

          },

          yellow: {
            ['I9'] =>
                     'city=revenue:30;city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:_1,b:0;path=a:_2,b:4;label=B-V',
            ['H22'] =>
        'city=revenue:30;path=a:2,b:_0;path=a:_0,b:4;label=B',
            ['B14'] =>
        'city=revenue:30;path=a:3,b:_0;path=a:_0,b:5;label=B',

          },

        }.freeze

        LAYOUT = :flat

        def available_shorts(_corporation)
          [0, 0]
        end

        SEED_MONEY = 150
        LOANS_PER_INCREMENT = 4
      end
    end
  end
end
# rubocop:enable Layout/LineLength
