# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G1830
      class Game < Game::Base
        include_meta(G1830::Meta)

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        MARKET = [
          %w[60y
             67
             71
             76
             82
             90
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             325
             350],
          %w[53y
             60y
             66
             70
             76
             82
             90p
             100
             112
             126
             142
             160
             180
             200
             220
             240
             260
             280
             300],
          %w[46y
             55y
             60y
             65
             70
             76
             82p
             90
             100
             111
             125
             140
             155
             170
             185
             200],
          %w[39o
             48y
             54y
             60y
             66
             71
             76p
             82
             90
             100
             110
             120
             130],
          %w[32o 41o 48y 55y 62 67 71p 76 82 90 100],
          %w[25b 34o 42o 50y 58y 65 67p 71 75 80],
          %w[18b 27b 36o 45o 54y 63 67 69 70],
          %w[10b 20b 30b 40o 50y 60y 67 68],
          ['', '10b', '20b', '30b', '40o', '50y', '60y'],
          ['', '', '10b', '20b', '30b', '40o', '50y'],
          ['', '', '', '10b', '20b', '30b', '40o'],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
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
                    name: 'D',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 4 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 2 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        HEXES = {
          red: {
            ['F2'] =>
                     'offboard=revenue:yellow_40|brown_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I1'] =>
                   'offboard=revenue:yellow_30|brown_60,hide:1,groups:Gulf;path=a:4,b:_0;border=edge:5',
            ['J2'] =>
                   'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['A9'] =>
                   'offboard=revenue:yellow_30|brown_50,hide:1,groups:Canada;path=a:5,b:_0;border=edge:4',
            ['A11'] =>
                   'offboard=revenue:yellow_30|brown_50,groups:Canada;path=a:5,b:_0;path=a:0,b:_0;border=edge:1',
            ['K13'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            ['B24'] => 'offboard=revenue:yellow_20|brown_30;path=a:1,b:_0;path=a:0,b:_0',
          },
          gray: {
            ['D2'] => 'city=revenue:20;path=a:5,b:_0;path=a:4,b:_0',
            ['F6'] => 'city=revenue:30;path=a:5,b:_0;path=a:0,b:_0',
            ['E9'] => 'path=a:2,b:3',
            ['H12'] => 'city=revenue:10,loc:2.5;path=a:1,b:_0;path=a:4,b:_0;path=a:1,b:4',
            ['D14'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0',
            ['C15'] => 'town=revenue:10;path=a:1,b:_0;path=a:3,b:_0',
            ['K15'] => 'city=revenue:20;path=a:2,b:_0',
            ['A17'] => 'path=a:0,b:5',
            ['A19'] => 'city=revenue:40;path=a:5,b:_0;path=a:0,b:_0',
            %w[I19 F24] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['D24'] => 'path=a:1,b:0',
          },
          white: {
            %w[F4 J14 F22] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            ['E7'] => 'town=revenue:0;border=edge:5,type:impassable',
            ['F8'] => 'border=edge:2,type:impassable',
            ['C11'] => 'border=edge:5,type:impassable',
            ['C13'] => 'border=edge:0,type:impassable',
            ['D12'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['B16'] => 'city=revenue:0;border=edge:5,type:impassable',
            ['C17'] => 'upgrade=cost:120,terrain:mountain;border=edge:2,type:impassable',
            %w[B20 D4 F10] => 'town',
            %w[I13
               D18
               B12
               B14
               B22
               C7
               C9
               C23
               D8
               D16
               D20
               E3
               E13
               E15
               F12
               F14
               F18
               G3
               G5
               G9
               G11
               H2
               H6
               H8
               H14
               I3
               I5
               I7
               I9
               J4
               J6
               J8] => 'blank',
            %w[G15 C21 D22 E17 E21 G13 I11 J10 J12] =>
            'upgrade=cost:120,terrain:mountain',
            %w[E19 H4 B10 H10 H16] => 'city',
            ['F16'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[G7 G17 F20] => 'town=revenue:0;town=revenue:0',
            %w[D6 I17 B18 C19] => 'upgrade=cost:80,terrain:water',
          },
          yellow: {
            %w[E5 D10] =>
                     'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:water',
            %w[E11 H18] => 'city=revenue:0;city=revenue:0;label=OO',
            ['I15'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',
            ['G19'] =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:0,b:_1;label=NY;upgrade=cost:80,terrain:water',
            ['E23'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
        }.freeze

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end
      end
    end
  end
end
