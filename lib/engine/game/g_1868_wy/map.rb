# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module Map
        LAYOUT = :pointy

        HEXES = {
          white: {
            ['C9'] => 'city=revenue:0,loc:0.5;label=C;upgrade=cost:10,terrain:cow_skull,size:40;upgrade=cost:10,terrain:water',
            %w[B16 H10] => 'city=revenue:0',
            ['H18'] => 'city=revenue:0;label=C;',
            ['M25'] => 'city=revenue:0;label=C;border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['J6'] => 'stub=edge:2;stub=edge:4;town=revenue:0,loc:2;city=revenue:0,loc:0;label=G;upgrade=cost:10,terrain:water;'\
                      'border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['M21'] => 'stub=edge:2;stub=edge:4;town=revenue:0,loc:4;city=revenue:0,loc:1;label=L',
            ['F12'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable;'\
                       'border=edge:5,type:impassable;border=edge:1,type:water;'\
                       'upgrade=cost:20,terrain:water;upgrade=cost:10,terrain:mountain',
            %w[B8 B18 C13 D10 D14 E13 E19 E21 F16 F20 G13 G15 G17 G21 G23 H12
               H14 H16 K9 K11 K13 L12 L14 M11 M13] => 'upgrade=cost:10,terrain:cow_skull,size:40',
            %w[B10 D20 D24] => 'town=revenue:0,boom:1',
            ['B12'] => 'upgrade=cost:20,terrain:water',
            %w[B14 E15] => 'upgrade=cost:60,terrain:mountain',
            %w[B20 C21] => 'upgrade=cost:10,terrain:mountain',
            %w[B22 B24 D22 D26 E23 E25 F24 F26 G25 H24 H26 I25 K5 L6 L20 M5] => '',
            %w[B26 C23 C25 G19 H20 M17] => 'upgrade=cost:20,terrain:mountain',
            %w[C11 D12] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:water',
            %w[C17 F22 L10] => 'town=revenue:0,boom:1;upgrade=cost:10,terrain:cow_skull,size:40',
            %w[C19 D18] => 'upgrade=cost:10,terrain:cow_skull,size:40;upgrade=cost:10,terrain:water',
            %w[E11 G9 G11] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            ['E17'] => 'town=revenue:0;upgrade=cost:10,terrain:cow_skull,size:40;upgrade=cost:10,terrain:water',
            ['F8'] => 'upgrade=cost:10,terrain:water;upgrade=cost:20,terrain:mountain',
            %w[F18 K17 L8] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:mountain',
            %w[G5 H4 K21 M7 M9] => 'upgrade=cost:40,terrain:mountain',
            ['H6'] => 'town=revenue:0,boom:1;upgrade=cost:30,terrain:mountain',
            %w[H22 K15] => 'town=revenue:0,boom:1;upgrade=cost:10,terrain:mountain',
            ['I3'] =>
    'town=revenue:0,boom:1;upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I5'] =>
    'upgrade=cost:10,terrain:water;upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I7'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I9'] =>
    'town=revenue:0,boom:1;upgrade=cost:10,terrain:cow_skull,size:40;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I11'] => 'upgrade=cost:10,terrain:cow_skull,size:40;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[I13 I15 I17] => 'upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I19'] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I21'] => 'upgrade=cost:50,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I23'] => 'upgrade=cost:10,terrain:mountain;border=edge:0,type:mountain',
            ['J2'] => 'town=revenue:0,boom:1;upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain',
            ['J4'] => 'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[J8 J14 J16 J18] =>
    'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['J10'] => 'upgrade=cost:10,terrain:cow_skull,size:40;border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['J12'] => 'town=revenue:0,boom:1;upgrade=cost:10,terrain:cow_skull,size:40;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain;'\
                       'icon=image:1868_wy/uranium_early,sticky:1;icon=image:1868_wy/uranium_early,sticky:1',
            ['J20'] => 'town=revenue:0,boom:1;upgrade=cost:30,terrain:mountain;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain;icon=image:1868_wy/uranium_early,sticky:1',
            ['J22'] =>
    'upgrade=cost:60,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['J24'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain',
            %w[J26 L4] => 'town=revenue:0',
            ['K3'] => 'upgrade=cost:30,terrain:mountain',
            ['M3'] => 'upgrade=cost:30,terrain:mountain;border=edge:1,type:mountain,cost:30',
            ['K7'] => 'upgrade=cost:20,terrain:water;upgrade=cost:20,terrain:mountain',
            %w[K19 L16] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
            ['K23'] =>
    'upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            ['K25'] => 'border=edge:1,type:mountain',
            ['L2'] => 'city=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain,cost:30',
            ['L22'] => 'upgrade=cost:60,terrain:mountain;border=edge:4,type:mountain',
            ['L24'] => 'border=edge:0,type:mountain;border=edge:5,type:mountain;'\
                       'border=edge:0,type:mountain;border=edge:1,type:mountain;'\
                       'border=edge:2,type:mountain',
            ['L26'] => 'border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['M23'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain',
          },
          red: {
            ['A9'] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,groups:W;'\
                      'border=edge:4;path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:5;label=W;icon=image:1868_wy/120',
            ['A11'] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,hide:1,groups:W;'\
                       'border=edge:1;path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:5;label=W;icon=image:1868_wy/120',
            ['A15'] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,groups:W;'\
                       'path=a:_0,b:1;path=a:_0,b:5;label=W;icon=image:1868_wy/60',
            ['E27'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:E;'\
                       'path=a:_0,b:1;label=E;icon=image:1868_wy/10;',
            ['E1'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:W;'\
                      'path=a:_0,b:5;label=W;icon=image:1868_wy/-10;',
            ['K27'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30,groups:E;'\
                       'path=a:_0,b:2;label=E;icon=image:1868_wy/10',
            ['M1'] => 'offboard=revenue:yellow_20|green_20|brown_20|gray_30,groups:W;'\
                      'path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4;border=edge:3,type:mountain,cost:30;'\
                      'border=edge:4,type:mountain,cost:30;label=W;icon=image:1868_wy/180',
            ['M27'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:E;path=a:_0,b:1;'\
                       'path=a:_0,b:2;border=edge:2,type:mountain;label=E;icon=image:1868_wy/30;',
            ['N18'] => 'city=revenue:yellow_0|green_40|brown_30|gray_0,loc:2.5;path=a:_0,b:2;path=a:_0,b:3',
            ['N26'] => 'offboard=revenue:yellow_0|green_20|brown_40|gray_50,groups:E;'\
                       'path=a:_0,b:2;label=E;icon=image:1868_wy/10;',
            ['B2'] => 'border=edge:4;border=edge:5',
            ['B4'] => 'border=edge:0;border=edge:1;border=edge:5',
            ['C3'] => 'border=edge:0;border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            ['C5'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3;'\
                      'border=edge:5;town=revenue:yellow_20|green_30|brown_30|gray_40,loc:4;path=a:_0,b:4',
            ['D2'] => 'border=edge:3;border=edge:4',
            ['D4'] => 'border=edge:1;border=edge:2;border=edge:3;town=revenue:yellow_20|green_30|brown_30|gray_40,loc:0;'\
                      'path=a:_0,b:0',
          },
          purple: {
            ['D28'] => 'city=revenue:yellow_20|green_30|brown_40|gray_40,groups:E;'\
                       'path=a:_0,b:1,terminal:1;label=E;icon=image:1868_wy/20;',
          },
          gray: {
            %w[B6 C15 D6 D8 E9 F4 F6 H2 H8 L18 M15] => '',
            %w[A17 G7] => 'offboard=revenue:0;path=a:_0,b:0',
            ['A1'] => 'town=revenue:0;path=a:_0,b:4;icon=image:1868_wy/golden_spike',
            %w[C7 E5] => 'path=a:1,b:4',
            %w[D16 K1] => 'offboard=revenue:0;path=a:_0,b:3',
            ['E3'] => 'junction;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['E7'] => 'path=a:1,b:5',
            ['F10'] => 'border=edge:4,type:water',
            ['F14'] => 'border=edge:1,type:impassable',
            ['F2'] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['G3'] => 'path=a:2,b:4',
            ['I1'] => 'offboard=revenue:0;path=a:_0,b:4;path=a:_0,b:5;',
            ['M19'] => 'town=revenue:10;path=a:_0,b:0;path=a:_0,b:4',
            ['L0'] => 'town=revenue:0,loc:5;junction;path=a:_0,b:5;path=a:_1,b:4,terminal:1;icon=image:1868_wy/golden_spike',
          },
        }.freeze

        TILES = {
          # yellow
          '3' => 'unlimited',
          '4' => 'unlimited',
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 'unlimited',
          '58' => 'unlimited',

          # green
          '14' => 'unlimited',
          '15' => 'unlimited',
          '17' => 'unlimited',
          '18' => 'unlimited',
          '21' => 'unlimited',
          '22' => 'unlimited',
          '141' => 'unlimited',
          '142' => 'unlimited',
          '143' => 'unlimited',
          '144' => 'unlimited',
          '619' => 'unlimited',
          '625' => 'unlimited',
          '626' => 'unlimited',

          # brown
          '611' => 2,

          # gray
          '51' => 2,

          # custom yellow
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
            'code' => 'city=revenue:#FFFFFF_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:1',
          },
          'Y6b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center;path=a:_0,b:0;path=a:_0,b:2',
          },
          'Y6B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:#FFFFFF_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:2',
          },
          'Y57b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center;path=a:_0,b:0;path=a:_0,b:3',
          },
          'Y57B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:#FFFFFF_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:3',
          },

          # custom green
          '16' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'path=a:0,b:2;path=a:1,b:3;label=$20',
          },
          '19' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'path=a:0,b:3;path=a:2,b:4;label=$20',
          },
          '20' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'path=a:0,b:3;path=a:1,b:4;label=$20',
          },
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
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;'\
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
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:3;',
          },
          '619B' => {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4;',
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
          'B5b' => {
            'count' => 8,
            'color' => 'brown',
            'code' => 'town=revenue:20,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'B5BB' => {
            'count' => 8,
            'color' => 'brown',
            'code' => 'city=revenue:#FFFFFF_20|brown_40|black_50,slots:2,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },

          # ghost town tiles
          'GT' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'white',
            'code' => '',
          },
          'GT544' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'GT545' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:5',
          },
          'GT546' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4',
          },
          'GT5' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },

          # custom gray
          '5b' => {
            'count' => 4,
            'color' => 'gray',
            'code' => 'town=revenue:20,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          '5BB' => {
            'count' => 4,
            'color' => 'gray',
            'code' => 'city=revenue:#FFFFFF_20|gray_50|black_60,boom:1,slots:2;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },

          'L0-spike' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'offboard=revenue:0;path=a:_0,b:4',
            'hidden' => 1,
          },
          'A1-spike' => {
            'count' => 1,
            'color' => 'gray',
            'code' => '',
            'hidden' => 1,
          },

          # custom red
          'Billings-a' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_20|green_40|brown_50|gray_60,groups:W;'\
                      'path=a:_0,b:0;path=a:_0,b:5;label=W;icon=image:1868_wy/40;',
          },
          'Billings-b' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_20|green_40|brown_50|gray_60,hide:1,groups:W;'\
                      'path=a:_0,b:0;path=a:_0,b:5;label=W;icon=image:1868_wy/40;',
          },
          'Billings-c' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_20|green_40|brown_50|gray_60,groups:W;'\
                      'path=a:_0,b:5;label=W;icon=image:1868_wy/20;',
          },
          'Ogden' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=groups:Billings,revenue:yellow_30|green_40|brown_50|gray_60,groups:W;'\
                      'path=a:_0,b:3;path=a:_0,b:4;label=W;icon=image:1868_wy/50;',
          },
        }.freeze

        TILE_UPGRADES = {
          # town + city -> city
          'YG' => ['GG'],
          'YL' => ['GL'],

          # Green -> Brown Boomtown
          '14b' => ['B5b'],
          '15b' => ['B5b'],
          '619b' => ['B5b'],

          # Green -> Brown Boom City
          '14B' => ['B5BB'],
          '15B' => ['B5BB'],
          '619B' => ['B5BB'],

          # Brown -> Gray Boomtown
          'B5b' => ['5b'],

          # Brown -> Gray Boom City
          'B5BB' => ['5BB'],
        }.freeze

        BOOMTOWN_TO_BOOMCITY_TILES = {
          # yellow
          'Y5b' => 'Y5B',
          'Y6b' => 'Y6B',
          'Y57b' => 'Y57B',

          # green
          '14b' => '14B',
          '15b' => '15B',
          '619b' => '619B',

          # brown
          'B5b' => 'B5BB',

          # gray
          '5b' => '5BB',
        }.freeze

        BOOMCITY_TO_BOOMTOWN_TILES = {
          # yellow
          'Y5B' => 'Y5b',
          'Y6B' => 'Y6b',
          'Y57B' => 'Y57b',

          # green
          '14B' => '14b',
          '15B' => '15b',
          '619B' => '619b',

          # brown
          'B5BB' => 'B5b',

          # gray
          '5BB' => '5b',
        }.freeze

        TILE_GROUPS = [
          %w[YC],
          %w[YL],
          %w[YG],
          %w[Y5b Y5B],
          %w[Y6b Y6B],
          %w[Y57b Y57B],
          %w[3],
          %w[4],
          %w[5],
          %w[6],
          %w[7],
          %w[8],
          %w[9],
          %w[57],
          %w[58],
          %w[GC],
          %w[GL],
          %w[GG],
          %w[14],
          %w[14b 14B],
          %w[15],
          %w[15b 15B],
          %w[619],
          %w[619b 619B],
          %w[16],
          %w[17],
          %w[18],
          %w[19],
          %w[20],
          %w[21],
          %w[22],
          %w[625],
          %w[626],
          %w[141],
          %w[142],
          %w[143],
          %w[144],

          %w[BC],
          %w[BL],
          %w[BG],
          %w[611],
          %w[B5b B5BB],

          %w[51],
          %w[5b 5BB],

          %w[Billings-a],
          %w[Billings-b],
          %w[Billings-c],
          %w[Ogden],

          %w[L0-spike],
          %w[A1-spike],

          %w[GT],
          %w[GT544],
          %w[GT545],
          %w[GT546],
          %w[GT5],
        ].freeze

        GHOST_TOWN_TILE = {
          'Y5b' => '7',
          'Y5B' => '7',
          'Y6b' => '8',
          'Y6B' => '8',
          'Y57b' => '9',
          'Y57B' => '9',

          '14b' => 'GT544',
          '14B' => 'GT544',
          '15b' => 'GT545',
          '15B' => 'GT545',
          '619b' => 'GT546',
          '619B' => 'GT546',

          'B5b' => 'GT5',
          'B5BB' => 'GT5',

          '5b' => 'GT5',
          '5BB' => 'GT5',
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'Independence Creek / Northern Spike',
          'A11' => 'Billings',
          'A15' => 'Billings',
          'B10' => 'Powell',
          'B16' => 'Sheridan',
          'C11' => 'Greybull & Basin',
          'C17' => 'Buffalo',
          'C23' => "Devil's Tower",
          'C3' => 'Yellowstone National Park',
          'C5' => 'East Entrance',
          'C9' => 'Cody',
          'D12' => 'Worland',
          'D20' => 'Donkey Town',
          'D24' => 'Sundance',
          'D28' => 'Rapid City',
          'D4' => 'South Entrance',
          'E1' => 'Oregon (via Idaho)',
          'E11' => 'Thermopolis',
          'E17' => 'Kaycee',
          'E27' => 'Black Hills',
          'F12' => 'Wind River Canyon',
          'F18' => 'Midwest',
          'F2' => 'Jackson',
          'F22' => 'Bill',
          'G11' => 'Shoshoni',
          'G9' => 'Riverton',
          'H10' => 'Lander',
          'H18' => 'Casper',
          'H22' => 'Douglas',
          'H6' => 'Pinedale',
          'I3' => 'Cokeville',
          'I9' => 'South Pass City',
          'J2' => 'Kemmerer',
          'J6' => 'Granger',
          'J12' => 'Jeffrey City',
          'J20' => 'Shirley Basin',
          'J26' => 'Fort Laramie',
          'K15' => 'Rawlins',
          'K17' => 'Hanna',
          'K19' => 'Medicine Bow',
          'K27' => 'Scottsbluff',
          'L0' => 'Promontory Summit / Golden Spike',
          'L2' => 'Bear River City',
          'L4' => 'Fort Bridger',
          'L8' => 'Green River',
          'L10' => 'Rock Springs',
          'L16' => 'Saratoga',
          'M1' => 'Ogden',
          'M19' => 'Centennial',
          'M21' => 'Laramie',
          'M23' => 'Sherman',
          'M25' => 'Cheyenne',
          'M27' => 'Omaha',
          'N18' => 'Walden',
          'N26' => 'Denver',
        }.freeze
      end
    end
  end
end
