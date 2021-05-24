# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module Map
        LAYOUT = :pointy

        TILES = {
          # yellow
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 'unlimited',

          # green
          '14' => 'unlimited',
          '15' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '141' => 'unlimited',
          '142' => 'unlimited',
          '143' => 'unlimited',
          '144' => 'unlimited',
          '619' => 'unlimited',

          # brown
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '611' => 'unlimited',

          # gray
          '51' => 2,
          '60' => 2,

          # custom yellow
          '3' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,loc:center;path=a:_0,b:0;path=a:_0,b:1',
          },
          '4' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,loc:center;path=a:_0,b:0;path=a:_0,b:3',
          },
          '58' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,loc:center;path=a:_0,b:0;path=a:_0,b:2',
          },
          'YC' => {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:_0,b:1;path=a:_0,b:4;label=C',
          },
          'YL' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0,loc:1;town=revenue:10,loc:center;path=a:_1,b:2;path=a:_1,b:4;label=L',
          },
          'YG' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0,loc:0;town=revenue:10,loc:center;path=a:_1,b:2;path=a:_1,b:4;label=G',
          },
          'Y5b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center;path=a:_0,b:0;path=a:_0,b:1',
          },
          'Y5B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:1',
          },
          'Y6b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center;path=a:_0,b:0;path=a:_0,b:2',
          },
          'Y6B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:2',
          },
          'Y57b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center;path=a:_0,b:0;path=a:_0,b:3',
          },
          'Y57B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:3',
          },
          '961bb' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1;town=revenue:10,boom:1;path=a:_0,b:0;path=a:_1,b:3',
          },
          '961Bb' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;town=revenue:10,boom:1;'\
                      'path=a:_0,b:0;path=a:_1,b:3',
          },
          '962bb' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1;town=revenue:10,boom:1;path=a:_0,b:0;path=a:_1,b:4',
          },
          '962bB' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;town=revenue:10,boom:1;'\
                      'path=a:_0,b:4;path=a:_1,b:0',
          },
          '962Bb' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;town=revenue:10,boom:1;'\
                      'path=a:_0,b:0;path=a:_1,b:4',
          },
          '963bb' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1;town=revenue:10,boom:1;path=a:_0,b:3;path=a:_1,b:4',
          },
          '963bB' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;town=revenue:10,boom:1;'\
                      'path=a:_0,b:4;path=a:_1,b:3',
          },
          '963Bb' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:white_10|yellow_20|black_30,boom:1;town=revenue:10,boom:1;'\
                      'path=a:_0,b:3;path=a:_1,b:4',
          },

          # custom green
          'GC' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;label=C;'\
                      'path=a:_0,b:1;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;',
          },
          'GL' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;label=L;'\
                      'path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4',
          },
          'GG' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;label=G;'\
                      'path=a:_0,b:2;path=a:_0,b:4',
          },
          '619b' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4;',
          },
          '14b' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:3;path=a:_0,b:4;',
          },
          '14B' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:white_10|green_30|black_40,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:3;path=a:_0,b:4;',
          },
          '15b' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:3;',
          },
          '15B' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:white_10|green_30|black_40,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:3;',
          },
          '619B' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:white_10|green_30|black_40,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4;',
          },
          '941a1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:2;path=a:_1,b:3',
          },
          '941A1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:2;path=a:_1,b:3',
          },
          '941a2' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:2;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:2;path=a:_1,b:0;path=a:_1,b:3',
          },
          '941A2' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:2;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:2;path=a:_1,b:0;path=a:_1,b:3',
          },
          '941a3' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:3;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:3;path=a:_1,b:0;path=a:_1,b:2',
          },
          '941A3' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:3;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:3;path=a:_1,b:0;path=a:_1,b:2',
          },
          '942a1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:3;path=a:_1,b:4',
          },
          '942A1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:3;path=a:_1,b:4',
          },
          '942a2' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:3;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:3;path=a:_1,b:0;path=a:_1,b:4',
          },
          '942A2' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:3;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:3;path=a:_1,b:0;path=a:_1,b:4',
          },
          '942a3' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:4;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:4;path=a:_1,b:0;path=a:_1,b:3',
          },
          '942A3' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:4;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:4;path=a:_1,b:0;path=a:_1,b:3',
          },
          '943a1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:1;path=a:_1,b:2',
          },
          '943A1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:1;path=a:_1,b:2',
          },
          '943a2' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:1;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:1;path=a:_1,b:0;path=a:_1,b:2',
          },
          '943A2' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:1;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:1;path=a:_1,b:0;path=a:_1,b:2',
          },
          '943a3' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:2;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:2;path=a:_1,b:0;path=a:_1,b:1',
          },
          '943A3' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:2;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:2;path=a:_1,b:0;path=a:_1,b:1',
          },
          '944a1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;town=revenue:10,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:2;path=a:_1,b:4',
          },
          '944A1' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'town=revenue:10,boom:1,loc:0;city=revenue:white_10|green_30|black_40,boom:1,loc:center;'\
                      'path=a:_0,b:_1;path=a:_0,b:0;path=a:_1,b:2;path=a:_1,b:4',
          },

          # custom brown
          'BC' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=C;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5',
          },
          'BL' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;label=L;'\
                      'path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4',
          },
          'BG' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;label=G;'\
                      'path=a:_0,b:0;path=a:_0,b:2;path=a:_0,b:4',
          },
          'B5' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'hidden' => 1,
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'B5b' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'town=revenue:20,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'B5B' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:white_20|brown_40|black_50,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'B5bb' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'town=revenue:20,boom:1,double:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'B5BB' => {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:white_20|brown_40|black_50,slots:2,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },

          # custom gray
          '5b' => {
            'count' => 6,
            'color' => 'gray',
            'code' => 'town=revenue:20,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          '5B' => {
            'count' => 6,
            'color' => 'gray',
            'code' => 'city=revenue:white_20|gray_50|black_60,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'B5G' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'RC' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=C;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5',
          },
          '5bb' => {
            'count' => 3,
            'color' => 'gray',
            'code' => 'town=revenue:20,boom:1,double:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          '5BB' => {
            'count' => 3,
            'color' => 'gray',
            'code' => 'city=revenue:white_20|gray_50|black_60,boom:1,slots:2;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },

          # custom red
          'Billings-X' => {
            'count' => 1,
            'color' => 'red',
            'code' => '',
          },
          'Billings-a' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_20|green_40|brown_50|gray_60;'\
                      'path=a:_0,b:0;path=a:_0,b:5;',
          },
          'Billings-b' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_20|green_40|brown_50|gray_60,hide:1;'\
                      'path=a:_0,b:0;path=a:_0,b:5;',
          },
          'Billings-c' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_20|green_40|brown_50|gray_60;'\
                      'path=a:_0,b:5',
          },
          'Ogden' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_30|green_40|brown_50|gray_60;'\
                      'path=a:_0,b:3;path=a:_0,b:4;',
          },
        }.freeze

        TILE_UPGRADES = {
          # town + city -> city
          'YG' => ['GG'],
          'YL' => ['GL'],

          # Brown Boomtown
          '14b' => ['B5b'],
          '15b' => ['B5b'],
          '619b' => ['B5b'],

          # Brown Boom City
          '14B' => ['B5B'],
          '15B' => ['B5B'],
          '619B' => ['B5B'],

          # Brown double Boomtown
          '941a1' => ['B5bb'],
          '941a2' => ['B5bb'],
          '941a3' => ['B5bb'],
          '942a1' => ['B5bb'],
          '942a2' => ['B5bb'],
          '942a3' => ['B5bb'],
          '943a1' => ['B5bb'],
          '943a2' => ['B5bb'],
          '943a3' => ['B5bb'],
          '944a1' => ['B5bb'],

          # Brown Double Boom City
          '941A1' => ['B5BB'],
          '941A2' => ['B5BB'],
          '941A3' => ['B5BB'],
          '942A1' => ['B5BB'],
          '942A2' => ['B5BB'],
          '942A3' => ['B5BB'],
          '943A1' => ['B5BB'],
          '943A2' => ['B5BB'],
          '943A3' => ['B5BB'],
          '944A1' => ['B5BB'],

          # Brown double Boomtown -> Gray double Boomtown
          'B5bb' => ['5bb'],

          # Brown Double Boom City -> Gray Double Boom City
          'B5BB' => ['5BB'],
        }.freeze

        BOOMTOWN_TO_BOOMCITY_TILES = {
          'Y5b' => %w[Y5B],
          'Y6b' => %w[Y6B],
          'Y57b' => %w[Y57B],
          '961bb' => %w[961Bb 961bB],
          '962bb' => %w[962Bb 962bB],
          '963bb' => %w[963Bb 963bB],

          '14b' => %w[14B],
          '15b' => %w[15B],
          '619b' => %w[619B],

          '941a1' => %w[941A1],
          '941a2' => %w[941A2],
          '941a3' => %w[941A3],

          '942a1' => %w[942A1],
          '942a2' => %w[942A2],
          '942a3' => %w[942A3],

          '943a1' => %w[943A1],
          '943a2' => %w[943A2],
          '943a3' => %w[943A3],

          '944a1' => %w[944A1],

          'B5b' => %w[B5B],
          'B5bb' => %w[B5BB],

          '5b' => %w[5B],
          '5bb' => %w[5BB],
        }.freeze

        GHOST_TOWN_TILE = {
          'Y5b' => '7',
          'Y5B' => '7',
          '963bb' => '7',
          '963Bb' => '7',
          '963bB' => '7',

          'Y6b' => '8',
          'Y6B' => '8',
          '962bb' => '8',
          '962Bb' => '8',
          '962bB' => '8',

          'Y57b' => '9',
          'Y57B' => '9',
          '961bb' => '9',
          '961Bb' => '9',

          '14b' => '544',
          '14B' => '544',

          '15b' => '545',
          '15B' => '545',

          '619b' => '546',
          '619B' => '546',

          '941a1' => '83',
          '941a2' => '83',
          '941a3' => '83',
          '941A1' => '83',
          '941A2' => '83',
          '941A3' => '83',

          '942a1' => '82',
          '942a2' => '82',
          '942a3' => '82',
          '942A1' => '82',
          '942A2' => '82',
          '942A3' => '82',

          '943a1' => '80',
          '943a2' => '80',
          '943a3' => '80',
          '943A1' => '80',
          '943A2' => '80',
          '943A3' => '80',

          '944a1' => '81',
          '944A1' => '81',

          'B5b' => 'B5',
          'B5bb' => 'B5',
          'B5B' => 'B5',
          'B5BB' => 'B5',

          '5b' => 'B5G',
          '5bb' => 'B5G',
          '5B' => 'B5G',
          '5BB' => 'B5G',
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'Independence Creek',
          'A13' => 'Billings',
          'A19' => 'Billings',
          'B12' => 'Powell',
          'B14' => 'Lovell',
          'B20' => 'Sheridan',
          'B24' => 'Spotted Horse',
          'C3' => 'Yellowstone National Park',
          'C5' => 'East Entrance',
          'C11' => 'Cody',
          'C15' => 'Basin & Greybull',
          'C29' => "Devil's Tower",
          'D4' => 'South Entrance',
          'D12' => 'Meeteetse',
          'D22' => 'Buffalo',
          'D26' => 'Donkey Town & Wyodak',
          'D30' => 'Sundance',
          'D34' => 'Rapid City',
          'E15' => 'Worland',
          'E33' => 'Black Hills',
          'F14' => 'Thermopolis',
          'F22' => 'Kaycee',
          'F26' => 'Wright',
          'F32' => 'Newcastle',
          'G1' => 'Oregon (via Idaho)',
          'G3' => 'Jackson',
          'G9' => 'Dubois',
          'G15' => 'Wind River Canyon',
          'G23' => 'Midwest',
          'G27' => 'Bill',
          'H12' => 'Riverton',
          'H14' => 'Shoshoni',
          'I11' => 'Lander',
          'I23' => 'Casper',
          'I27' => 'Douglas',
          'I31' => 'Lusk',
          'I33' => 'Chadron',
          'J6' => 'Pinedale',
          'K3' => 'Cokeville',
          'K11' => 'Atlantic City & South Pass City',
          'K15' => 'Jeffrey City',
          'K17' => 'Muddy Gap',
          'K23' => 'Shirley Basin',
          'L4' => 'Cumberland & Kemmerer',
          'L8' => 'Granger',
          'L30' => 'Fort Laramie',
          'L32' => 'Torrington',
          'M3' => 'Almy',
          'M19' => 'Rawlins',
          'M21' => 'Hanna',
          'M23' => 'Medicine Bow',
          'M33' => 'Scottsbluff',
          'N0' => 'Promontory Summit',
          'N2' => 'Bear River City',
          'N4' => 'Fort Bridger',
          'N8' => 'Green River',
          'N10' => 'Rock Springs',
          'N20' => 'Saratoga',
          'O1' => 'Ogden',
          'O17' => 'Baggs',
          'O23' => 'Centennial',
          'O25' => 'Laramie',
          'O27' => 'Sherman',
          'O29' => 'Cheyenne',
          'O33' => 'Omaha',
          'P22' => 'Walden',
          'P30' => 'Denver',
        }.freeze

        HEXES = {
          white: {
            %w[
              B28 B32
              C25
              D28
              E27 E29 E31
              F28 F30
              G29 G31
              H28 H30 H32
              I21 I29
              J30 J32
              K31
              L6
              M5 M7 M31
              N6 N24 N32
              O5 O31
            ] => '',
            %w[L8] => 'stub=edge:2;stub=edge:4;town=revenue:0,loc:2;city=revenue:0,loc:0;'\
                      'upgrade=cost:20,terrain:water;label=G',
            %w[O25] => 'stub=edge:2;stub=edge:4;town=revenue:0,loc:4;city=revenue:0,loc:1;label=L',
            %w[B10 B22
               C21
               D16
               E13 E17 E21 E25
               F24
               G21 G25
               H18 H20 H22 H26
               I13 I15 I17 I19] => 'upgrade=terrain:cow_skull,cost:10,size:40',
            %w[C13 C23 D24 E23] => 'upgrade=terrain:cow_skull,cost:10,size:40;'\
                                   'upgrade=terrain:water,cost:10',
            %w[C11] => 'upgrade=terrain:cow_skull,cost:10,size:40;upgrade=terrain:water,cost:10;'\
                       'city=revenue:0,loc:0.5',
            %w[D14] => 'upgrade=terrain:water,cost:20',
            %w[D22] => 'upgrade=terrain:cow_skull,cost:10,size:40;city=revenue:0,loc:1',
            %w[F16] => 'upgrade=terrain:cow_skull,cost:10,size:40;border=edge:0,type:impassable',
            %w[F32 I31 L32 N4] => 'town=revenue:0',
            %w[F14 H12 H14] => 'town=revenue:0;upgrade=terrain:water,cost:20',
            %w[D12 G27] => 'upgrade=terrain:cow_skull,cost:10,size:40;town=revenue:0',
            %w[L12 L14 L16 M11 M13 M15 M17 N12 N14 N16 O11 O13 O15] => 'upgrade=terrain:cow_skull,cost:20,size:40',
            %w[N2] => 'border=edge:0,type:mountain,cost:30;city=revenue:0;'\
                      'upgrade=cost:20,terrain:mountain',
            %w[O3] => 'border=edge:1,type:mountain,cost:30;upgrade=cost:20,terrain:mountain',
            %w[G15] => 'upgrade=cost:10,terrain:mountain;upgrade=cost:20,terrain:water;'\
                       'border=edge:3,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable;'\
                       'border=edge:1,type:impassable;',
            %w[H16] => 'upgrade=terrain:cow_skull,cost:10,size:40;border=edge:2,type:impassable',
            %w[O7] => 'border=edge:4,type:water,cost:30;upgrade=cost:40,terrain:mountain',
            %w[O9] => 'border=edge:1,type:water,cost:30;upgrade=cost:40,terrain:mountain',
            %w[B12 B20 D30] => 'town=revenue:0,boom:1',
            %w[B14 E15] => 'town=revenue:0,boom:1;upgrade=terrain:water,cost:20',
            %w[B24] => 'town=revenue:0,boom:1;upgrade=terrain:water,cost:10;upgrade=terrain:cow_skull,cost:10,size:40'\
                       'town=revenue:0,boom:1',
            %w[C15] => 'town=revenue:0,boom:1,loc:4;town=revenue:0,boom:1,loc:1;upgrade=terrain:water,cost:20',
            %w[B16 C9 F18 F20 G19 L22 N18 N26] => 'upgrade=cost:60,terrain:mountain',
            %w[B18 D10 I5 I7 L24] => 'upgrade=cost:40,terrain:mountain',
            %w[M3 M19 M21] => 'upgrade=cost:30,terrain:mountain;town=revenue:0,boom:1',
            %w[L4] => 'upgrade=cost:40,terrain:mountain;town=revenue:0,boom:1,loc:4;town=revenue:0,boom:1,loc:1',
            %w[I23] => 'city=revenue:0;label=C',
            %w[F8 H4 L26] => 'upgrade=cost:50,terrain:mountain',
            %w[L2 L10] => 'upgrade=cost:30,terrain:mountain',
            %w[B30 C29 C31 D32 E11 F12 H24 L18 M25 O21] => 'upgrade=cost:20,terrain:mountain',
            %w[L20 M9] => 'upgrade=cost:20,terrain:mountain;upgrade=cost:20,terrain:water',
            %w[G9] => 'upgrade=cost:20,terrain:mountain;upgrade=cost:10,terrain:water;town=revenue:0',
            %w[G23] => 'upgrade=cost:20,terrain:mountain;town=revenue:0,boom:1',
            %w[D26] => 'town=revenue:0,boom:1,loc:4;town=revenue:0,boom:1,loc:1',
            %w[F26] => 'upgrade=terrain:cow_skull,cost:10,size:40;town=revenue:0,boom:1',
            %w[F22] => 'upgrade=terrain:cow_skull,cost:10,size:40;upgrade=terrain:water,cost:10;town=revenue:0,boom:1',
            %w[I11] => 'city=revenue:0',
            %w[I27] => 'upgrade=cost:10,terrain:mountain;town=revenue:0,boom:1',
            %w[H10] => 'upgrade=cost:10,terrain:mountain;upgrade=cost:10,terrain:water',
            %w[B26 C27 I25] => 'upgrade=cost:10,terrain:mountain',
            %w[M23 N20] => 'upgrade=cost:20,terrain:mountain;town=revenue:0',
            %w[N8] => 'upgrade=cost:20,terrain:mountain;upgrade=cost:20,terrain:water;town=revenue:0,boom:1',
            %w[N10] => 'upgrade=cost:20,terrain:mountain;town=revenue:0,boom:1',
            %w[O17] => 'upgrade=cost:10,terrain:cow_skull,size:40;town=revenue:0',

            # credit mobilier region - east exterior
            %w[K29] => 'upgrade=cost:10,terrain:mountain;'\
                       'border=edge:0,type:mountain;border=edge:1,type:mountain',
            %w[L30] => 'town=revenue:0;'\
                       'border=edge:1,type:mountain',
            %w[M29] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[N30] => 'border=edge:1,type:mountain',
            %w[O29] => 'city=revenue:0;label=C;'\
                       'border=edge:1,type:mountain;border=edge:2,type:mountain',

            # credit mobilier region - east interior
            %w[L28] => 'border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[M27] => 'upgrade=cost:60,terrain:mountain;border=edge:4,type:mountain',
            %w[N28] => 'upgrade=cost:50,terrain:mountain;'\
                       'border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            %w[O27] => 'upgrade=cost:40,terrain:mountain;town=revenue:0;border=edge:4,type:mountain',

            # credit mobilier region - row J
            %w[J4] => 'upgrade=cost:50,terrain:mountain;'\
                      'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J6] => 'upgrade=cost:30,terrain:mountain;town=revenue:0,boom:1;'\
                      'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J8] => 'upgrade=cost:30,terrain:mountain;'\
                      'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J12 J14 J16 J18] => 'upgrade=cost:20,terrain:mountain;'\
                                   'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J20] => 'upgrade=cost:40,terrain:mountain;'\
                       'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J22 J26] => 'upgrade=cost:60,terrain:mountain;'\
                           'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[J28] => 'upgrade=cost:10,terrain:mountain;border=edge:0,type:mountain',

            # credit mobilier region - row K
            %w[K3] => 'upgrade=cost:40,terrain:mountain;town=revenue:0,boom:1;'\
                      'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K5 K9] => 'upgrade=cost:20,terrain:mountain;'\
                         'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K7] => 'upgrade=cost:20,terrain:mountain;upgrade=cost:10,terrain:water;'\
                      'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K11] => 'upgrade=cost:20,terrain:cow_skull,size:40;'\
                       'town=revenue:0,boom:1,loc:4;town=revenue:0,boom:1,loc:1;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K13] => 'upgrade=terrain:cow_skull,cost:20,size:40;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K15] => 'upgrade=cost:20,terrain:cow_skull,size:40;town=revenue:0,boom:1;'\
                       'icon=image:1868_wy/uranium;icon=image:1868_wy/uranium;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K17] => 'upgrade=cost:40,terrain:mountain;town=revenue:0;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K19] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:water,cost:30;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K21] => 'border=edge:1,type:water,cost:30;upgrade=cost:20,terrain:mountain;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K23] => 'upgrade=cost:30,terrain:mountain;town=revenue:0,boom:1;icon=image:1868_wy/uranium;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K25] => 'upgrade=cost:60,terrain:mountain;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[K27] => 'upgrade=cost:60,terrain:mountain;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain;'\
                       'border=edge:4,type:mountain',
          },
          gray: {
            %w[
              B8
              C17 C19
              D8 D18 D20
              E5 E7 E9 E19
              F2 F10
              G5 G7 G11
              H2 H6 H8
              I3
              N22
              O19
            ] => '',
            %w[A1] => 'town=revenue:0;path=a:_0,b:4',
            %w[A21] => 'offboard=revenue:0;path=a:_0,b:0;border=edge:4',
            %w[A23] => 'offboard=revenue:0;path=a:_0,b:5;border=edge:1',
            %w[C7 F6] => 'path=a:1,b:4',
            %w[E3] => 'path=a:3,b:5',
            %w[F4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[G3] => 'town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            %w[N0] => 'town=revenue:0,loc:5;'\
                      'path=a:_0,b:4,terminal:1;path=a:_0,b:5',
            %w[O23] => 'town=revenue:10,loc:center;path=a:_0,b:0;path=a:_0,b:4',
            %w[G17] => 'border=edge:1,type:impassable',
            %w[G13] => 'border=edge:4,type:impassable',
            %w[I9] => 'offboard=revenue:0;path=a:_0,b:4',

            # credit mobilier region
            %w[J2 J10 J24] => 'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[K1] => 'offboard=revenue:0;path=a:_0,b:4;border=edge:3,type:mountain',
          },
          red: {
            %w[A11] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30;'\
                       'border=edge:4;path=a:_0,b:0;path=a:_0,b:5',
            %w[A13] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,hide:1;'\
                       'border=edge:1;path=a:_0,b:0;path=a:_0,b:5',
            %w[A19] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30;'\
                       'path=a:_0,b:5',
            %w[E33] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40,groups:Black Hills,hide:1;path=a:_0,b:1;'\
                       'border=edge:5',
            %w[F34] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40,groups:Black Hills;path=a:_0,b:1;'\
                       'border=edge:2',
            %w[G1] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:_0,b:4',
            %w[M33] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30;path=a:_0,b:2',
            %w[O1] => 'offboard=revenue:yellow_20|green_20|brown_20|gray_30;'\
                      'path=a:_0,b:3;path=a:_0,b:4;'\
                      'border=edge:3,type:mountain,cost:30;border=edge:4,type:mountain,cost:30',
            %w[O33] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:_0,b:1;path=a:_0,b:2',
            %w[P22] => 'offboard=revenue:yellow_0|green_40|brown_30|gray_0;path=a:_0,b:2;path=a:_0,b:3',
            %w[P30] => 'offboard=revenue:yellow_0|green_20|brown_40|gray_50;path=a:_0,b:2',

            # yellowstone
            %w[B2] => 'border=edge:4;border=edge:5',
            %w[B4] => 'border=edge:0;border=edge:1;border=edge:4;border=edge:5',
            %w[B6] => 'border=edge:0;border=edge:1',
            %w[C3] => 'border=edge:0;border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            %w[C5] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3;border=edge:5;'\
                      'town=revenue:yellow_20|green_30|brown_30|gray_40;'\
                      'path=a:_0,b:4',
            %w[D2] => 'border=edge:3;border=edge:4',
            %w[D4] => 'border=edge:1;border=edge:2;border=edge:3;border=edge:4;'\
                      'town=revenue:yellow_20|green_30|brown_30|gray_40;'\
                      'path=a:_0,b:0',
            %w[D6] => 'border=edge:1;border=edge:2',
          },
          purple: {
            %w[D34] => 'city=revenue:yellow_20|green_30|brown_40|gray_40;path=a:_0,b:1,terminal:1',
            %w[I33] => 'city=revenue:yellow_20|green_30|brown_30|gray_40;'\
                       'path=a:_0,b:0,terminal:1;path=a:_0,b:1,terminal:1;path=a:_0,b:2,terminal:1',
          },
        }.freeze
      end
    end
  end
end
