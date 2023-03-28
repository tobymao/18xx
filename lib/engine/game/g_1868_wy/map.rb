# frozen_string_literal: true

# rubocop:disable Layout/LineLength

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
            ['J6'] => 'stub=edge:2;stub=edge:4;town=revenue:0,loc:2;city=revenue:0,loc:0;label=G;upgrade=cost:20,terrain:water;'\
                      'border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['M21'] => 'stub=edge:2;stub=edge:4;town=revenue:0,loc:4;city=revenue:0,loc:1;label=L',
            ['F12'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable;'\
                       'border=edge:5,type:impassable;border=edge:1,type:water;'\
                       'upgrade=cost:20,terrain:water;upgrade=cost:10,terrain:mountain;label=WRC',
            %w[B8 B18 C13 D10 D14 E21 F16 F20 G15 G17 G23 H12 H14 H16] => 'upgrade=cost:10,terrain:cow_skull,size:40',
            %w[K9 K11 K13 L12 L14 M11 M13] => 'upgrade=cost:20,terrain:cow_skull,size:40',
            %w[B10 D20 D24] => 'town=revenue:0,boom:1',
            ['B12'] => 'upgrade=cost:20,terrain:water;town=revenue:0',
            %w[B14 E15] => 'upgrade=cost:60,terrain:mountain',
            %w[B20 C21] => 'upgrade=cost:10,terrain:mountain',
            %w[B22 B24 D22 E23 F24 H24 I25 K5 L6 M5] => '',
            %w[C23 G19 H20] => 'upgrade=cost:20,terrain:mountain',
            %w[B26] => 'upgrade=cost:20,terrain:mountain;stub=edge:5',
            %w[C17] => 'town=revenue:0,boom:1;upgrade=cost:10,terrain:cow_skull,size:40;icon=image:1868_wy/fort,sticky:1',
            %w[C25] => 'upgrade=cost:20,terrain:mountain;stub=edge:4',
            %w[C11 D12] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:water',
            %w[F22] => 'town=revenue:0,boom:1;upgrade=cost:10,terrain:cow_skull,size:40',
            %w[C19 D18] => 'upgrade=cost:10,terrain:cow_skull,size:40;upgrade=cost:10,terrain:water',
            %w[D26] => 'stub=edge:3',
            %w[E11 G9 G11] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[E13] => 'upgrade=cost:10,terrain:cow_skull,size:40;border=edge:0,type:impassable',
            ['E17'] => 'town=revenue:0;upgrade=cost:10,terrain:cow_skull,size:40;upgrade=cost:10,terrain:water',
            ['E19'] => 'upgrade=cost:10,terrain:cow_skull,size:40;icon=image:1868_wy/fort,sticky:1',
            %w[E25] => 'stub=edge:4',
            ['F8'] => 'upgrade=cost:10,terrain:water;upgrade=cost:20,terrain:mountain;stub=edge:2',
            %w[F18] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:mountain',
            %w[F26] => 'stub=edge:5',
            %w[G5] => 'stub=edge:1;upgrade=cost:40,terrain:mountain;icon=image:1868_wy/fort,sticky:1',
            %w[G13] => 'upgrade=cost:10,terrain:cow_skull,size:40;border=edge:2,type:impassable',
            %w[G21] => 'upgrade=cost:10,terrain:cow_skull,size:40;icon=image:1868_wy/fort,sticky:1',
            %w[G25] => 'stub=edge:4',
            %w[H4 K21] => 'upgrade=cost:40,terrain:mountain',
            ['M7'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:water,cost:30',
            ['M9'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:water,cost:30',
            ['M17'] => 'upgrade=cost:20,terrain:mountain;stub=edge:5',
            ['H6'] => 'town=revenue:0,boom:1;upgrade=cost:30,terrain:mountain',
            %w[H22 K15] => 'town=revenue:0,boom:1;upgrade=cost:10,terrain:mountain',
            %w[H26] => 'stub=edge:3',
            ['I3'] =>
    'town=revenue:0,boom:1;upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I5'] =>
    'upgrade=cost:10,terrain:water;upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I7'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I9'] =>
    'town=revenue:0,boom:1;upgrade=cost:20,terrain:cow_skull,size:40;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I11'] => 'upgrade=cost:20,terrain:cow_skull,size:40;border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[I13 I15 I17] => 'upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I19'] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I21'] => 'upgrade=cost:50,terrain:mountain;border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['I23'] => 'upgrade=cost:10,terrain:mountain;border=edge:0,type:mountain',
            ['J2'] => 'town=revenue:0,boom:1;upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain',
            ['J4'] => 'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[J8 J14] =>
    'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['J16'] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:water,cost:30',
            ['J18'] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:1,type:water,cost:30',
            ['J10'] => 'upgrade=cost:20,terrain:cow_skull,size:40;border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['J12'] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:cow_skull,size:40;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain;'\
                       'icon=image:1868_wy/uranium_early,sticky:1;icon=image:1868_wy/uranium_early,sticky:1',
            ['J20'] => 'town=revenue:0,boom:1;upgrade=cost:30,terrain:mountain;'\
                       'border=edge:2,type:mountain;border=edge:3,type:mountain;icon=image:1868_wy/uranium_early,sticky:1',
            ['J22'] =>
    'upgrade=cost:60,terrain:mountain;border=edge:2,type:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['J24'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain',
            %w[J26 L4] => 'town=revenue:0;icon=image:1868_wy/fort,sticky:1',
            ['K3'] => 'upgrade=cost:30,terrain:mountain',
            ['M3'] => 'upgrade=cost:30,terrain:mountain;border=edge:1,type:mountain,cost:30;stub=edge:1',
            ['K7'] => 'upgrade=cost:20,terrain:water;upgrade=cost:20,terrain:mountain',
            ['K17'] => 'town=revenue:0,boom:1;upgrade=cost:30,terrain:mountain;icon=image:1868_wy/fort,sticky:1',
            ['K19'] => 'upgrade=cost:20,terrain:mountain',
            ['L10'] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:cow_skull,size:40',
            ['L16'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
            ['K23'] =>
    'upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            ['K25'] => 'border=edge:1,type:mountain',
            ['L2'] => 'city=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:0,type:mountain,cost:30',
            ['L8'] => 'town=revenue:0,boom:1;upgrade=cost:20,terrain:mountain;upgrade=cost:20,terrain:water;',
            ['L20'] => 'town=revenue:0;upgrade=cost:20,terrain:cow_skull,size:40',
            ['L22'] => 'upgrade=cost:60,terrain:mountain;border=edge:4,type:mountain',
            ['L24'] => 'border=edge:0,type:mountain;border=edge:5,type:mountain;'\
                       'border=edge:0,type:mountain;border=edge:1,type:mountain;'\
                       'border=edge:2,type:mountain',
            ['L26'] => 'border=edge:0,type:mountain;border=edge:5,type:mountain',

            ['M23'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain',
          },
          red: {
            ['A9'] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,groups:W;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:5;icon=image:1868_wy/120',
            ['A11'] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,hide:1,groups:W;'\
                       'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:5;icon=image:1868_wy/120',
            ['A15'] => 'offboard=groups:Billings,revenue:yellow_10|green_20|brown_30|gray_30,groups:W;'\
                       'path=a:_0,b:1;path=a:_0,b:5;icon=image:1868_wy/60',
            ['A23'] => 'offboard=revenue:yellow_40|green_30|brown_20|gray_20;path=a:_0,b:0;path=a:_0,b:5;icon=image:1868_wy/fort,sticky:1',
            ['E27'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:E;'\
                       'path=a:_0,b:1;label=E;icon=image:1868_wy/10;',
            ['E1'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:W;'\
                      'path=a:_0,b:5;label=W;icon=image:1868_wy/-10;',
            ['K27'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30,groups:E;'\
                       'path=a:_0,b:2;label=E;icon=image:1868_wy/10',
            ['M1'] => 'offboard=revenue:yellow_20|green_20|brown_20|gray_30,groups:W;'\
                      'path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4;border=edge:3,type:mountain,cost:30;'\
                      'border=edge:4,type:mountain,cost:30;icon=image:1868_wy/180',
            ['M27'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:E;path=a:_0,b:1;'\
                       'path=a:_0,b:2;border=edge:2,type:mountain;label=E;icon=image:1868_wy/30;',
            ['N18'] => 'city=revenue:yellow_0|green_40|brown_30|gray_0,loc:2.5;path=a:_0,b:2;path=a:_0,b:3',
            ['N26'] => 'offboard=revenue:yellow_0|green_20|brown_40|gray_50,groups:E;'\
                       'path=a:_0,b:2;label=E;icon=image:1868_wy/10;',
            ['B2'] => 'border=edge:4;border=edge:5',
            ['B4'] => 'border=edge:0;border=edge:1;border=edge:5',
            ['C3'] => 'border=edge:0;border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            ['C5'] => 'border=edge:0;border=edge:1;border=edge:2;border=edge:3;'\
                      'border=edge:5;town=style:dot,revenue:yellow_20|green_30|brown_30|gray_40,loc:4.5;path=a:_0,b:4',
            ['D2'] => 'border=edge:3;border=edge:4',
            ['D4'] => 'border=edge:1;border=edge:2;border=edge:3;town=style:dot,revenue:yellow_20|green_30|brown_30|gray_40,loc:0;'\
                      'path=a:_0,b:0',
          },
          purple: {
            ['C27'] => 'city=revenue:yellow_20|green_30|brown_40|gray_40,groups:E;'\
                       'path=a:_0,b:0,terminal:1;path=a:_0,b:1,terminal:1;path=a:_0,b:2,terminal:1;'\
                       'label=E;icon=image:1868_wy/20;',
            ['G27'] => 'city=revenue:yellow_20|green_30|brown_30|gray_40,groups:E;'\
                       'path=a:_0,b:0,terminal:1;path=a:_0,b:1,terminal:1;path=a:_0,b:2,terminal:1;'\
                       'label=E;icon=image:1868_wy/10;',
          },
          gray: {
            %w[B6 C15 D6 D8 E9 F4 F6 H2 H8 L18 M15] => '',
            %w[A17 G7] => 'offboard=revenue:0;path=a:_0,b:0',
            ['A1'] => 'town=style:dot,revenue:0;path=a:_0,b:4;icon=image:1868_wy/golden_spike,large:1',
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
            ['L0'] => 'town=style:dot,revenue:0,loc:5;junction;path=a:_0,b:5;path=a:_1,b:4,terminal:1;icon=image:1868_wy/golden_spike,large:1',
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

          # custom yellow-gray
          'WRC' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:2;label=WRC;stripes=color:gray',
          },

          # custom yellow
          'YC' => {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:_0,b:1;path=a:_0,b:4;label=C',
          },
          'YL' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0,loc:1;town=revenue:10,loc:center,style:dot;path=a:_1,b:2;path=a:_1,b:4;label=L',
          },
          'YG' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0,loc:0;town=revenue:10,loc:center,style:dot;path=a:_1,b:2;path=a:_1,b:4;label=G',
          },
          '5b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center,style:dot;path=a:_0,b:0;path=a:_0,b:1',
          },
          '5B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:#FFFFFF_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:1',
          },
          '6b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center,style:dot;path=a:_0,b:0;path=a:_0,b:2',
          },
          '6B' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:#FFFFFF_10|yellow_20|black_30,boom:1;path=a:_0,b:0;path=a:_0,b:2',
          },
          '57b' => {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'town=revenue:10,boom:1,loc:center,style:dot;path=a:_0,b:0;path=a:_0,b:3',
          },
          '57B' => {
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
                      'path=a:_0,b:0;path=a:_0,b:2;path=a:_0,b:4',
          },

          '12b' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'town=revenue:10,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '12B' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '13b' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'town=revenue:10,boom:1;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '13B' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '205b' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'town=revenue:10,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          '205B' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          '206b' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'town=revenue:10,boom:1;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          '206B' => {
            'color' => 'green',
            'count' => 'unlimited',
            'code' => 'city=revenue:#FFFFFF_10|green_30|black_40,boom:1;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
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
                      'path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4',
          },
          'BG' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;label=G;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4',
          },
          '449b' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'town=revenue:20,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '449B' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:#FFFFFF_20|brown_40|black_50,slots:2,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '448b' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'town=revenue:20,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          '448B' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:#FFFFFF_20|brown_40|black_50,slots:2,boom:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          '450b' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'town=revenue:20,boom:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '450B' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:#FFFFFF_20|brown_40|black_50,slots:2,boom:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },

          # ghost town tiles
          'gt' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'white',
            'code' => '',
          },
          '80g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '81g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '82g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          '83g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          '544g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          '545g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:5',
          },
          '546g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4',
          },
          '5g' => {
            'count' => 'unlimited',
            'hidden' => 1,
            'color' => 'gray',
            'code' => 'junction;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },

          # custom gray
          'RC' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=C;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          'RG' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:2;label=G;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4',
          },
          'RL' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;label=L;'\
                      'path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:3;path=a:_0,b:4',
          },
          '51b' => {
            'count' => 4,
            'color' => 'gray',
            'code' => 'town=revenue:20,boom:1;'\
                      'path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:2;path=a:_0,b:4;path=a:_0,b:5',
          },
          '51B' => {
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

        BOOMTOWN_TO_BOOMCITY_TILES = {
          # yellow
          '5b' => '5B',
          '6b' => '6B',
          '57b' => '57B',

          # green
          '12b' => '12B',
          '13b' => '13B',
          '205b' => '205B',
          '206b' => '206B',

          # brown
          '449b' => '449B',
          '448b' => '448B',
          '450b' => '450B',

          # gray
          '51b' => '51B',
        }.freeze

        BOOMCITY_TO_BOOMTOWN_TILES = {
          # yellow
          '5B' => '5b',
          '6B' => '6b',
          '57B' => '57b',

          # green
          '12B' => '12b',
          '13B' => '13b',
          '205B' => '205b',
          '206B' => '206b',

          # brown
          '449B' => '449b',
          '448B' => '448b',
          '450B' => '450b',

          # gray
          '51B' => '51b',
        }.freeze

        TILE_GROUPS = [
          %w[YC],
          %w[YL],
          %w[YG],
          %w[7],
          %w[8],
          %w[WRC],
          %w[9],
          %w[3],
          %w[4],
          %w[58],
          %w[5],
          %w[6],
          %w[57],
          %w[5b 5B],
          %w[6b 6B],
          %w[57b 57B],

          %w[GC],
          %w[GL],
          %w[GG],
          %w[17],
          %w[18],
          %w[21],
          %w[22],
          %w[625],
          %w[626],
          %w[16],
          %w[19],
          %w[20],
          %w[141],
          %w[142],
          %w[143],
          %w[144],
          %w[14],
          %w[15],
          %w[619],
          %w[12b 12B],
          %w[13b 13B],
          %w[205b 205B],
          %w[206b 206B],

          %w[BC],
          %w[BL],
          %w[BG],
          %w[611],
          %w[448b 448B],
          %w[449b 449B],
          %w[450b 450B],

          %w[RC],
          %w[RL],
          %w[RG],
          %w[51],
          %w[51b 51B],

          %w[Billings-a],
          %w[Billings-b],
          %w[Billings-c],
          %w[Ogden],

          %w[L0-spike],
          %w[A1-spike],

          %w[gt],
          %w[80g],
          %w[81g],
          %w[82g],
          %w[83g],
          %w[544g],
          %w[545g],
          %w[546g],
          %w[5g],
        ].freeze

        GHOST_TOWN_TILE = {
          # yellow
          '5b' => '7',
          '5B' => '7',
          '6b' => '8',
          '6B' => '8',
          '57b' => '9',
          '57B' => '9',

          # green
          '12b' => '80g',
          '12B' => '80g',
          '13b' => '81g',
          '13B' => '81g',
          '205b' => '82g',
          '205B' => '82g',
          '206b' => '83g',
          '206B' => '83g',

          # brown
          '448b' => '545g',
          '448B' => '545g',
          '449b' => '544g',
          '449B' => '544g',
          '450b' => '546g',
          '450B' => '546g',

          # gray
          '51b' => '5g',
          '51B' => '5g',
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'Independence Creek / Northern Spike',
          'A11' => 'Billings',
          'A15' => 'Billings',
          'A23' => 'Ft. Keogh / Miles City',
          'B10' => 'Powell',
          'B12' => 'Lovell',
          'B16' => 'Sheridan',
          'C11' => 'Greybull & Basin',
          'C17' => 'Ft. Phil Kearney / Buffalo',
          'C23' => "Devil's Tower",
          'C3' => 'Yellowstone National Park',
          'C5' => 'East Entrance',
          'C9' => 'Cody',
          'C27' => 'Rapid City',
          'D12' => 'Worland',
          'D20' => 'Donkey Town',
          'D24' => 'Sundance',
          'D4' => 'South Entrance',
          'E1' => 'Oregon (via Idaho)',
          'E11' => 'Thermopolis',
          'E17' => 'Kaycee',
          'E19' => 'Ft. Reno',
          'F12' => 'Wind River Canyon',
          'F18' => 'Midwest',
          'F2' => 'Jackson',
          'F22' => 'Bill',
          'E27' => 'Black Hills',
          'G5' => 'Ft. Bonneville',
          'G9' => 'Riverton',
          'G11' => 'Shoshoni',
          'G21' => 'Ft. Fetterman',
          'G27' => 'Chadron',
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
          'J26' => 'Ft. Laramie',
          'K15' => 'Rawlins',
          'K17' => 'Ft. Steele / Hanna',
          'L20' => 'Medicine Bow',
          'K27' => 'Scottsbluff',
          'L0' => 'Promontory Summit / Golden Spike',
          'L2' => 'Bear River City',
          'L4' => 'Ft. Bridger',
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
# rubocop:enable Layout/LineLength
