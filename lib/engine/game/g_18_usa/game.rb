# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'

module Engine
  module Game
    module G18USA
      class Game < G1817::Game
        include_meta(G18USA::Meta)

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 32, 3 => 21, 4 => 16, 5 => 16, 6 => 13, 7 => 11 }.freeze

        STARTING_CASH = { 2 => 630, 3 => 420, 4 => 315, 5 => 300, 6 => 250, 7 => 225 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '6' => 'unlimited',
          '5' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '57' => 'unlimited',
          '60' => 'unlimited',
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
          '7coal' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:1;label=⛏️',
          },
          '8coal' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:2;label=⛏️',
          },
          '9coal' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:3;label=⛏️',
          },
          '544coal' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '545coal' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=⛏️',
          },
          '546coal' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '80coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=⛏️',
          },
          '81coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '82coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;label=⛏️',
          },
          '83coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=⛏️',
          },
          '60coal' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:10,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=⛏️',
          },
          'X17coal' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:10,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '7iron10' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:1;label=⚒️',
          },
          '8iron10' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:2;label=⚒️',
          },
          '9iron10' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:3;label=⚒️',
          },
          '7iron20' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'offboard=revenue:20,hide:1;path=a:0,b:1;label=⚒️',
          },
          '8iron20' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'offboard=revenue:20,hide:1;path=a:0,b:2;label=⚒️',
          },
          '9iron20' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'offboard=revenue:20,hide:1;path=a:0,b:3;label=⚒️',
          },
          '7oil' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:1;label=🛢️',
          },
          '8oil' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:2;label=🛢️',
          },
          '9oil' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:3;label=🛢️',
          },
          '544oil' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=🛢️',
          },
          '545oil' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=🛢️',
          },
          '546oil' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:20,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=🛢️',
          },
          '80oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=🛢️',
          },
          '81oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=🛢️',
          },
          '82oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;label=🛢️',
          },
          '83oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=🛢️',
          },
          '60oil' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:20,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=🛢️',
          },
          'X17oil' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:20,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=🛢️',
          },
          'RuralK' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R.J.',
          },
          'RuralY' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=R.J.',
          },
          'RuralX' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=R.J.',
          },
          'CTownK' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C.T.',
          },
          'CTownY' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C.T.',
          },
          'CTownX' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C.T.',
          },
          'RHQ3' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          'RHQ4' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'RHQ5' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'RHQ6' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'X01' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'X02' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'X06' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'X03' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DFW',
          },
          'X05' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=LA',
          },
          'X10' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DFW',
          },
          'X11' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=LA',
          },
          'X12' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60,slots:2;city=revenue:60;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,'\
                      'b:_1;label=NY',
          },
          'X13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=CL',
          },
          'X14' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'label=DFW',
          },
          'X15' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          'X16' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY',
          },
          'X17' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
          'X18' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=DFW',
          },
          'X19' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90,slots:4;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          'X30' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
          },
        }.freeze

        LOCATION_NAMES = {
          'A15' => 'Winnipeg',
          'A27' => 'Montreal',
          'B2' => 'Seattle',
          'B8' => 'Helena',
          'B14' => 'Fargo',
          'C3' => 'Portland',
          'C17' => 'Minneapolis',
          'C23' => 'Detroit',
          'C25' => 'Toronto',
          'C29' => 'Boston',
          'D6' => 'Boise',
          'D14' => 'Omaha',
          'D20' => 'Chicago',
          'D24' => 'Cleveland',
          'D28' => 'New York City',
          'E1' => 'San Francisco',
          'E3' => 'Sacramento',
          'E7' => 'Salt Lake City',
          'E11' => 'Denver',
          'E15' => 'Kansas City',
          'E17' => 'St. Louis',
          'E23' => 'Columbus',
          'F20' => 'Louisville',
          'F26' => 'Baltimore',
          'G3' => 'Los Angeles',
          'G7' => 'Pheonix',
          'G11' => 'Santa Fe',
          'G17' => 'Memphis',
          'G27' => 'Norfolk',
          'H8' => 'Tucson',
          'H14' => 'Dallas-Fort Worth',
          'H20' => 'Birmingham',
          'H22' => 'Atlanta',
          'I13' => 'San Antonio',
          'I15' => 'Houston',
          'I19' => 'New Orelans',
          'I25' => 'Jacksonville',
          'J20' => 'Port of New Orleans',
          'J24' => 'Florida',
          'I9' => 'Mexico',
        }.freeze

        MARKET = [
          %w[0l
             0a
             0a
             0a
             42
             44
             46
             48
             50p
             53s
             56p
             59p
             62p
             66p
             70p
             74s
             78p
             82p
             86p
             90p
             95p
             100p
             105p
             110p
             115p
             120s
             127p
             135p
             142p
             150p
             157p
             165p
             172p
             180p
             190p
             200p
             210
             220
             230
             240
             250
             260
             270
             285
             300
             315
             330
             345
             360
             375
             390
             405
             420
             440
             460
             480
             500
             520
             540
             560
             580
             600
             625
             650
             675
             700
             725
             750
             775
             800],
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
            name: '3+',
            on: '3+',
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
            name: '4+',
            on: '4+',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
            status: ['increased_oil'],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            status: ['increased_oil'],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green blue brown gray],
            status: ['increased_oil'],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green blue brown gray],
            status: %w[increased_oil no_new_shorts],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
        ].freeze

        # Trying to do {static literal}.merge(super.static_literal) so that the capitalization shows up first.
        STATUS_TEXT = {
          'increased_oil' => [
            'Increased Oil Prices',
            'Oil is worth $20 instead of $10',
          ],
        }.merge(Base::STATUS_TEXT)
        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 40 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 4 },
                  { name: '3', distance: 3, price: 250, rusts_on: '6', num: 12 },
                  { name: '3+', distance: 3, price: 250, obsolete_on: '6', num: 2 },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 7 },
                  { name: '4+', distance: 4, price: 400, obsolete_on: '8', num: 1 },
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

        CITY_HEXES =
          %w[B8 B14 C3 C17 C29 D6 D14 D20 D24 E3 E7 E11 E15 E17 E23 F20 F26 G3 G7 G11 G17 G27 H8 H14 H20 H22 I13 I15 I19
             I25].freeze
        OIL_HEXES = %w[B12 G15 H4 I17 I21 I23 J14].freeze
        IRON_HEXES = %w[B10 C7 C19 D16 E5 E9 G21 H6].freeze
        COAL_HEXES = %w[B6 B10 B12 C9 D8 D10 D26 E19 E25 F8 F10 F16 F22 F24].freeze
        BRIDGE_CITY_HEXES = %w[C10 C17 D14 E15 E17 F20 G17].freeze
        COMPANIES = [
          # P1
          {
            name: 'Lehigh Coal Mine Co.',
            value: 30,
            revenue: 0,
            desc: 'Comes with one coal mine marker. When placing a yellow '\
                  'tile in a coal hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P1',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: %w[7coal 8coal 9coal],
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
          # P2
          # TODO: Make it work as a combo with P27
          {
            name: 'Fox Bridge Works',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city, regardless of connectivity.  Allows owning corp to '\
                  'skip $10 river fee when placing track.',
            sym: 'P2',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: BRIDGE_CITY_HEXES,
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          # P3
          {
            name: 'Reece Oil and Gas',
            value: 30,
            revenue: 0,
            desc: 'Comes with one oil marker. When placing a yellow '\
                  'tile in an oilfield hex pointing to a revenue location, can place '\
                  'token.  Marked yellow hexes *can* be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  Hexes revenue bonus is upgraded automatically to $20 in phase 5. '\
                  'May not start or end a route at an oilfield.',
            sym: 'P3',
            abilities: [
              {
                type: 'tile_lay',
                hexes: OIL_HEXES,
                tiles: %w[7oil 8oil 9oil],
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
          # P4
          {
            name: 'Hendrickson Iron',
            value: 40,
            revenue: 0,
            desc: 'Comes with one ore marker. When placing a yellow '\
                  'tile in a mining hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  A tile lay action may be used to increase the revenue bonus to $20 in phase 3. '\
                  '  May not start or end a route at an iron mine.',
            sym: 'P4',
            abilities: [
              {
                type: 'tile_lay',
                hexes: IRON_HEXES,
                tiles: %w[7iron10 8iron10 9iron10],
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
          # P5
          {
            name: 'Nobel\'s Blasting Powder',
            value: 30,
            revenue: 0,
            desc: '$15 discount on mountains. No money is refunded if combined with the ability of another private that also '\
                  'negates the cost of difficult terrain',
            sym: 'P5',
            abilities: [
              {
                type: 'tile_discount',
                discount: 15,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          # P12
          {
            name: 'Standard Oil Co.',
            value: 60,
            revenue: 0,
            desc: 'Comes with two oil markers. When placing a yellow '\
                  'tile in an oilfield hex pointing to a revenue location, can place '\
                  'token.  Marked yellow hexes *can* be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  Hexes revenue bonus is upgraded automatically to $20 in phase 5. '\
                  'May not start or end a route at an oilfield.',
            sym: 'P12',
            abilities: [
              {
                type: 'tile_lay',
                hexes: OIL_HEXES,
                tiles: %w[7oil 8oil 9oil],
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
          # P14
          {
            name: 'Pyramid Scheme',
            value: 60,
            revenue: 0,
            desc: 'Does nothing',
            sym: 'P14',
            abilities: [],
            color: nil,
          },
          # P16 Regional Headquarters
          # TODO - make it so that tile lay can be restricted to be within a phase and onto a specific tile
          {
            name: 'Regional Headquarters',
            value: 60,
            revenue: 0,
            desc: 'May upgrade a non-metropolis green or brown city to the RHQ tile after phase 5 starts',
            sym: 'P16',
            abilities: [
              # Simply owning this company is the ability
            ],
            color: nil,
          },
          # P18
          {
            name: 'Peabody Coal Company',
            value: 60,
            revenue: 0,
            desc: 'Comes with two coal mine markers. When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P18',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: %w[7coal 8coal 9coal],
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
          # P21
          # TODO: Make it work as a combo with P27
          {
            name: 'Keystone Bridge Co.',
            value: 80,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city, regardless of connectivity.  Allows owning corp to '\
                  'skip $10 river fee when placing track. '\
                  'Also comes with one coal token and one ore token. (see rules on coal and ore) '\
                  'You can only ever use one of these two; using one means you forfeit the other',
            sym: 'P21',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: BRIDGE_CITY_HEXES,
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
              {
                type: 'tile_lay',
                hexes: COAL_HEXES + IRON_HEXES,
                tiles: %w[7coal 8coal 9coal 7iron10 8iron10 9iron10],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: nil,
          },
          # P22
          {
            name: 'American Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge tokens that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city, regardless of connectivity..  Allows owning corp to '\
                  'skip $10 river fee when placing track.',
            sym: 'P22',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: BRIDGE_CITY_HEXES,
                count: 2,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          # P23
          {
            name: 'Bailey Yard',
            value: 80,
            revenue: 0,
            desc: 'Provides an additional station marker for the owning corp, awarded at time of purchase',
            sym: 'P23',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          # P24
          {
            name: 'Anaconda Copper',
            value: 90,
            revenue: 0,
            desc: 'Comes with two ore markers. When placing a yellow '\
                  'tile in a mining hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  A tile lay action may be used to increase the revenue bonus to $20 in phase 3. '\
                  '  May not start or end a route at an iron mine.',
            sym: 'P24',
            abilities: [
              {
                type: 'tile_lay',
                hexes: IRON_HEXES,
                tiles: %w[7iron10 8iron10 9iron10],
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
          # P26
          {
            name: 'Rural Junction',
            value: 90,
            revenue: 0,
            desc: 'Comes with three rural junction tiles. Rural junctions can be placed in empty city hexes and fulfill the '\
                  'revenue center requirement for coal, iron, and oil markers and can receive bridge tokens. Rural junctions '\
                  'are not towns and do not count against the number of stops for a train and furthermore they may not be the '\
                  'start or end of a route. Rural junctions may never be upgraded; a train may not run through the same rural '\
                  'junction twice',
            sym: 'P26',
            abilities: [
              {
                type: 'tile_lay',
                hexes: CITY_HEXES,
                tiles: %w[RuralX RuralY RuralK],
                free: false,
                reachable: true,
                when: 'track',
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
            color: nil,
          },
          # P27
          {
            name: 'Company Town',
            value: 90,
            revenue: 0,
            desc: 'Comes with 3 company town tiles, only one of which may be played. The owning corporation may place one '\
                  'Company Town tile on any empty hex not adjacent to a metropolis. When placed, the owning corporation '\
                  'receives one bonus station marker which must be placed on the Company Town tile. No other corporations may '\
                  'place a token on the Company Town hex and receive $10 less for the city than the company with the station '\
                  'marker in the city. The Company Town can be placed on any hex, city circle or not, as long as it is not '\
                  'adjacent to a metropolis and has no track or station marker in it. If the Company Town tile is placed on a '\
                  '$10 river hex, a bridge token may be used. Coal / Oil / Iron markers may not be used with the Company Town. '\
                  'If the station marker in the Company Town hex is ever removed, no token may ever replace it',
            sym: 'P27',
            abilities: [],
            color: nil,
          },
          # P28
          {
            name: 'Consolidation Coal Co.',
            value: 90,
            revenue: 0,
            desc: 'Comes with three coal mine markers. When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P28',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: %w[7coal 8coal 9coal],
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

        LAYOUT = :pointy

        ASSIGNMENT_TOKENS = {
          'bridge' => '/icons/1817/bridge_token.svg',
        }.freeze

        SEED_MONEY = 200
        # Alphabetized. Not sure what official ordering is

        METROPOLITAN_HEXES = %w[G3 E11 H14 H22 I19 D20].freeze

        def active_metropolitan_hexes
          @active_metropolitan_hexes ||= [@hexes.find { |h| h.id == 'D28' }]
        end

        def setup
          @rhq_tiles ||= @all_tiles.select { |t| t.name.include?('RHQ') }
          @company_town_tiles ||= @all_tiles.select { |t| t.name.include?('CTown') }

          # Place neutral tokens in the off board cities
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'minus_ten',
            simple_logo: 'minus_ten',
            tokens: [0, 0, 0],
          )
          neutral.owner = @bank

          neutral.tokens.each { |token| token.type = :neutral }
          city_by_id('CTownK-0-0').place_token(neutral, neutral.next_token)
          city_by_id('CTownX-0-0').place_token(neutral, neutral.next_token)
          city_by_id('CTownY-0-0').place_token(neutral, neutral.next_token)

          metro = METROPOLITAN_HEXES.sort_by { rand }.take(3)
          metro.each do |i|
            hex = @hexes.find { |h| h.id == i }
            active_metropolitan_hexes << hex
            case i
            when 'H14'
              hex.lay(@tiles.find { |t| t.name == 'X03' })
            when 'E11'
              # Denver needs to be done at a later date
            when 'G3'
              hex.lay(@tiles.find { |t| t.name == 'X05' }.rotate!(3))
            when 'D20'
              hex.lay(@tiles.find { |t| t.name == 'X02' }.rotate!(1))
            when 'I19'
              hex.lay(@tiles.find { |t| t.name == 'X06' })
            when 'H22'
              hex.lay(@tiles.find { |t| t.name == 'X01' })
            end
          end
        end

        #
        # Get the currently possible upgrades for a tile
        # from: Tile - Tile to upgrade from
        # to: Tile - Tile to upgrade to
        # special - ???
        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # TODO: Check if it's near a metropolis
          return true if @company_town_tiles.map(&:name).include?(to.name) && from.color == :white
          return @phase.tiles.include?(:brown) if @rhq_tiles.map(&:name).include?(to.name) &&
              %w[5 6 7 14 15 619].include?(from.name)

          super
        end

        # Get all possible upgrades for a tile
        # tile: The tile to be upgraded
        # tile_manifest: true/false Is this being called from the tile manifest screen
        #
        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super
          return upgrades unless tile_manifest

          upgrades |= @rhq_tiles if @phase.tiles.include?(:brown) && %w[5 6 7 14 15 619].include?(tile.name)
          upgrades |= @company_town_tiles if tile.color == :white
          upgrades
        end

        def legal_tile_rotation?(entity, hex, tile)
          return company_by_id('P27').owner == entity && !company_by_id('P27').closed? if tile.name.include?('CTown')
          return company_by_id('P16').owner == entity && !company_by_id('P16').closed? if tile.name.include?('RHQ')

          super
        end

        def take_loan(entity, loan)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          price = entity.share_price.price
          name = entity.name
          name += " (#{entity.owner.name})" if @round.is_a?(Round::Stock)
          @log << "#{name} takes a loan and receives #{format_currency(loan.amount)}"
          @bank.spend(loan.amount, entity)
          @stock_market.move_left(entity)
          @stock_market.move_left(entity)
          log_share_price(entity, price)
          entity.loans << loan
          @loans.delete(loan)
        end

        OFFBOARD_VALUES = [[20, 30, 40, 50], [20, 30, 40, 60], [20, 30, 50, 60], [20, 30, 50, 60], [20, 30, 60, 90],
                           [20, 40, 50, 80], [30, 40, 40, 50], [30, 40, 50, 60], [30, 50, 60, 80], [30, 50, 60, 80],
                           [40, 50, 40, 40]].freeze

        def optional_hexes
          offboard = OFFBOARD_VALUES.sort_by { rand }
          plain_hexes = %w[B20 B26 C5 C11 C13 C15 D2 D4 D12 D22 E13 F2 F6 F12 F14 G9 G13 G19 G25 H10 H12 H16
                           H24 H26]
          {
            red: {
              ['A27'] => "offboard=revenue:yellow_#{offboard[0][0]}|green_#{offboard[0][1]}"\
                         "|brown_#{offboard[0][2]}|gray_#{offboard[0][3]};"\
                         'path=a:5,b:_0;path=a:0,b:_0',
              ['J20'] => "offboard=revenue:yellow_#{offboard[1][0]}|green_#{offboard[1][1]}|brown_#{offboard[1][2]}"\
                         "|gray_#{offboard[1][3]};path=a:2,b:_0",
              ['I5'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                        "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:2,b:_0;path=a:3,b:_0;border=edge:4",
              %w[I7
                 I9] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                        "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:2,b:_0;path=a:3,b:_0;border=edge:4;border=edge:1",
              ['I11'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                         "|gray_#{offboard[2][3]},groups:Mexico;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;"\
                         'border=edge:5',
              ['J12'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                         "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:3,b:_0;path=a:4,b:_0;border=edge:2;border=edge:5",
              ['K13'] => "offboard=revenue:yellow_#{offboard[2][0]}|green_#{offboard[2][1]}|brown_#{offboard[2][2]}"\
                         "|gray_#{offboard[2][3]},groups:Mexico,hide:1;path=a:3,b:_0;border=edge:2",
            },
            white: {
              %w[E27] => 'stub=edge:3',
              %w[E11 G3 H14 I15 H20 H22 F26 C29 D24] => 'city=revenue:0',
              %w[D6 E3 E7 G7 G11 H8 I13 I25 G27 E23] => 'city=revenue:0;icon=image:18_ms/coins',
              %w[C17 E15 E17 F20 G17 I19] => 'city=revenue:0;upgrade=cost:10,terrain:water;icon=image:18_usa/bridge',
              %w[C3
                 D14] => 'city=revenue:0;upgrade=cost:10,terrain:water;icon=image:18_ms/coins;icon=image:18_usa/bridge',
              %w[B28 C27 F4 G5 G23] => 'upgrade=cost:15,terrain:mountain',
              %w[D18 E21 F18 H18] => 'upgrade=cost:10,terrain:water',
              ['B22'] => 'upgrade=cost:20,terrain:lake',
              %w[C7 E9 G21] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/mine',
              %w[D16 E5 H6] => 'icon=image:18_usa/mine',
              %w[G15 H4 I17 I21 I23 J14] => 'icon=image:18_usa/oil-derrick',
              %w[E19 F16] => 'icon=image:18_usa/coalcar',
              %w[C9 D8 D10 E25 F8 F10 F22 F24] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar',
              %w[D26] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar;stub=edge:4',
              %w[B16 B18] => 'icon=image:18_usa/gnr',
              ['C19'] => 'icon=image:18_usa/gnr;icon=image:18_usa/mine',
              ['B10'] => 'icon=image:18_usa/gnr;icon=image:18_usa/coalcar;icon=image:18_usa/mine',
              ['B12'] => 'icon=image:18_usa/gnr;icon=image:18_usa/coalcar;icon=image:18_usa/oil-derrick',
              ['D20'] => 'icon=image:18_usa/gnr;city=revenue:0',
              %w[B8 B14] => 'icon=image:18_usa/gnr;city=revenue:0;icon=image:18_ms/coins',
              ['B6'] => 'icon=image:18_usa/gnr;upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar',
              ['B4'] => 'icon=image:18_usa/gnr;upgrade=cost:10,terrain:water',
              plain_hexes => '',
            },
            gray: {
              ['A15'] => "town=revenue:yellow_#{offboard[3][0]}|green_#{offboard[3][1]}|brown_#{offboard[3][2]}"\
                         "|gray_#{offboard[3][3]};path=a:0,b:_0;path=a:5,b:_0",
              ['B2'] => "town=revenue:yellow_#{offboard[4][0]}|green_#{offboard[4][1]}|brown_#{offboard[4][2]}"\
                        "|gray_#{offboard[4][3]};path=a:4,b:_0;path=a:5,b:_0",
              ['J24'] => "town=revenue:yellow_#{offboard[5][0]}|green_#{offboard[5][1]}|brown_#{offboard[5][2]}"\
                         "|gray_#{offboard[5][3]};path=a:2,b:_0;path=a:3,b:_0",
              ['E1'] => "town=revenue:yellow_#{offboard[6][0]}|green_#{offboard[6][1]}|brown_#{offboard[6][2]}"\
                        "|gray_#{offboard[6][3]};path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0",
              ['B30'] => 'path=a:1,b:0',
              ['C23'] => 'town=revenue:yellow_30|green_40|brown_50|gray_60;path=a:4,b:_0;path=a:2,b:_0;path=a:0,b:_0',
              ['C25'] => 'town=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:5,b:_0;path=a:3,b:_0',
            },
            yellow: {
              ['D28'] => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:3,b:_0;label=NY',
            },
            blue: {
              ['F28'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:0,b:_0',
              %w[B24 C21] => '',
            },
          }
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G18USA::Round::Stock.new(self, [
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
            G18USA::Step::Loan,
            G18USA::Step::SpecialTrack,
            G18USA::Step::Assign,
            G18USA::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18USA::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1817::Step::BuyTrain,
          ], round_num: round_num)
        end

        def revenue_for(route, stops)
          revenue = super

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          revenue += 10 * route.all_hexes.count { |hex| hex.tile.id.include?('coal') }
          revenue += 10 * route.all_hexes.count { |hex| hex.tile.id.include?('iron10') }
          revenue += 20 * route.all_hexes.count { |hex| hex.tile.id.include?('iron20') }
          revenue + (increased_oil? ? 20 : 10) * route.all_hexes.count { |hex| hex.tile.id.include?('oil') }
        end

        def increased_oil?
          @phase.status.include?('increased_oil')
        end

        def check_distance(route, visits)
          super
          #raise GameError, 'Train cannot start or end on a rural junction' if visits.first.tile.name.include?('Rural') || visits.last.tile.name.include?('Rural')
        end

      end
    end
  end
end
