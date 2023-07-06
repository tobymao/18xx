# frozen_string_literal: true

require_relative 'meta'
require_relative 'share_pool'
require_relative 'stock_market'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18CO
      class Game < Game::Base
        include_meta(G18CO::Meta)
        include CitiesPlusTownsRouteDistanceStr

        attr_accessor :presidents_choice

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a',
                        black: '#000000',
                        pink: '#FF0099',
                        purple: '#9900FF',
                        white: '#FFFFFF')
        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 17, 4 => 14, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        EBUY_PRES_SWAP = false

        TILES = {
          '3a' =>
                 {
                   'count' => 6,
                   'color' => 'yellow',
                   'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:1',
                 },
          '4a' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:3',
          },
          '5' => 3,
          '6' => 6,
          '7' => 15,
          '8' => 25,
          '9' => 25,
          '57' => 6,
          '58a' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:2',
          },
          'co1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30,slots:2;city=revenue:30;city=revenue:30;path=a:5,b:_0;'\
                      'path=a:_0,b:0;path=a:1,b:_1;path=a:_1,b:2;path=a:3,b:_2;path=a:_2,b:4;label=D;',
          },
          'co5' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:20,hide:1;path=a:0,b:_0;path=a:_0,b:5;'\
                      'path=a:2,b:_1;path=a:_1,b:4;label=C;',
          },
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          'co8' =>
          {
            'count' => 5,
            'color' => 'green',
            'code' =>
            'town=revenue:20,to_city:1;junction;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          'co9' =>
          {
            'count' => 5,
            'color' => 'green',
            'code' =>
            'town=revenue:20,to_city:1;junction;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          'co10' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:20,to_city:1;junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          'co2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:3,loc:16.5;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=D;',
          },
          'co6' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=C;',
          },
          '39' => 1,
          '40' => 2,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '63' => 6,
          'co3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=D;',
          },
          'co4' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
          'co7' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0,;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C;',
          },
        }.freeze

        LOCATION_NAMES = {
          'A11' => 'Laramie, WY',
          'A17' => 'Cheyenne, WY',
          'B10' => 'Walden',
          'B22' => 'Sterling',
          'B26' => 'Lincoln, NE (SLC +100)',
          'C7' => 'Craig',
          'C9' => 'Steamboat Springs',
          'C15' => 'Fort Collins',
          'C17' => 'Greeley',
          'C21' => 'Fort Morgan',
          'D4' => 'Meeker',
          'D14' => 'Boulder',
          'D24' => 'Wray',
          'E1' => 'Salt Lake City, UT',
          'E5' => 'Rifle',
          'E7' => 'Glenwood Springs',
          'E11' => 'Dillon',
          'E15' => 'Denver',
          'E27' => 'Kansas City, KS (SLC +100)',
          'F8' => 'Aspen',
          'F12' => 'South Park',
          'F20' => 'Limon',
          'F24' => 'Burlington',
          'G3' => 'Grand Junction',
          'G17' => 'Colorado Springs',
          'G27' => 'Kansas City, KS (SLC +100)',
          'H6' => 'Montrose',
          'H8' => 'Gunnison',
          'H12' => 'Salida',
          'H14' => 'Canon City',
          'I17' => 'Pueblo',
          'I21' => 'La Junta',
          'I23' => 'Lamar',
          'J6' => 'Silverton',
          'J26' => 'Wichita, KS (SLC +100)',
          'K5' => 'Durango',
          'K13' => 'Alamosa',
          'K17' => 'Trinidad',
          'L2' => 'Farmington, NM',
          'L14' => 'Santa Fe, NM',
          'L20' => 'Fort Worth, TX',
        }.freeze

        MARKET = [
          %w[140
             145
             150
             155
             165
             175
             190
             205
             225
             250
             280
             315
             355
             395
             440
             485],
          %w[110
             115
             120
             125
             135
             145z
             160z
             175
             195
             220
             250
             280
             315
             350
             385
             425],
          %w[85
             90
             95
             100x
             110x
             120z
             135z
             150
             170
             195
             220
             245
             275
             305
             335
             370],
          %w[65
             70
             75p
             80x
             90x
             100
             115
             130
             150
             170
             195
             215
             240
             265
             290
             320],
          %w[50
             55
             60p
             65
             75
             85
             100
             115
             130
             150
             170
             185
             205],
          %w[40 45 50p 55 65 75 85 100 115 130],
          %w[30 35 40p 45 55 65 75 85],
          %w[25 30 35 40 45 55 65],
          %w[20 25 30 35 40 45],
          %w[15 20 25 30 35 40],
          %w[10a 15 20 25 30],
          %w[10a 10a 15 20 20],
          %w[10a 10a 10a 15a 15a],
        ].freeze

        # Hexes that are small towns. Used in special GJGR ability.
        SMALL_TOWNS = %w[C9
                         C17
                         C21
                         D14
                         E7
                         H8
                         H14
                         K13].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 2 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    status: ['closable_corporations'],
                    operating_rounds: 2,
                  },
                  {
                    name: '5b',
                    on: '4D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: ['closable_corporations'],
                    operating_rounds: 2,
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: ['closable_corporations'],
                    operating_rounds: 2,
                  },
                  {
                    name: '6b',
                    on: %w[5D E],
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: %w[closable_corporations corporate_shares_open],
                    operating_rounds: 2,
                  },
                  {
                    name: '7',
                    on: 'E',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: %w[closable_corporations corporate_shares_open reduced_tile_lay],
                    operating_rounds: 2,
                  }].freeze

        TRAINS = [
          {
            name: '2P',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 0,
            num: 1,
          },
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            rusts_on: '4D',
            num: 5,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 280,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            events: [{ 'type' => 'close_companies' }, { 'type' => 'unreserve_home_stations' }],
            price: 500,
            rusts_on: 'E',
            num: 2,
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            available_on: '5',
            price: 650,
            num: 3,
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            events: [{ 'type' => 'remove_mines' }],
            price: 720,
            num: 10,
          },
          {
            name: '5D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            events: [{ 'type' => 'presidents_choice' }],
            available_on: '6',
            price: 850,
            num: 2,
          },
          {
            name: 'E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 99, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            events: [{ 'type' => 'presidents_choice' }],
            available_on: '6',
            price: 1000,
            num: 1,
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'IMC',
            name: 'Idarado Mining Company',
            value: 30,
            revenue: 5,
            desc: 'Money gained from mine tokens is doubled for the owning Corporation. '\
                  'If owned by a Corporation, closes on purchase of “6” train, otherwise '\
                  'closes on purchase of “5” train.',
            abilities: [{ type: 'close', owner_type: 'corporation', on_phase: '6' }],
            color: nil,
          },
          {
            sym: 'GJGR',
            name: 'Grand Junction and Grand River Valley Railway',
            value: 40,
            revenue: 10,
            desc: 'An owning Corporation may upgrade a yellow town to a green city in '\
                  'additional to its normal tile lay at any time during its turn. This tile '\
                  'does not need to be reachable by the corporation\'s trains. Action closes '\
                  'the company or closes on purchase of “5” train.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                owner_type: 'corporation',
                when: %w[track special_track],
                count: 1,
                special: true,
                tiles: %w[14 15],
                hexes: SMALL_TOWNS,
              },
            ],
            color: nil,
          },
          {
            sym: 'DNP',
            name: 'Denver, Northwestern and Pacific Railroad',
            value: 50,
            revenue: 10,
            desc: 'An owning Corporation may return a station token to its charter to gain '\
                  'the token cost. The token is placed on the rightmost (most expensive) empty '\
                  'token slot with money gained corresponding to empty token slot\'s price. The '\
                  'corporation must always have at least one token on the board. Action closes '\
                  'the company or closes on purchase of “5” train.',
            abilities: [
              {
                type: 'return_token',
                owner_type: 'corporation',
                count: 1,
                reimburse: true,
              },
            ],
            color: nil,
          },
          {
            sym: 'Toll',
            name: 'Saguache & San Juan Toll Road Company',
            value: 60,
            revenue: 10,
            desc: 'An owning Corporation receives a $20 discount on the cost of tile lays. Closes '\
                  'on purchase of “5” train.',
            abilities: [{ type: 'tile_discount', discount: 20 }],
            color: nil,
          },
          {
            sym: 'LNPW',
            name: 'Laramie, North Park and Western Railroad',
            value: 70,
            revenue: 15,
            desc: 'When laying track tiles, an owning Corporation may lay an extra yellow tile at '\
                  'no cost in addition to its normal tile lay. Action closes the company or closes '\
                  'on purchase of “5” train.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                special: false,
                reachable: true,
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                hexes: [],
                tiles: %w[co1 co5 3a 4a 5 6 7 8 9 57 58a],
              },
            ],
            color: nil,
          },
          {
            sym: 'DPRT',
            name: 'Denver Pacific Railway and Telegraph Company',
            value: 100,
            revenue: 15,
            desc: 'The owner immediately receives one share of either Denver Pacific Railroad, '\
                  'Colorado and Southern Railroad, Kansas Pacific Railway or Colorado Midland Railway. '\
                  'The railroad receives money equal to the par value when the President’s Certificate '\
                  'is purchased. Closes on purchase of “5” train.',
            abilities: [
              {
                type: 'shares',
                shares: 'random_share',
                corporations: %w[CS DPAC KPAC CM],
              },
            ],
            color: nil,
          },
          {
            sym: 'DRGR',
            name: 'Denver & Rio Grande Railway Silverton Branch',
            value: 120,
            revenue: 25,
            desc: 'The owner receives the Presidency of Durango and Silverton Narrow Gauge, which '\
                  'floats immediately. Closes when the DSNG runs a train or on purchase of “5” train. '\
                  'Cannot be purchased by a Corporation. Does not count towards net worth.',
            abilities: [{ type: 'shares', shares: 'DSNG_0' },
                        { type: 'close', when: 'run_train', corporation: 'DSNG' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'KPAC',
            name: 'Kansas Pacific Railway',
            group: 'III',
            float_percent: 40,
            always_market_price: true,
            logo: '18_co/KPAC',
            simple_logo: '18_co/KPAC.alt',
            tokens: [0, 40, 100],
            coordinates: 'E27',
            color: '#7b352a',
            abilities: [{ type: 'description', description: 'Par Group - C' }],
            reservation_color: nil,
          },
          {
            sym: 'CM',
            name: 'Colorado Midland Railway',
            group: 'III',
            float_percent: 40,
            always_market_price: true,
            logo: '18_co/CM',
            simple_logo: '18_co/CM.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G17',
            color: '#a2dced',
            text_color: 'black',
            abilities: [{ type: 'description', description: 'Par Group - C' }],
            reservation_color: nil,
          },
          {
            sym: 'CS',
            name: 'Colorado & Southern Railway',
            group: 'III',
            float_percent: 40,
            always_market_price: true,
            logo: '18_co/CS',
            simple_logo: '18_co/CS.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'K17',
            color: :'#232b2b',
            abilities: [{ type: 'description', description: 'Par Group - C' }],
            reservation_color: nil,
          },
          {
            sym: 'DPAC',
            name: 'Denver Pacific Railway',
            group: 'III',
            float_percent: 40,
            always_market_price: true,
            logo: '18_co/DPAC',
            simple_logo: '18_co/DPAC.alt',
            tokens: [0, 40],
            city: 2,
            coordinates: 'E15',
            color: :'#82009c',
            abilities: [{ type: 'description', description: 'Par Group - C' }],
            reservation_color: nil,
          },
          {
            sym: 'DSL',
            name: 'Denver & Salt Lake Railroad',
            group: 'III',
            float_percent: 40,
            always_market_price: true,
            logo: '18_co/DSL',
            simple_logo: '18_co/DSL.alt',
            tokens: [0, 40],
            city: 1,
            coordinates: 'E15',
            color: '#237333',
            abilities: [{ type: 'description', description: 'Par Group - C' }],
            reservation_color: nil,
          },
          {
            sym: 'DRG',
            name: 'Denver & Rio Grande Railroad',
            group: 'II',
            float_percent: 50,
            always_market_price: true,
            logo: '18_co/DRG',
            simple_logo: '18_co/DRG.alt',
            tokens: [0, 40, 80, 100, 100, 100],
            city: 0,
            coordinates: 'E15',
            color: :gold,
            text_color: 'black',
            abilities: [{ type: 'description', description: 'Par Group - B' }],
            reservation_color: nil,
          },
          {
            sym: 'ATSF',
            name: 'Atchison, Topeka & Santa Fe',
            group: 'II',
            float_percent: 50,
            always_market_price: true,
            logo: '18_co/ATSF',
            simple_logo: '18_co/ATSF.alt',
            tokens: [0, 40, 80, 100, 100, 100],
            coordinates: 'J26',
            color: :'#000e4b',
            abilities: [{ type: 'description', description: 'Par Group - B' }],
            reservation_color: nil,
          },
          {
            sym: 'CBQ',
            name: 'Chicago, Burlington & Quincy',
            group: 'I',
            float_percent: 60,
            always_market_price: true,
            logo: '18_co/CBQ',
            simple_logo: '18_co/CBQ.alt',
            tokens: [0, 40, 80, 100, 100, 100, 100],
            coordinates: 'B26',
            color: '#f48221',
            text_color: 'black',
            abilities: [{ type: 'description', description: 'Par Group - A' }],
            reservation_color: nil,
          },
          {
            sym: 'ROCK',
            name: 'Chicago, Rock Island & Pacific',
            group: 'I',
            float_percent: 60,
            always_market_price: true,
            logo: '18_co/ROCK',
            simple_logo: '18_co/ROCK.alt',
            tokens: [0, 40, 80, 100, 100, 100, 100, 100],
            coordinates: 'G27',
            color: '#d81e3e',
            abilities: [{ type: 'description', description: 'Par Group - A' }],
            reservation_color: nil,
          },
          {
            sym: 'UP',
            name: 'Union Pacific',
            group: 'I',
            float_percent: 60,
            always_market_price: true,
            logo: '18_co/UP',
            simple_logo: '18_co/UP.alt',
            tokens: [0, 40, 80, 100, 100, 100, 100, 100],
            coordinates: 'A17',
            color: :'#ffffeb',
            text_color: 'black',
            abilities: [{ type: 'description', description: 'Par Group - A' }],
            reservation_color: nil,
          },
          {
            sym: 'DSNG',
            name: 'Durango & Silverton Narrow Gauge',
            group: 'X',
            float_percent: 20,
            always_market_price: true,
            logo: '18_co/DSNG',
            simple_logo: '18_co/DSNG.alt',
            shares: [20, 10, 20, 20, 10, 10, 10],
            tokens: [0, 40],
            coordinates: 'K5',
            color: :'#db00c0',
            abilities: [
              {
                type: 'description',
                description: 'Pars @ $75(C) via DRG Silverton Branch',
              },
              {
                type: 'base',
                description: 'Shares: 2P/2/2/1/1/1/1',
              },
            ],
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B2
               B4
               B6
               B16
               B18
               B20
               B24
               C3
               C5
               C19
               C23
               C25
               D2
               D16
               D18
               D20
               D22
               E3
               E17
               E19
               E21
               E23
               E25
               F2
               F18
               F22
               G13
               G19
               G21
               G23
               G25
               H18
               H20
               H22
               H24
               I5
               I19
               I25
               J2
               J16
               J18
               J20
               J22
               J24
               K3
               K19
               K21
               K23
               K25] => '',
            %w[C15 K17] => 'city=revenue:0',
            ['G17'] =>
                   'city=revenue:10;path=a:5,b:_0;path=a:_0,b:0;label=C;border=edge:1,type:mountain,cost:40;',
            ['E15'] =>
                   'city=revenue:10;city=revenue:0,loc:7;city=revenue:10;path=a:5,b:_0;path=a:3,b:_2;'\
                   'label=D;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;',
            %w[B22 C7 D4 D24 F20 F24 I21 I23] => 'town=revenue:0',
            %w[C17 C21] =>
                   'town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade',
            %w[B14 K11] => 'border=edge:1,type:mountain,cost:40;',
            ['I3'] => 'border=edge:3,type:mountain,cost:40;',
            ['J12'] => 'border=edge:4,type:mountain,cost:40;',
            ['F4'] => 'border=edge:5,type:mountain,cost:40;',
            ['F16'] =>
                   'border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;',
            ['H16'] =>
                   'border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;',
            ['I11'] =>
                   'border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;',
            ['G5'] =>
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;',
            ['H2'] =>
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;',
            ['D10'] =>
                   'border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;',
            ['E5'] => 'town=revenue:0;border=edge:3,type:mountain,cost:40;',
            ['B10'] =>
                   'town=revenue:0;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;',
            ['F12'] =>
                   'town=revenue:0;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;',
            ['K13'] =>
                   'town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade;'\
                   'border=edge:4,type:mountain,cost:40;',
            ['H8'] =>
                   'town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['D14'] =>
                   'town=revenue:0;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:0,type:mountain,cost:40'\
                   ';border=edge:1,type:mountain,cost:40;',
            ['F8'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['H12'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:1,type:mountain,cost:40;',
            ['E11'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['J6'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['H14'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/upgrade,sticky:1,name:upgrade;'\
                   'border=edge:0,type:mountain,cost:40;',
            ['E7'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/upgrade,sticky:1,name:upgrade;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;',
            ['C9'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/upgrade,sticky:1,name:upgrade;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['G3'] => 'city=revenue:0;border=edge:0,type:mountain,cost:40;',
            ['I17'] => 'city=revenue:0;border=edge:1,type:mountain,cost:40;',
            ['H6'] =>
                   'city=revenue:0;border=edge:3,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            %w[B8 B12] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:4,type:mountain,cost:40;',
            %w[C11 J4] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:40;',
            ['H4'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:1,type:mountain,cost:40;',
            ['D6'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['K7'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;',
            ['F14'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;',
            ['D8'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['J14'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['K9'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;',
            ['D12'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['I13'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['H10'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['I15'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;',
            ['G9'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;',
            ['E9'] =>
                   'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['F6'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['K15'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;',
            ['I7'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['G15'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['E13'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;',
            ['F10'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:4,type:mountain,cost:40;',
            ['J8'] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            %w[G7 I9] =>
                   'upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;'\
                   'border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;'\
                   'border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;'\
                   'border=edge:5,type:mountain,cost:40;',
            ['G11'] =>
                   'icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:1,type:mountain,cost:40;',
            ['J10'] =>
                   'icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;'\
                   'border=edge:2,type:mountain,cost:40;',
          },
          red: {
            ['A11'] => 'offboard=revenue:yellow_50|brown_20;path=a:0,b:_0,terminal:1;',
            ['A17'] =>
            'city=revenue:yellow_40|brown_50;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;',
            ['B26'] =>
            'city=revenue:yellow_50|brown_30;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;',
            ['E1'] =>
            'offboard=revenue:yellow_50|brown_70;path=a:3,b:_0;path=a:5,b:_0,terminal:1;',
            ['E27'] => 'city=revenue:yellow_50|brown_30;path=a:0,b:_0,terminal:1;',
            ['G27'] => 'city=revenue:yellow_50|brown_30;path=a:2,b:_0,terminal:1;',
            ['J26'] =>
            'city=revenue:yellow_40|brown_20;path=a:0,b:_0;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['L2'] => 'offboard=revenue:yellow_20|brown_30;path=a:4,b:_0,terminal:1;',
            %w[L14 L20] =>
            'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0,terminal:1;',
          },
          gray: {
            ['C13'] => '',
            ['F26'] => 'path=a:0,b:5;path=a:1,b:5;path=a:1,b:3;path=a:2,b:3',
            ['L4'] => 'path=a:2,b:1;path=a:3,b:1;',
            %w[L12 L18] => 'path=a:2,b:4;path=a:3,b:4;',
          },
          yellow: {
            ['K5'] =>
                        'city=revenue:0;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;',
          },
        }.freeze

        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        SELL_BUY_ORDER = :sell_buy
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = false

        CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY = true
        CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
        VARIABLE_FLOAT_PERCENTAGES = true
        DISCARDED_TRAIN_DISCOUNT = 50
        MAX_SHARE_VALUE = 485

        # Two tiles can be laid, only one upgrade
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze
        REDUCED_TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        # First 3 are Denver, Second 3 are CO Springs
        TILES_FIXED_ROTATION = %w[co1 co2 co3 co5 co6 co7].freeze
        GREEN_TOWN_TILES = %w[co8 co9 co10].freeze
        GREEN_CITY_TILES = %w[14 15].freeze
        BROWN_CITY_TILES = %w[co4 63].freeze
        MAX_STATION_TILES = %w[14 15 co1 co2 co3 co4 co7 63].freeze

        STOCKMARKET_COLORS = {
          par: :blue,
          par_1: :purple,
          par_2: :yellow,
          acquisition: :red,
        }.freeze

        MARKET_TEXT = {
          par: 'Par: 40% - C',
          par_1: 'Par: 50% - B/C',
          par_2: 'Par: 60% - A/B/C',
          acquisition: 'Acquisition: Corporation assets will be auctioned if entering Stock Round',
        }.freeze

        PAR_FLOAT_GROUPS = {
          20 => %w[X],
          40 => %w[C B A],
          50 => %w[B A],
          60 => %w[A],
        }.freeze

        PAR_PRICE_GROUPS = {
          'X' => [75],
          'C' => [40, 50, 60, 75],
          'B' => [80, 90, 100, 110],
          'A' => [120, 135, 145, 160],
        }.freeze

        PAR_GROUP_FLOATS = {
          'X' => 20,
          'C' => 40,
          'B' => 50,
          'A' => 60,
        }.freeze

        EAST_HEXES = %w[B26 J26 E27 G27].freeze

        BASE_MINE_VALUE = 10

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
            'remove_mines' => ['Mines Close', 'Mine tokens removed from board and corporations'],
            'presidents_choice' => [
              'President\'s Choice Triggered',
              'President\'s choice round will occur at the beginning of the next Stock Round',
            ],
            'unreserve_home_stations' => [
              'Remove Reservations',
              'Home stations are no longer reserved for unparred corporations.',
            ]
          ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'reduced_tile_lay' => ['Reduced Tile Lay', 'Corporations place only one tile per OR.'],
          'corporate_shares_open' => [
            'Corporate Shares Open',
            'All corporate shares are available for any player to purchase.',
          ],
          'closable_corporations' => [
            'Closable Corporations',
            'Unparred corporations are removed if there is no station available to place their home token. '\
            'Parring a corporation restores its home token reservation.',
          ]
        ).freeze

        include CompanyPrice50To150Percent

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def dsng
          @dsng ||= corporation_by_id('DSNG')
        end

        def drgr
          @drgr ||= company_by_id('DRGR')
        end

        def imc
          @imc ||= company_by_id('IMC')
        end

        def setup
          setup_company_price_50_to_150_percent
          setup_corporations
          @presidents_choice = nil
        end

        def next_sr_player_order
          return :first_to_pass if @optional_rules&.include?(:priority_order_pass)

          super
        end

        def setup_corporations
          # The DSNG comes with a 2P train
          train = @depot.upcoming[0]
          train.buyable = false
          buy_train(dsng, train, :free)
        end

        def init_share_pool
          G18CO::SharePool.new(self)
        end

        def init_stock_market
          G18CO::StockMarket.new(
            self.class::MARKET,
            self.class::CERT_LIMIT_TYPES,
            multiple_buy_types: self.class::MULTIPLE_BUY_TYPES
          )
        end

        def mines_count(entity)
          Array(abilities(entity, :mine_income)).sum(&:count_per_or)
        end

        def mine_multiplier(entity)
          imc.owner == entity ? 2 : 1
        end

        def mine_value(entity)
          BASE_MINE_VALUE * mine_multiplier(entity)
        end

        def mines_total(entity)
          mine_value(entity) * mines_count(entity)
        end

        def mines_remove(entity)
          abilities(entity, :mine_income) do |ability|
            entity.remove_ability(ability)
          end
        end

        def mines_add(entity, count)
          mine_create(entity, mines_count(entity) + count)
        end

        def mine_add(entity)
          mines_add(entity, 1)
        end

        def mine_update_text(entity)
          mine_create(entity, mines_count(entity))
        end

        def mine_create(entity, count)
          return unless count.positive?

          mines_remove(entity)
          total = count * mine_value(entity)
          entity.add_ability(Engine::Ability::Base.new(
                type: :mine_income,
                description: "#{count} mine#{count > 1 ? 's' : ''} x
                            #{format_currency(mine_value(entity))} =
                            #{format_currency(total)} to Treasury",
                count_per_or: count,
                remove: '6'
              ))
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
          Engine::Step::Bankrupt,
          G18CO::Step::Takeover,
          G18CO::Step::DiscardTrain,
          G18CO::Step::HomeToken,
          G18CO::Step::ReturnToken,
          Engine::Step::BuyCompany,
          G18CO::Step::RedeemShares,
          G18CO::Step::CorporateBuyShares,
          G18CO::Step::SpecialTrack,
          G18CO::Step::Track,
          Engine::Step::Token,
          Engine::Step::Route,
          G18CO::Step::Dividend,
          G18CO::Step::BuyTrain,
          Engine::Step::CorporateSellShares,
          G18CO::Step::IssueShares,
          [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          G18CO::Round::Stock.new(self, [
          G18CO::Step::Takeover,
          G18CO::Step::DiscardTrain,
          G18CO::Step::BuySellParShares,
          ])
        end

        def new_presidents_choice_round
          @log << '-- President\'s Choice --'
          G18CO::Round::PresidentsChoice.new(self, [
            G18CO::Step::PresidentsChoice,
          ])
        end

        def new_acquisition_round
          @log << '-- Acquisition Round --'
          G18CO::Round::Acquisition.new(self, [
            G18CO::Step::AcquisitionTakeover,
            G18CO::Step::AcquisitionAuction,
          ])
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18CO::Step::CompanyPendingPar,
            G18CO::Step::MovingBidAuction,
          ])
        end

        def next_round!
          @round =
            case @round
            when G18CO::Round::Acquisition
              new_stock_round
            when G18CO::Round::PresidentsChoice
              if acquirable_corporations.any?
                new_acquisition_round
              else
                new_stock_round
              end
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if @presidents_choice == :triggered
                  new_presidents_choice_round
                elsif acquirable_corporations.any?
                  new_acquisition_round
                else
                  new_stock_round
                end
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def acquirable_corporations
          corporations.select { |c| c&.share_price&.acquisition? }
        end

        def action_processed(action)
          super

          case action
          when Action::BuyCompany
            mine_update_text(action.entity) if action.company == imc && action.entity.corporation?
          when Action::PlaceToken
            remove_corporations_if_no_home(action.city) if @phase.status.include?('closable_corporations')
          when Action::Par
            rereserve_home_station(action.corporation) if @phase.status.include?('closable_corporations')
            remove_par_group_ability(action.corporation)
          end
        end

        def remove_par_group_ability(corporation)
          par_group = abilities(corporation, :description)

          corporation.remove_ability(par_group) if par_group
        end

        def remove_corporations_if_no_home(city)
          tile = city.tile

          return unless tile_has_max_stations(tile)

          @corporations.dup.each do |corp|
            next if corp.ipoed
            next unless corp.coordinates == tile.hex.name

            next if city.tokenable?(corp, free: true)

            log << "#{corp.name} closes as its home station can never be available"
            close_corporation(corp, quiet: true)
          end
        end

        def tile_has_max_stations(tile)
          tile.color == :red || MAX_STATION_TILES.include?(tile.name)
        end

        def rereserve_home_station(corporation)
          return unless corporation.coordinates

          tile = hex_by_id(corporation.coordinates).tile
          city = tile.cities[corporation.city || 0] || tile.cities[0]
          slot = city.get_slot(corporation)
          tile.add_reservation!(corporation, slot ? corporation.city : nil, slot)
          log << "#{corporation.name} reserves station on #{tile.hex.name}"\
                 "#{slot ? '' : " which must be upgraded to place the #{corporation.name} home station"}"
        end

        def check_distance(route, visits)
          super

          distance = route.train.distance

          return if distance.is_a?(Numeric)

          cities_allowed = distance.find { |d| d['nodes'].include?('city') }['pay']
          cities_visited = visits.count { |v| v.city? || v.offboard? }
          start_at_town = visits.first.town? ? 1 : 0
          end_at_town = visits.last.town? ? 1 : 0

          return unless cities_allowed < (cities_visited + start_at_town + end_at_town)

          raise GameError, 'Towns on route ends are counted against city limit.'
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += east_west_bonus(stops)[:revenue]

          revenue
        end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| EAST_HEXES.include?(stop.hex.name) }
          west = stops.find { |stop| stop.hex.name == 'E1' }

          if east && west
            bonus[:revenue] = 100
            bonus[:description] = 'E/W'
          end

          bonus
        end

        def revenue_str(route)
          str = route.stops.map { |s| s.hex.name }.join('-')

          bonus = east_west_bonus(route.stops)[:description]
          str += " + #{bonus}" if bonus

          str
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if special && from.hex.tile.color == :yellow && GREEN_CITY_TILES.include?(to.name)

          # Green towns can't be upgraded to brown cities unless the hex has the upgrade icon
          if GREEN_TOWN_TILES.include?(from.hex.tile.name)
            return BROWN_CITY_TILES.include?(to.name) if from.hex.tile.icons.any? { |icon| icon.name == 'upgrade' }

            return false
          end

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          if GREEN_TOWN_TILES.include?(tile.name)
            brown_cityco4 = @tiles.find { |t| t.name == 'co4' }
            brown_city63 = @tiles.find { |t| t.name == '63' }
            upgrades |= [brown_cityco4] if brown_cityco4
            upgrades |= [brown_city63] if brown_city63
          end

          upgrades
        end

        def event_remove_mines!
          @log << '-- Event: Mines close --'

          hexes.each do |hex|
            hex.tile.icons.reject! { |icon| icon.name == 'mine' }
          end

          @corporations.each do |corporation|
            mines_remove(corporation)
          end
        end

        def event_unreserve_home_stations!
          @log << '-- Event: Home station reservations removed --'

          @corporations.each do |corporation|
            next if corporation.ipoed

            tile = hex_by_id(corporation.coordinates).tile
            city = tile.cities[corporation.city || 0]
            city.remove_reservation!(corporation)
          end
        end

        def tile_lays(_entity)
          return REDUCED_TILE_LAYS if @phase.status.include?('reduced_tile_lay')

          super
        end

        def event_presidents_choice!
          return if @presidents_choice

          @log << '-- Event: President\'s Choice --'
          @log << 'President\'s choice round will occur at the beginning of the next Stock Round'

          @presidents_choice = :triggered
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price
          was_president = corporation.president?(bundle.owner)
          was_issued = bundle.owner == bundle.corporation

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          share_drop_num = bundle.num_shares - (swap ? 1 : 0)

          return if !(was_president || was_issued) && share_drop_num == 1

          share_drop_num.times { @stock_market.move_down(corporation) }

          log_share_price(corporation, old_price) if self.class::SELL_MOVEMENT != :none
        end

        def shares_for_presidency_swap(shares, num_shares)
          return [] if shares.empty?
          return [] unless num_shares
          return shares if shares.one?

          percent = num_shares * shares.first.corporation.share_percent
          matching_bundles = (1..shares.size).flat_map do |n|
            shares.combination(n).to_a.select { |b| b.sum(&:percent) == percent }
          end

          # we want the bundle with the most shares, as higher percent in fewer shares in more valuable
          matching_bundles.max_by(&:size)
        end

        def legal_tile_rotation?(_entity, _hex, tile)
          return false if TILES_FIXED_ROTATION.include?(tile.name) && tile.rotation != 0

          super
        end

        # Reduce the list of par prices available to just those corresponding to the corporation group
        def par_prices(corporation)
          par_nodes = @stock_market.par_prices
          available_par_groups = PAR_FLOAT_GROUPS[corporation.float_percent]
          available_par_prices = PAR_PRICE_GROUPS.values_at(*available_par_groups).flatten
          par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
        end

        def total_shares_to_float(corporation, price)
          find_par_float_percent(corporation, price) / corporation.share_percent
        end

        def find_par_float_percent(corporation, price)
          PAR_PRICE_GROUPS.each do |key, prices|
            next unless PAR_FLOAT_GROUPS[corporation.float_percent].include?(key)
            next unless prices.include?(price)

            return PAR_GROUP_FLOATS[key]
          end

          corporation.float_percent
        end

        # Higher valued par groups require more shares to float. The float percent is adjusted upon parring.
        def par_change_float_percent(corporation)
          new_par = find_par_float_percent(corporation, corporation.par_price.price)
          return if corporation.float_percent == new_par

          corporation.float_percent = new_par
          @log << "#{corporation.name} now requires #{corporation.float_percent}% to float"
        end

        def emergency_issuable_cash(corporation)
          emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
        end

        def emergency_issuable_bundles(entity)
          eligible, remaining = issuable_shares(entity)
            .partition { |bundle| bundle.price + entity.cash < @depot.min_depot_price }
          eligible.concat(remaining.take(1))
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless entity.num_ipo_shares

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
            .map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def sellable_bundles(player, corporation)
          bundles = super
          return bundles unless @optional_rules&.include?(:pay_per_trash)
          return bundles if corporation.operated?

          bundles.map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
        end

        # we can use this same logic for issuing multiple shares
        def reduced_bundle_price_for_market_drop(bundle)
          return bundle if bundle.num_shares == 1

          new_price = (0..bundle.num_shares - 1).sum do |max_drops|
            @stock_market.find_share_price(bundle.corporation, (1..max_drops).map { |_| :down }).price
          end

          bundle.share_price = new_price / bundle.num_shares

          bundle
        end

        def all_bundles_for_corporation(share_holder, corporation, shares: nil)
          return [] unless corporation.ipoed
          return super unless corporation == dsng

          shares = (shares || share_holder.shares_of(corporation)).sort_by { |h| [h.president ? 1 : 0, h.price] }

          return [] if shares.empty?

          bundles = (1..shares.size).flat_map do |n|
            shares.combination(n).to_a.map { |ss| Engine::ShareBundle.new(ss) }
          end

          bundles.sort_by { |b| [b.presidents_share ? 1 : 0, b.percent, -b.shares.size] }.uniq(&:percent)
        end

        def purchasable_companies(entity = nil)
          @companies.select do |company|
            !company.closed? &&
              (company.owner&.player? || company.owner.nil?) &&
              (entity.nil? || entity != company.owner) &&
              !abilities(company, :no_buy)
          end
        end

        def unowned_purchasable_companies(_entity)
          @companies.select { |company| !company.closed? && company.owner.nil? }
        end

        def entity_can_use_company?(entity, company)
          entity.corporation? && entity == company.owner
        end

        def player_value(player)
          value = player.value
          return value unless drgr&.owner == player

          value - drgr.value
        end

        def train_limit(entity)
          super + Array(abilities(entity, :train_limit)).sum(&:increase)
        end
      end
    end
  end
end
