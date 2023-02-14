# frozen_string_literal: true

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

        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 2,
          '15' => 4,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 2,
          '22' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 2,
          '58' => 4,
          '63' => 3,
          '70' => 2,
          '87' => 2,
          '88' => 2,
          '120' => 1,
          '122' => 1,
          '124' => 1,
          '201' => 3,
          '202' => 3,
          '204' => 2,
          '207' => 5,
          '208' => 2,
          '611' => 3,
          '619' => 2,
          '621' => 2,
          '622' => 2,
          '623' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '637' => 1,
          '639' => 1,
          '801' => 2,
          '911' => 3,
          'X1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;path=a:_2,b:5;label=M',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:5;path=a:2,b:_2;'\
                      'path=a:_2,b:4;label=M',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:4;path=a:1,b:_1;path=a:_1,b:2;path=a:3,b:_2;'\
                      'path=a:_2,b:5;label=M',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:3;'\
                      'path=a:1,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:5;label=M',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;city=revenue:70;path=a:0,b:_1;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;city=revenue:70;path=a:0,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=M',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;city=revenue:70;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_1;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_0;label=M',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
        }.freeze

        LOCATION_NAMES = {
          'D2' => 'Timmins ($80 if includes T/M/Q)',
          'D8' => 'Sudbury',
          'F8' => 'North Bay',
          'E13' => 'Barrie',
          'E15' => 'Guelph',
          'E17' => 'Hamilton',
          'D16' => 'Berlin',
          'C17' => 'London',
          'G15' => 'Peterborough',
          'I15' => 'Kingston',
          'J12' => 'Ottawa',
          'M9' => 'Trois-Rivières',
          'O7' => 'Quebec',
          'N12' => 'Sherbrooke',
          'C15' => 'Goderich',
          'B18' => 'Sarnia',
          'H14' => 'Belleville',
          'H10' => 'Pembroke',
          'K13' => 'Cornwall',
          'L10' => 'St. Jerome',
          'M13' => 'Granby',
          'L12' => 'Montreal',
          'F16' => 'Toronto',
          'A7' => 'Sault Ste. Marie',
          'F18' => 'Buffalo',
          'M15' => 'New England',
          'O13' => 'Maine',
          'P8' => 'Maritime Provinces',
          'A19' => 'Detroit',
        }.freeze

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

        COMPANIES = [
          {
            name: 'rules until start of phase 3',
            sym: '3',
            value: 3,
            revenue: 0,
            desc: 'Hidden corporation',
            abilities: [{ type: 'blocks_hexes', hexes: ['M13'] }],
            color: nil,
          },
          {
            name: 'Champlain & St. Lawrence',
            sym: 'C&SL',
            value: 30,
            revenue: 10,
            discount: 10,
            desc: 'No special abilities.',
            color: nil,
          },
          {
            name: 'Niagara Falls Bridge',
            sym: 'NFB',
            value: 45,
            revenue: 15,
            discount: 15,
            desc: 'When owned by a corporation, they gain $10 extra revenue for '\
                  'each of their routes that include Buffalo',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['F18'],
                amount: 10,
              },
            ],
            color: nil,
          },
          {
            name: 'Montreal Bridge',
            sym: 'MB',
            value: 60,
            revenue: 20,
            discount: 20,
            desc: 'When owned by a corporation, they gain $10 extra revenue for '\
                  'each of their routes that include Montreal',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['L12'],
                amount: 10,
              },
            ],
            color: nil,
          },
          {
            name: 'Quebec Bridge',
            sym: 'QB',
            value: 75,
            revenue: 25,
            discount: 25,
            desc: 'When owned by a corporation, they gain $10 extra revenue for '\
                  'each of their routes that include Quebec',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['O7'],
                amount: 10,
              },
            ],
            color: nil,
          },
          {
            name: 'St. Clair Tunnel',
            sym: 'SCT',
            value: 90,
            revenue: 30,
            discount: 30,
            desc: 'When owned by a corporation, they gain $10 extra revenue for '\
                  'each of their routes that include Detroit',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: %w[A19 A17],
                amount: 10,
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'CNR',
            name: 'Canadian Northern Railway',
            logo: '1867/CNR',
            simple_logo: '1867/CNR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#3c7b5c',
            reservation_color: nil,
          },
          {
            sym: 'CPR',
            name: 'Canadian Pacific Railway',
            logo: '1867/CPR',
            simple_logo: '1867/CPR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#ef4223',
            reservation_color: nil,
          },
          {
            sym: 'C&O',
            name: 'Chesapeake and Ohio Railway',
            logo: '1867/CO',
            simple_logo: '1867/CO.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            sym: 'GTR',
            name: 'Grand Trunk Railway',
            logo: '1867/GTR',
            simple_logo: '1867/GTR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#d75500',
            reservation_color: nil,
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway',
            logo: '1867/GWR',
            simple_logo: '1867/GWR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: :darkBlue,
            reservation_color: nil,
          },
          {
            sym: 'ICR',
            name: 'Intercolonial Railway',
            logo: '1867/ICR',
            simple_logo: '1867/ICR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            sym: 'NTR',
            name: 'National Transcontinental Railway',
            logo: '1867/NTR',
            simple_logo: '1867/NTR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#3c7b5c',
            reservation_color: nil,
          },
          {
            sym: 'NYC',
            name: 'New York Central Railroad',
            logo: '1867/NYC',
            simple_logo: '1867/NYC.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#772282',
            reservation_color: nil,
          },
          {
            sym: 'BBG',
            name: 'Buffalo, Brantford, and Goderich',
            logo: '1867/BBG',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            type: 'minor',
            shares: [100],
            max_ownership_percent: 100,
            color: '#7c7b8c',
            reservation_color: nil,
          },
          {
            sym: 'BO',
            name: 'Brockville and Ottawa',
            logo: '1867/BO',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#009595',
            reservation_color: nil,
          },
          {
            sym: 'CS',
            name: 'Canada Southern',
            logo: '1867/CS',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#4cb5d2',
            reservation_color: nil,
          },
          {
            sym: 'CV',
            name: 'Credit Valley Railway',
            logo: '1867/CV',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#0097df',
            reservation_color: nil,
          },
          {
            sym: 'KP',
            name: 'Kingston and Pembroke',
            logo: '1867/KP',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#0097df',
            reservation_color: nil,
          },
          {
            sym: 'LPS',
            name: 'London and Port Stanley',
            logo: '1867/LPS',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#7c7b8c',
            reservation_color: nil,
          },
          {
            sym: 'OP',
            name: 'Ottawa and Prescott',
            logo: '1867/OP',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#d30869',
            reservation_color: nil,
          },
          {
            sym: 'SLA',
            name: 'St. Lawrence and Atlantic',
            logo: '1867/SLA',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#7c7b8c',
            reservation_color: nil,
          },
          {
            sym: 'TGB',
            name: 'Toronto, Grey, and Bruce',
            logo: '1867/TGB',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: :darkBlue,
            reservation_color: nil,
          },
          {
            sym: 'TN',
            name: 'Toronto and Nipissing',
            logo: '1867/TN',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            sym: 'AE',
            name: 'Algoma Eastern Railway',
            logo: '1867/AE',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#d75500',
            reservation_color: nil,
          },
          {
            sym: 'CA',
            name: 'Canada Atlantic Railway',
            logo: '1867/CA',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#772282',
            reservation_color: nil,
          },
          {
            sym: 'NO',
            name: 'New York and Ottawa',
            logo: '1867/NO',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#d75500',
            reservation_color: nil,
          },
          {
            sym: 'PM',
            name: 'Pere Marquette Railway',
            logo: '1867/PM',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#4cb5d2',
            reservation_color: nil,
          },
          {
            sym: 'QLS',
            name: 'Quebec and Lake St. John',
            logo: '1867/QLS',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            sym: 'THB',
            name: 'Toronto, Hamilton and Buffalo',
            logo: '1867/THB',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            color: '#d75500',
            reservation_color: nil,
          },
          {
            sym: 'CN',
            name: 'Canadian National',
            logo: '1867/CN',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0],
            shares: [100],
            hide_shares: true,
            type: 'national',
            color: '#ef4223',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B6 B8 C5 C7 C19 D4 D6 D14 E3 E5 E7 E9 F2 F4 F6 F10 F12 F14 G3 G5
               G7 G9 G11 G13 H4 H6 H8 H12 I5 I7 I9 I11 I13 J6 J8 J10 J14 K5 K7 K9
               L6 L8 M5 M7 N6 O11] => '',
            ['D18'] => 'border=edge:5,type:impassable',
            ['C9'] => 'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['D10'] => 'border=edge:2,type:impassable;border=edge:1,type:impassable;'\
                       'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['E11'] => 'border=edge:2,type:impassable;border=edge:1,type:impassable',
            ['C11'] => 'border=edge:0,type:impassable;border=edge:3,type:impassable;'\
                       'border=edge:4,type:impassable',
            ['D12'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['C13'] => 'border=edge:3,type:impassable',
            ['K11'] => 'upgrade=cost:20,terrain:water',
            ['N8'] => 'border=edge:0,type:water,cost:80;border=edge:5,type:water,cost:80',
            %w[N10 M11] =>
                   'border=edge:2,type:water,cost:80;border=edge:3,type:water,cost:80',
            ['O9'] => 'border=edge:2,type:water,cost:80',
            ['M9'] =>
                   'city=revenue:0;border=edge:5,type:water,cost:80;border=edge:0,type:water,cost:80',
            %w[D8 F8 E13 E15 C17 I15 N12] => 'city=revenue:0',
            ['G15'] => 'city=revenue:0;stub=edge:1',
            %w[E17 D16 O7] => 'city=revenue:0;label=Y',
            ['J12'] => 'city=revenue:0;label=Y;future_label=label:O,color:gray;upgrade=cost:20,terrain:water',
            ['L10'] => 'town=revenue:0;border=edge:5,type:water,cost:80;stub=edge:0',
            ['H14'] => 'town=revenue:0;border=edge:0,type:impassable',
            %w[C15 B18 H10 M13] => 'town=revenue:0',
            ['K13'] => 'town=revenue:0;stub=edge:4',
          },
          gray: {
            ['D2'] => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;border=edge:1;border=edge:4',
            ['C3'] => 'path=a:0,b:4;border=edge:4',
            ['E1'] => 'path=a:1,b:5;border=edge:1',
            ['B16'] => 'path=a:0,b:5',
            ['L14'] => 'path=a:2,b:3',
          },
          yellow: {
            ['L12'] => 'city=revenue:40;city=revenue:40;city=revenue:40,loc:5;path=a:1,b:_0;'\
                       'path=a:3,b:_1;label=M;upgrade=cost:20,terrain:water',
            ['F16'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=T',
          },
          red: {
            ['A7'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:4,b:_0;path=a:5,b:_0',
            ['F18'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0',
            ['M15'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:3,b:_0',
            ['O13'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:3,b:_0',
            ['P8'] => 'offboard=revenue:yellow_30|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:1,b:_0',
            ['A17'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Detroit;'\
                       'path=a:5,b:_0;border=edge:0',
            ['A19'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Detroit;'\
                       'path=a:4,b:_0;border=edge:3',
          },
          blue: {
            ['E19'] => 'offboard=revenue:10;path=a:3,b:_0;border=edge:2,type:impassable',
            ['H16'] => 'offboard=revenue:10;path=a:2,b:_0;path=a:4,b:_0;border=edge:3,type:impassable',
          },
        }.freeze

        LAYOUT = :flat

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
          open_locations = hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city.tokens.none? }
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

        def add_neutral_tokens(hexes)
          @green_tokens = []
          logo = '/logos/1867/neutral.svg'
          hexes.each do |hex|
            case hex.id
            when 'D2'
              token = Token.new(national, price: 0, logo: logo, simple_logo: logo, type: :neutral)
              hex.tile.cities.first.exchange_token(token)
              @green_tokens << token
            when 'L12'
              token = Token.new(national, price: 0, logo: logo, simple_logo: logo, type: :neutral)
              hex.tile.cities.last.exchange_token(token)
              @green_tokens << token
            when 'F16'
              hex.tile.cities.first.exchange_token(national.tokens.first)
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
          @national = national
          @national.ipoed = true
          @national.shares.clear
          @national.shares_by_corporation[@national].clear

          @national_reservations = self.class::NATIONAL_RESERVATIONS.dup
          @corporations.delete(@national)

          # Move green and majors out of the normal list
          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end
          @show_majors = false
        end

        def national
          @national ||= @corporations.find { |c| c.type == :national }
        end

        def init_hexes(_companies, corporations)
          hexes = super
          add_neutral_tokens(hexes)
          hexes
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
