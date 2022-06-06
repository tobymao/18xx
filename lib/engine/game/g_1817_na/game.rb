# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'

module Engine
  module Game
    module G1817NA
      class Game < G1817::Game
        include_meta(G1817NA::Meta)

        CURRENCY_FORMAT_STR = '$%d'

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
          'A7' => 'Dawson City',
          'B2' => 'Anchorage',
          'B6' => 'The Klondike',
          'B18' => 'Arctic',
          'C3' => 'Asia',
          'C9' => 'Hazelton',
          'D12' => 'Edmonton',
          'D16' => 'Winnipeg',
          'D22' => 'Quebec',
          'D26' => 'Europe',
          'E9' => 'Seattle',
          'F14' => 'Denver',
          'F20' => 'Toronto',
          'F22' => 'New York',
          'H8' => 'Hawaii',
          'H10' => 'Los Angeles',
          'H18' => 'New Orleans',
          'I13' => 'Guadalajara',
          'I15' => 'Mexico City',
          'I21' => 'Miami',
          'J18' => 'Belize',
          'K21' => 'South America',
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
            name: 'Denver Telecommunications',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place special Denver yellow tile during tile-laying, '\
                  'regardless of connectivity.  The hex is not reserved, and the '\
                  'power is lost if another company builds there first.',
            sym: 'DTC',
            abilities: [
            {
              type: 'tile_lay',
              hexes: ['F14'],
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
                  'in Winnipeg or New Orleans, max one token per city, regardless of '\
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
                hexes: %w[D16 H18],
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
                hexes: %w[A3
                          B4
                          B8
                          B10
                          D10
                          E11
                          E13
                          F12
                          G13
                          G19
                          H12
                          J14],
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
                hexes: %w[A3
                          B4
                          B8
                          B10
                          D10
                          E11
                          E13
                          F12
                          G13
                          G19
                          H12
                          J14],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
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
            sym: 'J',
            name: 'Elgin, Joliet and Eastern Railway',
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
            sym: 'NYOW',
            name: 'New York, Ontario and Western Railway',
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
            sym: 'NYSW',
            name: 'New York, Susquehanna and Western Railway',
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
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
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
            sym: 'PW',
            name: 'Providence and Worcester Railroad',
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
            sym: 'SR',
            name: 'Strasburg Railroad',
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
            sym: 'WT',
            name: 'Warren & Trumbull Railroad',
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
            %w[A3
               B4
               B8
               B10
               D10
               E11
               E13
               F12
               G13
               G19
               H12
               J14] => 'upgrade=cost:15,terrain:mountain',
            %w[A5
               A9
               B12
               C7
               C11
               C13
               C15
               C17
               C23
               D18
               D20
               D24
               E21
               E23
               F10
               G9
               G11
               G15
               G21
               H14
               H16
               H20
               J16
               K17
               K19] => '',
            ['E19'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['E17'] => 'border=edge:4,type:impassable',
            ['F18'] => 'border=edge:3,type:impassable',
            ['A7'] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[B2 C9 D22 E9 F14 F20 H10 I13] => 'city=revenue:0',
            ['J18'] => 'city=revenue:0;border=edge:3,type:impassable',
            %w[D8 E25 J20] => 'upgrade=cost:20,terrain:lake',
            ['I19'] => 'upgrade=cost:20,terrain:lake;border=edge:0,type:impassable',
            %w[D14 E15 F16 G17] => 'upgrade=cost:10,terrain:water',
            %w[H18 D16] => 'city=revenue:0;upgrade=cost:10,terrain:water',
          },
          gray: {
            ['B6'] =>
                     'town=revenue:yellow_50|green_20|brown_40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            %w[B14 C19] => 'path=a:1,b:4',
            %w[B16 C21] => 'path=a:1,b:5',
            ['I21'] =>
            'city=revenue:yellow_20|green_30|brown_50|gray_60;path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_0;path=a:_0,b:1',
          },
          red: {
            ['B18'] =>
                     'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0',
            ['C3'] =>
            'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0',
            ['D26'] =>
            'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:1,b:_0;path=a:0,b:_0',
            ['H8'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0',
            ['K21'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0',
          },
          yellow: {
            ['D12'] => 'city=revenue:30;path=a:2,b:_0;path=a:_0,b:4;label=B',
            ['F22'] =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_1;path=a:0,b:_0;label=NY;upgrade=cost:20,terrain:lake',
            ['I15'] =>
            'city=revenue:30;path=a:1,b:_0;path=a:_0,b:5;label=B;upgrade=cost:20,terrain:lake',
          },
          blue: {
            %w[I17 C1 F8] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0',
            ['I9'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0;border=edge:4',
            ['J12'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0;border=edge:2',
            ['I11'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:2,b:_0;offboard=revenue:yellow_0,visit_cost:99;'\
                       'path=a:4,b:_0;border=edge:1;border=edge:5',
            ['A1'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:5,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        SEED_MONEY = 150
        LOANS_PER_INCREMENT = 4

        def setup_preround
          super
          @pittsburgh_private = @companies.find { |c| c.id == 'DTC' }
        end
      end
    end
  end
end
