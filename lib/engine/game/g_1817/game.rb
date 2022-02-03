# frozen_string_literal: true

require_relative 'meta'
require_relative '../../loan'
require_relative '../base'
require_relative '../interest_on_loans'

module Engine
  module Game
    module G1817
      class Game < Game::Base
        include_meta(G1817::Meta)

        register_colors(black: '#16190e',
                        blue: '#165633',
                        brightGreen: '#0a884b',
                        brown: '#984573',
                        gold: '#904098',
                        gray: '#984d2d',
                        green: '#bedb86',
                        lavender: '#e96f2c',
                        lightBlue: '#bedef3',
                        lightBrown: '#bec8cc',
                        lime: '#00afad',
                        navy: '#003d84',
                        natural: '#e31f21',
                        orange: '#f2a847',
                        pink: '#ee3e80',
                        red: '#ef4223',
                        turquoise: '#0095da',
                        violet: '#e48329',
                        white: '#fff36b',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11, 7 => 9, 8 => 8, 9 => 7, 10 => 6, 11 => 6, 12 => 5 }.freeze

        STARTING_CASH = {
          3 => 420,
          4 => 315,
          5 => 252,
          6 => 210,
          7 => 180,
          8 => 158,
          9 => 140,
          10 => 126,
          11 => 115,
          12 => 105,
        }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILE_TYPE = :lawson

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
          'A20' => 'Montréal',
          'A28' => 'Maritime Prov.',
          'B5' => 'Lansing',
          'B13' => 'Toronto',
          'B17' => 'Rochester',
          'C8' => 'Detroit',
          'C14' => 'Buffalo',
          'C22' => 'Albany',
          'C26' => 'Boston',
          'D1' => 'Chicago',
          'D7' => 'Toledo',
          'D9' => 'Cleveland',
          'D19' => 'Scranton',
          'E22' => 'New York',
          'F3' => 'Indianapolis',
          'F13' => 'Pittsburgh',
          'F19' => 'Philadelphia',
          'G6' => 'Cincinnati',
          'G18' => 'Baltimore',
          'H1' => 'St. Louis',
          'H3' => 'Louisville',
          'H9' => 'Charleston',
          'I12' => 'Blacksburg',
          'I16' => 'Richmond',
          'J7' => 'Atlanta',
          'J15' => 'Raleigh-Durham',
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

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 40 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 4 },
                  { name: '3', distance: 3, price: 250, rusts_on: '6', num: 12 },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 8 },
                  { name: '5', distance: 5, price: 600, num: 5 },
                  { name: '6', distance: 6, price: 750, num: 4 },
                  { name: '7', distance: 7, price: 900, num: 3 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 40,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        COMPANIES = [
          {
            name: 'Pittsburgh Steel Mill',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place special Pittsburgh yellow tile during '\
                  'tile-laying, regardless of connectivity.  The hex is not '\
                  'reserved, and the power is lost if another company builds there first.',
            sym: 'PSM',
            abilities: [
            {
              type: 'tile_lay',
              hexes: ['F13'],
              tiles: ['X00'],
              when: 'track',
              owner_type: 'corporation',
              count: 1,
              consume_tile_lay: true,
              closed_when_used_up: true,
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
            name: 'Ohio Bridge Company',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the '\
                  'owning corp in Louisville, Cincinnati, or Charleston, max one '\
                  'token per city, regardless of connectivity.  Allows owning '\
                  'corp to skip $10 river fee when placing yellow tiles.',
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
                hexes: %w[H3 G6 H9],
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Union Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge token that may be placed by the '\
                  'owning corp in Louisville, Cincinnati, or Charleston, max '\
                  'one token per city, regardless of connectivity.  Allows '\
                  'owning corp to skip $10 river fee when placing yellow tiles.',
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
                hexes: %w[H3 G6 H9],
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
            desc: 'Comes with one coal mine marker.  When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can '\
                  'place token to avoid $15 terrain fee.  Marked yellow hexes '\
                  'cannot be upgraded.  Hexes pay $10 extra revenue and do not '\
                  'count as a stop.  May not start or end a route at a coal mine.',
            sym: 'MINC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B25
                          C20
                          C24
                          E18
                          F15
                          G12
                          G14
                          H11
                          H13
                          H15
                          I8
                          I10],
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
            desc: 'Comes with two coal mine markers.  When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can '\
                  'place token to avoid $15 terrain fee.  Marked yellow hexes '\
                  'cannot be upgraded.  Hexes pay $10 extra revenue and do not '\
                  'count as a stop.  May not start or end a route at a coal mine.',
            sym: 'CM',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B25
                          C20
                          C24
                          E18
                          F15
                          G12
                          G14
                          H11
                          H13
                          H15
                          I8
                          I10],
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
            name: 'Major Coal Mine',
            value: 90,
            revenue: 0,
            desc: 'Comes with three coal mine markers.  When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot '\
                  'be upgraded.  Hexes pay $10 extra revenue and do not count '\
                  'as a stop.  May not start or end a route at a coal mine.',
            sym: 'MAJC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B25
                          C20
                          C24
                          E18
                          F15
                          G12
                          G14
                          H11
                          H13
                          H15
                          I8
                          I10],
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
            desc: 'Pays owning corp $10 at the start of each operating round, '\
                  'as long as the company has at least one train.',
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
            name: 'Mail Contract',
            value: 90,
            revenue: 0,
            desc: 'Pays owning corp $15 at the start of each operating round, '\
                  'as long as the company has at least one train.',
            sym: 'MAIL',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 15,
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
            sym: 'A&A',
            name: 'Arcade and Attica',
            logo: '1817/AA',
            simple_logo: '1817/AA.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#904098',
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
          red: {
            ['A20'] =>
                     'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:5,b:_0;path=a:0,b:_0',
            ['A28'] =>
                   'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0',
            ['D1'] =>
                   'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:4,b:_0;path=a:5,b:_0',
            ['H1'] =>
                   'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J7'] =>
                   'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0',
            ['J15'] =>
                   'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0',
          },
          white: {
            %w[B5 B17 C14 C22 F3 F13 F19 I16] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;upgrade=cost:20,terrain:lake',
            %w[D19 I12] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[G6 H3 H9] => 'city=revenue:0;upgrade=cost:10,terrain:water',
            %w[B25
               C20
               C24
               E16
               E18
               F15
               G12
               G14
               H11
               H13
               H15
               I8
               I10] => 'upgrade=cost:15,terrain:mountain',
            %w[D13 E12 F11 G4 G10 H7] => 'upgrade=cost:10,terrain:water',
            %w[B9 B27 D25 D27 G20 H17] => 'upgrade=cost:20,terrain:lake',
            %w[B3
               B7
               B11
               B15
               B19
               B21
               B23
               C4
               C6
               C16
               C18
               D3
               D5
               D15
               D17
               D21
               D23
               E2
               E4
               E6
               E8
               E10
               E14
               E20
               F5
               F7
               F9
               F17
               F21
               G2
               G8
               G16
               H5
               I2
               I4
               I6
               I14] => '',
            ['C10'] => 'border=edge:5,type:impassable',
            ['D11'] => 'border=edge:2,type:impassable',
          },
          gray: {
            ['B13'] =>
                     'town=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['D9'] =>
            'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:5,b:_0;path=a:0,b:_0',
            ['F1'] => 'junction;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          yellow: {
            ['C8'] =>
                     'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B;upgrade=cost:20,terrain:lake',
            ['C26'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B',
            ['E22'] =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;label=NY;upgrade=cost:20,terrain:lake',
            ['G18'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',
          },
          blue: { ['C12'] => '' },
        }.freeze

        LAYOUT = :pointy

        TRAIN_STATION_PRIVATE_NAME = 'TS'
        PITTSBURGH_PRIVATE_NAME = 'PSM'
        PITTSBURGH_PRIVATE_HEX = 'F13'

        MUST_BID_INCREMENT_MULTIPLE = true
        SEED_MONEY = 200
        MUST_BUY_TRAIN = :never
        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        CERT_LIMIT_INCLUDES_PRIVATES = false
        POOL_SHARE_DROP = :each
        SELL_MOVEMENT = :none
        ALL_COMPANIES_ASSIGNABLE = true
        SELL_AFTER = :after_ipo
        OBSOLETE_TRAINS_COUNT_FOR_LIMIT = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        ASSIGNMENT_TOKENS = {
          'bridge' => '/icons/1817/bridge_token.svg',
          'mine' => '/icons/1817/mine_token.svg',
        }.freeze

        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :one_more_full_or_set }.freeze

        CERT_LIMIT_CHANGE_ON_BANKRUPTCY = true

        # Two lays with one being an upgrade, second tile costs 20
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        LIMIT_TOKENS_AFTER_MERGER = 8

        EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                    'Game Ends 3 ORs after purchase/export'\
                                                                    ' of first 8 train']).freeze
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'no_new_shorts' => ['Cannot gain new shorts', 'Short selling is not permitted, existing shorts remain'],
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(safe_par: 'Minimum Price for a 2($55), 5($70) and 10($120) share'\
                                                        ' corporation taking maximum loans to ensure it avoids acquisition',
                                              acquisition: 'Acquisition (Pay $40 dividend to move right, $80'\
                                                           ' to double jump)').freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :gray).freeze
        MARKET_SHARE_LIMIT = 1000 # notionally unlimited shares in market
        CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze

        MIN_LOAN = 5
        MAX_LOAN = 70
        LOANS_PER_INCREMENT = 5
        LOAN_INTEREST_INCREMENTS = 5

        include InterestOnLoans
        attr_reader :owner_when_liquidated, :stock_prices_start_merger

        def timeline
          @timeline = [
            'At the end of each OR the next available train will be exported
           (removed, triggering phase change as if purchased)',
          ]
        end

        def init_cert_limit
          @log << '1817 has not been tested thoroughly with more than seven players.' if @players.size > 7

          super
        end

        def available_programmed_actions
          [Action::ProgramMergerPass, Action::ProgramBuyShares, Action::ProgramSharePass]
        end

        def merge_rounds
          [G1817::Round::Merger, G1817::Round::Acquisition]
        end

        def merge_corporations
          @corporations.select { |c| c.floated? && c.share_price.normal_movement? && !c.share_price.acquisition? }
        end

        def option_short_squeeze?
          @optional_rules&.include?(:short_squeeze)
        end

        def option_five_shorts?
          @optional_rules&.include?(:five_shorts)
        end

        def option_modern_trains?
          @optional_rules&.include?(:modern_trains)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def init_stock_market
          @owner_when_liquidated = {}
          super
        end

        def loans_per_increment(_increment)
          self.class::LOANS_PER_INCREMENT
        end

        def loan_interest_increments
          self.class::LOAN_INTEREST_INCREMENTS
        end

        def min_loan
          self.class::MIN_LOAN
        end

        def max_loan
          self.class::MAX_LOAN
        end

        def init_loans
          total_loans = (min_loan..max_loan).step(loan_interest_increments).sum do |r|
            loans_per_increment(r)
          end

          @loan_value = 100
          Array.new(total_loans) { |id| Loan.new(id, @loan_value) }
        end

        def loan_value(_entity = nil)
          @loan_value
        end

        def cannot_pay_interest_str
          '(Liquidate)'
        end

        def future_interest_rate
          taken = loans_taken
          interest = (min_loan..max_loan).step(loan_interest_increments).find do |r|
            taken -= loans_per_increment(r)
            taken <= 0
          end || 0

          [[min_loan, interest].max, max_loan].min
        end

        def interest_rate
          @interest_fixed || future_interest_rate
        end

        def loans_due_interest(entity)
          entity.loans.size
        end

        def interest_owed_for_loans(loans)
          (interest_rate * loans * @loan_value) / 100
        end

        def interest_owed(entity)
          interest_owed_for_loans(entity.loans.size)
        end

        def interest_change
          rate = future_interest_rate
          summary = []

          unless rate == min_loan
            loans = loans_taken - (min_loan...rate).step(loan_interest_increments).sum { |r| loans_per_increment(r) }
            s = loans == 1 ? '' : 's'
            summary << ["Interest if #{loans} more loan#{s} repaid", rate - loan_interest_increments]
          end
          loan_table = []
          if loans_taken.zero?
            loan_table << [rate, loans_per_increment(rate)]
            summary << ["Interest if #{loans_per_increment(rate) + 1} more loans taken", 10]
          elsif rate != max_loan
            loans = (min_loan..rate).step(loan_interest_increments).sum { |r| loans_per_increment(r) } - loans_taken
            loan_table << [rate, loans]
            s = loans == 1 ? '' : 's'
            summary << ["Interest if #{loans + 1} more loan#{s} taken", rate + loan_interest_increments]
          end

          (rate + loan_interest_increments..max_loan).step(loan_interest_increments) do |r|
            loan_table << [r, loans_per_increment(r)]
          end
          [summary, loan_table]
        end

        def format_currency(val)
          # On dividends per share can be a float
          # But don't show decimal points on all
          return super if (val % 1).zero?

          format('$%.1<val>f', val: val)
        end

        def maximum_loans(entity)
          entity.total_shares
        end

        def bidding_power(player)
          player.cash + player.companies.sum(&:value)
        end

        def operating_order
          super.reject { |c| c.share_price.liquidation? }
        end

        def home_token_locations(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.is_a?(Engine::Step::BuySellParShares) }.active?
          return [] if entity.share_price.acquisition? || entity.share_price.liquidation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def tokens_needed(corporation)
          tokens_needed = { 2 => 1, 5 => 2, 10 => 4 }[corporation.total_shares] - corporation.tokens.size
          tokens_needed += 1 if corporation.companies.any? { |c| c.id == 'TS' }
          tokens_needed
        end

        def size_corporation(corporation, size)
          original_shares = shares_for_corporation(corporation)
          raise GameError, 'Can only convert 2 share corporation' unless corporation.total_shares == 2

          corporation.share_holders.clear

          case size
          when 5
            original_shares[0].percent = 40
            shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          when 10
            original_shares[0].percent = 20
            shares = Array.new(8) { |i| Share.new(corporation, percent: 10, index: i + 1) }
          end

          original_shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          corporation.max_ownership_percent = 60 unless size == 2

          shares.each do |share|
            add_new_share(share)
          end
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          super(
            share_holder,
            corporation,
            shares: shares || share_holder.shares_of(corporation).select { |share| share.percent.positive? },
          )
        end

        def convert(corporation)
          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          case corporation.total_shares
          when 2
            shares[0].percent = 40
            new_shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          when 5
            shares.each { |share| share.percent = share.percent.positive? ? 10 : -10 }
            shares[0].percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          else
            raise GameError, 'Cannot convert 10 share corporation'
          end

          corporation.max_ownership_percent = 60
          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end
          new_shares
        end

        def available_shorts(corporation)
          return [0, 0] if corporation&.total_shares == 2

          [shorts(corporation).size, corporation.total_shares]
        end

        def shorts(corporation)
          shares = []

          @_shares.each do |_, share|
            shares << share if share.corporation == corporation && share.percent.negative?
          end

          shares
        end

        def entity_shorts(entity, corporation)
          entity.shares_of(corporation).select { |share| share.percent.negative? }
        end

        def close_market_shorts
          @corporations.each do |corporation|
            # Try closing shorts
            count = 0
            while entity_shorts(@share_pool, corporation).any? &&
              (market_shares = @share_pool.shares_of(corporation)
               .select { |share| share.percent.positive? && !share.president }).any?

              unshort(@share_pool, market_shares.first)
              count += 1
            end
            @log << "Market closes #{count} shorts for #{corporation.name}" if count.positive?
          end
        end

        def close_bank_shorts
          # Close out shorts in stock market with the bank buying shares from the treasury
          @corporations.each do |corporation|
            next unless corporation.share_price
            next if corporation.share_price.acquisition? || corporation.share_price.liquidation?

            count = 0
            while entity_shorts(@share_pool, corporation).any? &&
              corporation.shares.any?

              # Market buys the share
              share = corporation.shares.first
              @share_pool.buy_shares(@share_pool, share)

              # Then closes the share
              unshort(@share_pool, share)
              count += 1

            end
            @log << "Market closes #{count} shorts for #{corporation.name}" if count.positive?
          end
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          super
          close_market_shorts
        end

        def migrate_shares(corporation, other)
          # Migrate shares from a 5 & 5 corporation merger
          new_shares = convert(corporation)
          percentage = 10

          shares = @_shares.values.select { |share| share.corporation == other }
          surviving_shares = @_shares.values.select { |share| share.corporation == corporation }
          # Highest share (9 is all the potential 'normal' share certificates)
          highest_share = [surviving_shares.map(&:index).max, 9].max

          shares.each do |share|
            entity = share.owner
            entity = corporation if entity == other
            # convert each 20% in the old company into 10% in the new company
            (share.percent / 20).abs.times do
              if share.percent.positive?
                if new_shares.any?
                  # Use the 'normal' shares where possible until they run out.
                  new_share = new_shares.shift
                  new_share.transfer(entity)
                else
                  highest_share += 1
                  new_share = Share.new(corporation, owner: entity, percent: percentage, index: highest_share)
                  add_new_share(new_share)
                end
              else
                highest_share += 1
                short = Share.new(corporation, owner: entity, percent: -percentage, index: highest_share)
                short.buyable = false
                short.counts_for_limit = false
                add_new_share(short)
              end
            end
          end

          max_shares = corporation.player_share_holders.values.max

          # Check cross-short merge problem
          raise GameError, 'At least one player must have more than 20% to allow a merge' if max_shares < 20

          # Find the new president, tie break is the surviving corporation president
          # This is done before the cancelling to ensure the new president can cancel any shorts
          majority_share_holders = corporation
            .player_share_holders
            .select { |_, p| p == max_shares }
            .keys

          previous_president = corporation.owner

          if majority_share_holders.none? { |player| player == previous_president }
            president = majority_share_holders
              .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
              .min_by { |p| @share_pool.distance(previous_president, p) }

            president_share = previous_president.shares_of(corporation).find(&:president)
            corporation.owner = president
            @log << "#{president.name} becomes the president of #{corporation.name}"
            @share_pool.change_president(president_share, previous_president, president)
          end

          # Consolidate shorts with their share pair (including share pool shares)
          shares_for_corporation(corporation)
            .group_by(&:owner)
            .each do |owner, _shares_|
            shares = owner.shares_of(corporation)
            while shares.any? { |s| s.percent.negative? } && shares.any? { |s| s.percent == percentage }
              share = shares.find { |s| s.percent == percentage }
              unshort(owner, share)
            end
          end
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def remove_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] -= share.percent if owner
          owner.shares_by_corporation[corporation].delete(share)
          @_shares.delete(share.id)
        end

        def short(entity, corporation)
          price = corporation.share_price.price
          percent = corporation.share_percent

          shares = shares_for_corporation(corporation)

          # Highest share (9 is all the potential 'normal' share certificates)
          highest_share = [shares.map(&:index).max, 9].max

          share = Share.new(corporation, owner: @share_pool, percent: percent, index: highest_share + 1)
          short = Share.new(corporation, owner: entity, percent: -percent, index: highest_share + 2)
          short.buyable = false
          short.counts_for_limit = false

          @log << "#{entity.name} shorts a #{percent}% " \
                  "share of #{corporation.name} for #{format_currency(price)}"

          @bank.spend(price, entity)
          add_new_share(short)
          add_new_share(share)
        end

        def unshort(entity, share)
          # Share is the positive share bought to cancel the short.
          # The share should be owned by the entity

          shares = entity.shares_of(share.corporation)
          remove_share(share)

          short = shares.find { |s| s.percent == -share.percent }
          remove_share(short)
        end

        def take_loan(entity, loan)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          price = entity.share_price.price
          name = entity.name
          name += " (#{entity.owner.name})" if @round.is_a?(Engine::Round::Stock)
          @log << "#{name} takes a loan and receives #{format_currency(loan.amount)}"
          @bank.spend(loan.amount, entity)
          loan_taken_stock_market_movement(entity)
          log_share_price(entity, price)
          entity.loans << loan
          @loans.delete(loan)
        end

        def loan_taken_stock_market_movement(entity)
          @stock_market.move_left(entity)
        end

        def payoff_loan(entity, loan, adjust_share_price: true)
          raise GameError, "Loan doesn't belong to that entity" unless entity.loans.include?(loan)

          amount = loan.amount
          @log << "#{entity.name} pays off a loan for #{format_currency(amount)}"
          entity.spend(amount, @bank)

          entity.loans.delete(loan)
          @loans << loan
          return unless adjust_share_price

          price = entity.share_price.price
          loan_payoff_stock_market_movement(entity)
          log_share_price(entity, price)
        end

        def loan_payoff_stock_market_movement(entity)
          @stock_market.move_right(entity)
        end

        def can_take_loan?(entity)
          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            !@loans.empty?
        end

        def float_str(_entity)
          '2 shares to start'
        end

        def available_loans(entity, extra_loans)
          [maximum_loans(entity) - entity.loans.size, @loans.size + extra_loans].min
        end

        def buying_power(entity, extra_loans: 0, **)
          return entity.cash unless entity.corporation?

          entity.cash + (available_loans(entity, extra_loans) * @loan_value)
        end

        def unstarted_corporation_summary
          [(@corporations.count { |c| !c.ipoed }).to_s, []]
        end

        def liquidate!(corporation)
          return if corporation.owner == @share_pool

          @owner_when_liquidated[corporation] = corporation.owner
          @stock_market.move(corporation, 0, 0, force: true)
        end

        def train_help(_entity, _runnable_trains, routes)
          all_hexes = {}
          @companies.each do |company|
            abilities(company, :assign_hexes)&.hexes&.each do |hex|
              all_hexes[hex] = company
            end
          end
          warnings = []
          unless hexes.empty?

            routes.each do |route|
              route.stops.each do |stop|
                if (company = all_hexes[stop.hex.id])
                  warnings << "Using #{company.name} on #{stop.hex.id} will improve revenue"
                end
              end
            end
          end

          warnings
        end

        def pullman_train?(_train)
          false
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += 10 * stops.count { |stop| stop.hex.assigned?('bridge') }

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          mine = 'mine'
          if route.hexes.first.assigned?(mine) || route.hexes.last.assigned?(mine)
            raise GameError, 'Route cannot start or end with a mine'
          end

          if option_modern_trains? && [7, 8].include?(route.train.distance)
            per_token = route.train.distance == 7 ? 10 : 20
            revenue += stops.sum do |stop|
              next per_token if stop.city? && stop.tokened_by?(route.train.owner)

              0
            end
          end

          revenue += 10 * route.all_hexes.count { |hex| hex.assigned?(mine) }
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
          entity.total_shares.to_s
        end

        private

        def new_auction_round
          log << "Seed Money for initial auction is #{format_currency(self.class::SEED_MONEY)}" unless @round
          Engine::Round::Auction.new(self, [
            G1817::Step::SelectionAuction,
          ])
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1817::Step::BuySellParShares,
          ])
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

          G1817::Round::Operating.new(self, [
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

        def or_round_finished
          if @depot.upcoming.first.name == '2'
            depot.export_all!('2')
          else
            depot.export!
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
              # Store the share price of each corp to determine if they can be acted upon in the AR
              @stock_prices_start_merger = @corporations.to_h { |corp| [corp, corp.share_price] }
              @log << "-- #{round_description('Merger and Conversion', @round.round_num)} --"
              G1817::Round::Merger.new(self, [
                Engine::Step::ReduceTokens,
                Engine::Step::DiscardTrain,
                G1817::Step::PostConversion,
                G1817::Step::PostConversionLoans,
                G1817::Step::Conversion,
              ], round_num: @round.round_num)
            when G1817::Round::Merger
              @log << "-- #{round_description('Acquisition', @round.round_num)} --"
              G1817::Round::Acquisition.new(self, [
                Engine::Step::ReduceTokens,
                G1817::Step::Bankrupt,
                G1817::Step::CashCrisis,
                Engine::Step::DiscardTrain,
                G1817::Step::Acquire,
              ], round_num: @round.round_num)
            when G1817::Round::Acquisition
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when init_round.class
              reorder_players
              new_stock_round
            end
        end

        def round_end
          G1817::Round::Acquisition
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        def event_signal_end_game!
          # If we're in round 1, we have another set of ORs with 2 ORs
          # If we're in round 2, we have another set of ORs with 3 ORs
          @final_operating_rounds = @round.round_num == 2 ? 3 : 2
          game_end_check
          @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
        end
      end
    end
  end
end
