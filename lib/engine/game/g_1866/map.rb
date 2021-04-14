# frozen_string_literal: true

module Engine
  module Game
    module G1866
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 6,
          '4' => 12,
          '5' => 10,
          '6' => 15,
          '7' => 10,
          '8' => 25,
          '9' => 25,
          '55' => 1,
          '56' => 1,
          '57' => 15,
          '58' => 12,
          '69' => 1,
          '201' => 4,
          '202' => 4,
          '621' => 4,
          '14' => 12,
          '15' => 16,
          '80' => 6,
          '81' => 6,
          '82' => 8,
          '83' => 8,
          '141' => 8,
          '142' => 8,
          '143' => 8,
          '144' => 8,
          '207' => 8,
          '208' => 6,
          '619' => 12,
          '622' => 6,
          '63' => 20,
          '216' => 3,
          '448' => 12,
          '544' => 8,
          '545' => 8,
          '546' => 8,
          '611' => 6,
          '767' => 8,
          '768' => 8,
          '769' => 8,
          '51' => 8,
          '60' => 4,
          '895' => 20,
          '912' => 4,
          'X1' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
          'X2' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=Y',
            },
          '169' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          '512' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=Y',
            },
          'X3' =>
            {
              'count' => 12,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X4' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
          'X5' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=Y',
            },
          'X6' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'B1' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'B2' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'B3' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
          'L1' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:0,b:_0;path=a:2,b:_0;upgrade=cost:40;label=L',
            },
          'L2' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;upgrade=cost:40;label=L',
            },
          'L3' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;upgrade=cost:40;label=L',
            },
          'L4' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:90,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'upgrade=cost:40;label=L',
            },
          'L5' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:90,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                'upgrade=cost:40;label=L',
            },
          'L6' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:90,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                'upgrade=cost:40;label=L',
            },
          'L7' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:120,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                'label=L',
            },
          'C1' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C2' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C3' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C4' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:30,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C5' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:30,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:30,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
          'C6' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C7' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C8' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C9' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:50,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C10' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:50,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:50,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
          'C11' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C12' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C13' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C14' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:70,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C15' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:70,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:70,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
          'C16' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C17' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C18' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C19' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:90,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C20' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:90,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:90,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
        }.freeze

        LOCATION_NAMES = {
          'A3' => 'Scotland',
          'D2' => 'Liverpool',
          'D4' => 'Manchester',
          'D6' => 'York',
          'E1' => 'Cardiff',
          'E3' => 'Birmingham',
          'E17' => 'Hamburg',
          'E19' => 'Lubeck',
          'E25' => 'Gdansk',
          'F2' => 'Bristol',
          'F6' => 'London',
          'F10' => 'Rotterdam',
          'F12' => 'Amsterdam',
          'F18' => 'Hannover',
          'F22' => 'Berlin',
          'G1' => 'Plymouth',
          'G3' => 'Southampton',
          'G9' => 'Bruges',
          'G11' => 'Antwerp',
          'H8' => 'Calais',
          'H10' => 'Brussels',
          'H12' => 'Liege',
          'H14' => 'Düsseldorf',
          'H20' => 'Leipzig',
          'H26' => 'Warsaw',
          'I1' => 'Brest',
          'I5' => 'Rouen',
          'I9' => 'Reims',
          'I11' => 'Luxembourg',
          'I15' => 'Frankfurt',
          'I23' => 'Dresden',
          'J6' => 'Paris',
          'J10' => 'Troyes',
          'J22' => 'Prague',
          'K1' => 'Nantes',
          'K3' => 'Tours',
          'K9' => 'Dijon',
          'K13' => 'Strasbourg',
          'K15' => 'Stuttgart',
          'K19' => 'Munich',
          'K25' => 'Brno',
          'L12' => 'Geneva',
          'L14' => 'Bern',
          'L16' => 'Zurich',
          'L18' => 'Innsbruck',
          'L24' => 'Vienna',
          'L26' => 'Bratislava',
          'M9' => 'Lyon',
          'M23' => 'Graz',
          'N2' => 'Bordeaux',
          'N12' => 'Turin',
          'N14' => 'Milan',
          'N18' => 'Venice',
          'N22' => 'Lubjiana',
          'N26' => 'Budapest',
          'O1' => 'Bilbao',
          'O5' => 'Toulouse',
          'O7' => 'Montpelier',
          'O13' => 'Genoa',
          'O21' => 'Rejka',
          'O23' => 'Zagreb',
          'P10' => 'Marseilles',
          'P12' => 'Nice',
          'P18' => 'Bologna',
          'P26' => 'Belgrade',
          'Q3' => 'Barcelona',
          'Q17' => 'Florence',
          'Q19' => 'San Marino',
          'Q25' => 'Sarajevo',
          'R0' => 'Madrid',
          'R18' => 'Rome',
          'S1' => 'Valencia',
          'S23' => 'Bari',
          'T12' => 'Cagliari',
          'T20' => 'Naples',
          'V18' => 'Palermo',
          'V20' => 'Catania',
        }.freeze

        HEXES = {
          white: {
            %w[E5 E21 F14 F16 F20 G17 G21 G23 H16 H18 H24 I7 I17 I19 I21 I25 J4 J8 J14 J20 J24 K7 K17
               L2 L4 L6 L10 L20 N4 N8 N24 O25 Q1 S13 T22] =>
              '',
            ['E7'] =>
              'border=edge:2,type:impassable;border=edge:5,type:impassable',
            ['G5'] =>
              'border=edge:0,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['H6'] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[E23 G13 G25 M25 O9 P8 P24] =>
              'upgrade=cost:20,terrain:swamp',
            %w[B2 C5 K11 M5 M7 M21 N6 P2 S19] =>
              'upgrade=cost:60,terrain:hill',
            %w[M17 M19 N16 O11 Q5] =>
              'upgrade=cost:90,terrain:mountain',
            %w[M13 M15 O3 P4] =>
              'upgrade=cost:120,terrain:mountain',
            %w[C3 D18 E13 E15 F4 H22 J2 J16 K23 L8 M3 P6 Q13 R2 S21 U21 W19] =>
              'town=revenue:0',
            %w[G15 J12 J18 K5] =>
              'town=revenue:0;town=revenue:0',
            ['G19'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:swamp',
            %w[I3 T24] =>
              'town=revenue:0;border=edge:3,type:impassable',
            %w[F24 I13 K21 L22 O15] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp',
            ['O17'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp',
            %w[B4 N20 P16 P22 Q23 R20] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill',
            ['R24'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;border=edge:0,type:impassable;border=edge:5,type:impassable',
            %w[M11 N10] =>
              'town=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[D2 E1 E3 G1 E19 E25 H12 I1 I9 I15 I23 J10 K9 K19 K25 L18 M9 N12 N14 N22 O5 O13 O21 O23
               P18 Q17 S1 T20 V18] =>
              'city=revenue:0',
            %w[F22 R18] =>
              'city=revenue:0;label=C',
            %w[H10 I11 J22 Q3 T12] =>
              'city=revenue:0;label=Y',
            %w[F18 H14 H20 K1 K3 K13] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp',
            ['I5'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:2,type:impassable',
            %w[J6 L24] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=C',
            ['N18'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=Y',
            %w[F2 E17 G11] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp',
            ['F10'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:1,type:impassable',
            ['F12'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;label=Y',
            ['N2'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:0,type:impassable;label=Y',
            %w[M23 O7 P12 Q19 Q25 V20] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill',
            %w[D4 K15 P10] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;label=Y',
            %w[L14 L16] =>
              'city=revenue:0;upgrade=cost:90,terrain:mountain',
            ['L12'] =>
              'city=revenue:0;upgrade=cost:90,terrain:mountain;label=C',
            ['H8'] =>
              'city=revenue:0;border=edge:2,type:impassable',
            ['O1'] =>
              'city=revenue:0;border=edge:3,type:impassable;label=B',
            %w[D6 G3] =>
              'city=revenue:0;border=edge:5,type:impassable',
            ['G9'] =>
              'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['S23'] =>
              'city=revenue:0;border=edge:3,type:impassable;border=edge:4,type:impassable;label=Y',
            ['F6'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:4,type:impassable;'\
              'border=edge:5,type:impassable;label=L',
          },
          green: {
            ['G7'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable;'\
              'border=edge:4,type:impassable;border=edge:5,type:impassable;stub=edge:2;stub=edge:5;upgrade=cost:50',
            ['S25'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable;'\
              'stub=edge:1;stub=edge:2;upgrade=cost:20',
          },
          brown: {
            ['F8'] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:4,type:impassable;'\
              'border=edge:5,type:impassable;stub=edge:2;stub=edge:4;upgrade=cost:50',
            ['H4'] =>
              'border=edge:0,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable;'\
              'border=edge:4,type:impassable;border=edge:5,type:impassable;stub=edge:0;stub=edge:2;upgrade=cost:50',
          },
          gray: {
            ['A3'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['H26'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            %w[L26 P26] =>
              'city=revenue:yellow_10|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['N26'] =>
              'city=revenue:yellow_20|green_40|brown_50|gray_60,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['R0'] =>
              'city=revenue:yellow_30|green_50|brown_70|gray_90,slots:1;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[F26 J26] =>
              'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            %w[J0 P0] =>
              'junction;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          blue: {
            %w[C7 E11] =>
              'junction;path=a:0,b:_0,terminal:1',
            ['S3'] =>
              'junction;path=a:1,b:_0,terminal:1',
            %w[T2 U13] =>
              'junction;path=a:2,b:_0,terminal:1',
            %w[F0 H0 S17 Q11 W17] =>
              'junction;path=a:3,b:_0,terminal:1',
            %w[D24 M1 R22 S11] =>
              'junction;path=a:5,b:_0,terminal:1',
            ['H2'] =>
              'junction;path=a:0,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['U19'] =>
              'junction;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['P14'] =>
              'path=a:2,b:5;border=edge:5',
            ['Q15'] =>
              'path=a:0,b:2;border=edge:0;border=edge:2;border=edge:5',
            ['R12'] =>
              'path=a:3,b:5',
            ['R14'] =>
              'junction;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:3;border=edge:4',
            ['R16'] =>
              'path=a:1,b:4;border=edge:1;border=edge:2',
            ['T14'] =>
              'path=a:1,b:4;border=edge:4',
            ['T16'] =>
              'path=a:1,b:4;border=edge:1;border=edge:4',
            ['T18'] =>
              'path=a:1,b:4;border=edge:1',
          },
        }.freeze
      end
    end
  end
end
