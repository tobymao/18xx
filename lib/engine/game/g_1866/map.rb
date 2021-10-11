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
          'C0' => 'America',
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
          'W9' => 'Africa',
        }.freeze

        HEXES = {
          white: {
            # Germany - Bavaria - I17 I19 J16 J18 J20 K17 K19 K21
            ['K19'] =>
              'city=revenue:0;frame=color:#8781bf',
            %w[I17 I19 J20 K17] =>
              'frame=color:#8781bf',
            ['J16'] =>
              'town=revenue:0;frame=color:#8781bf',
            ['J18'] =>
              'town=revenue:0;town=revenue:0;frame=color:#8781bf',
            ['K21'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;'\
              'frame=color:#8781bf',

            # Germany - Hannover - D18 E15 E17 E19 E21 F16 F18
            ['E19'] =>
              'city=revenue:0;frame=color:#a764a9',
            ['F18'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#a764a9',
            ['E17'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;frame=color:#a764a9',
            %w[E21 F16] =>
              'frame=color:#a764a9',
            %w[D18 E15] =>
              'town=revenue:0;frame=color:#a764a9',

            # Germany - Prussia - E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25
            ['E25'] =>
              'city=revenue:0;frame=color:#d0c1de',
            ['F22'] =>
              'city=revenue:0;label=C;frame=color:#d0c1de',
            ['H14'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#d0c1de',
            %w[F20 G17 G21 G23 H16 H18 H24 I25] =>
              'frame=color:#d0c1de',
            ['G15'] =>
              'town=revenue:0;town=revenue:0;frame=color:#d0c1de',
            ['G19'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#d0c1de',
            ['F24'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#d0c1de',
            %w[E23 G25] =>
              'upgrade=cost:20,terrain:swamp;frame=color:#d0c1de',

            # Germany - Saxony - H20 H22 I21 I23
            ['I23'] =>
              'city=revenue:0;frame=color:#bd8dbf',
            ['H20'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#bd8dbf',
            ['I21'] =>
              'frame=color:#bd8dbf',
            ['H22'] =>
              'town=revenue:0;frame=color:#bd8dbf',

            # Germany - Wurttemburg - I13 I15 J14 K15
            ['I15'] =>
              'city=revenue:0;frame=color:#855fa8',
            ['K15'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;label=Y;frame=color:#855fa8',
            ['J14'] =>
              'frame=color:#855fa8',
            ['I13'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#855fa8',

            # Italy - Kgdm 2 Sicilies - S21 S23 T20 T22 T24 U21 V18 V20 W19
            ['S23'] =>
              'city=revenue:0;border=edge:3,type:impassable;border=edge:4,type:impassable;label=Y;frame=color:#ffcfe5',
            %w[T20 V18] =>
              'city=revenue:0;frame=color:#ffcfe5',
            ['V20'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ffcfe5',
            ['T22'] =>
              'frame=color:#ffcfe5',
            ['T24'] =>
              'town=revenue:0;border=edge:3,type:impassable;frame=color:#ffcfe5',
            %w[S21 U21 W19] =>
              'town=revenue:0;frame=color:#ffcfe5',

            # Italy - Papal States - Q19 R18 R20 S19
            ['R18'] =>
              'city=revenue:0;label=C;frame=color:#f26eaa',
            ['Q19'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#f26eaa',
            ['R20'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#f26eaa',
            ['S19'] =>
              'upgrade=cost:60,terrain:hill;frame=color:#f26eaa',

            # Italy - Sardinia - N12 O13 O15 S13 T12
            %w[N12 O13] =>
              'city=revenue:0;frame=color:#f41097',
            ['T12'] =>
              'city=revenue:0;label=Y;frame=color:#f41097',
            ['S13'] =>
              'frame=color:#f41097',
            ['O15'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#f41097',

            # Italy - Tuscany - P16 Q17
            ['Q17'] =>
              'city=revenue:0;frame=color:#f996c3',
            ['P16'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#f996c3',

            # Italy - Lom-Venetia - M17 N14 N16 N18 N20 O17 P18
            %w[N14 P18] =>
              'city=revenue:0;frame=color:#ff7ffe',
            ['N18'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=Y;frame=color:#ff7ffe',
            ['O17'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp;frame=color:#ff7ffe',
            ['N20'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ff7ffe',
            %w[M17 N16] =>
              'upgrade=cost:90,terrain:mountain;frame=color:#ff7ffe',

            # Luxembourg - I11
            ['I11'] =>
              'city=revenue:0;label=Y;frame=color:#fecd04',

            # Astro-Hungary - J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
            #                 P22 P24 P26 Q23 Q25 R24
            %w[K25 L18 N22 O21 O23] =>
              'city=revenue:0;frame=color:#e2ceb6',
            ['J22'] =>
              'city=revenue:0;label=Y;frame=color:#e2ceb6',
            ['L24'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=C;frame=color:#e2ceb6',
            %w[M23 Q25] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#e2ceb6',
            %w[J24 L20 N24 O25] =>
              'frame=color:#e2ceb6',
            ['K23'] =>
              'town=revenue:0;frame=color:#e2ceb6',
            ['L22'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#e2ceb6',
            ['R24'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;border=edge:0,type:impassable;'\
              'border=edge:5,type:impassable;frame=color:#e2ceb6',
            %w[P22 Q23] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#e2ceb6',
            %w[M25 P24] =>
              'upgrade=cost:20,terrain:swamp;frame=color:#e2ceb6',
            ['M21'] =>
              'upgrade=cost:60,terrain:hill;frame=color:#e2ceb6',
            ['M19'] =>
              'upgrade=cost:90,terrain:mountain;frame=color:#e2ceb6',

            # Belgium - G9 G11 H10 H12
            ['G9'] =>
              'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable;frame=color:#7eff80',
            ['H12'] =>
              'city=revenue:0;frame=color:#7eff80',
            ['H10'] =>
              'city=revenue:0;label=Y;frame=color:#7eff80',
            ['G11'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;frame=color:#7eff80',

            # France - H6 H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
            #          M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13
            ['H6'] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable;'\
              'frame=color:#fffbcc',
            ['H8'] =>
              'city=revenue:0;border=edge:2,type:impassable;frame=color:#fffbcc',
            %w[I1 I9 J10 K9 M9 O5] =>
              'city=revenue:0;frame=color:#fffbcc',
            ['I5'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:2,type:impassable;frame=color:#fffbcc',
            %w[K1 K3 K13] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#fffbcc',
            ['J6'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=C;frame=color:#fffbcc',
            ['N2'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:0,type:impassable;label=Y;frame=color:#fffbcc',
            %w[O7 P12] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#fffbcc',
            ['P10'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;label=Y;frame=color:#fffbcc',
            %w[I7 J4 J8 K7 L2 L4 L6 L10 N4 N8] =>
              'frame=color:#fffbcc',
            ['I3'] =>
              'town=revenue:0;border=edge:3,type:impassable;frame=color:#fffbcc',
            %w[J2 L8 M3 P6 Q13] =>
              'town=revenue:0;frame=color:#fffbcc',
            %w[J12 K5] =>
              'town=revenue:0;town=revenue:0;frame=color:#fffbcc',
            %w[M11 N10] =>
              'town=revenue:0;upgrade=cost:120,terrain:mountain;frame=color:#fffbcc',
            %w[O9 P8] =>
              'upgrade=cost:20,terrain:swamp;frame=color:#fffbcc',
            %w[K11 M5 M7 N6] =>
              'upgrade=cost:60,terrain:hill;frame=color:#fffbcc',
            ['O11'] =>
              'upgrade=cost:90,terrain:mountain;frame=color:#fffbcc',
            ['O3'] =>
              'upgrade=cost:120,terrain:mountain;frame=color:#fffbcc',

            # Great Britain - A3 B2 B4 C3 C5 D2 D4 D6 E1 E3 E5 E7 F2 F4 F6 G1 G3 G5
            ['G5'] =>
              'border=edge:0,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable;'\
              'frame=color:#fde2c5',
            ['E7'] =>
              'border=edge:2,type:impassable;border=edge:5,type:impassable;frame=color:#fde2c5',
            %w[D6 G3] =>
              'city=revenue:0;border=edge:5,type:impassable;frame=color:#fde2c5',
            %w[D2 E1 E3 G1] =>
              'city=revenue:0;frame=color:#fde2c5',
            ['F2'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;frame=color:#fde2c5',
            ['F6'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:4,type:impassable;'\
              'border=edge:5,type:impassable;label=L;frame=color:#fde2c5',
            ['D4'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;label=Y;frame=color:#fde2c5',
            ['E5'] =>
              'frame=color:#fde2c5',
            %w[C3 F4] =>
              'town=revenue:0;frame=color:#fde2c5',
            ['B4'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#fde2c5',
            %w[B2 C5] =>
              'upgrade=cost:60,terrain:hill;frame=color:#fde2c5',

            # Netherlands - E13 F10 F12 F14 G13
            ['F10'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:1,type:impassable;frame=color:#f8931d',
            ['F12'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;label=Y;frame=color:#f8931d',
            ['F14'] =>
              'frame=color:#f8931d',
            ['E13'] =>
              'town=revenue:0;frame=color:#f8931d',
            ['G13'] =>
              'upgrade=cost:20,terrain:swamp;frame=color:#f8931d',

            # Spain - O1 P0 P2 P4 Q1 Q3 Q5 R0 R2 S1
            ['O1'] =>
              'city=revenue:0;border=edge:3,type:impassable;label=B;frame=color:#bea481',
            ['S1'] =>
              'city=revenue:0;frame=color:#bea481',
            ['Q3'] =>
              'city=revenue:0;label=Y;frame=color:#bea481',
            ['Q1'] =>
              'frame=color:#bea481',
            ['R2'] =>
              'town=revenue:0;frame=color:#bea481',
            ['P2'] =>
              'upgrade=cost:60,terrain:hill;frame=color:#bea481',
            ['Q5'] =>
              'upgrade=cost:90,terrain:mountain;frame=color:#bea481',
            ['P4'] =>
              'upgrade=cost:120,terrain:mountain;frame=color:#bea481',

            # Switzerland - L12 L14 L16 M13 M15
            %w[L14 L16] =>
              'city=revenue:0;upgrade=cost:90,terrain:mountain;frame=color:#d6cf81',
            ['L12'] =>
              'city=revenue:0;upgrade=cost:90,terrain:mountain;label=C;frame=color:#d6cf81',
            %w[M13 M15] =>
              'upgrade=cost:120,terrain:mountain;frame=color:#d6cf81',
          },
          green: {
            # Ferry tiles
            ['G7'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable;'\
              'border=edge:4,type:impassable;border=edge:5,type:impassable;stub=edge:2;stub=edge:5;upgrade=cost:50',
            ['S25'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable;'\
              'stub=edge:1;stub=edge:2;upgrade=cost:20',
          },
          brown: {
            # Ferry tiles
            ['F8'] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:4,type:impassable;'\
              'border=edge:5,type:impassable;stub=edge:2;stub=edge:4;upgrade=cost:50',
            ['H4'] =>
              'border=edge:0,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable;'\
              'border=edge:4,type:impassable;border=edge:5,type:impassable;stub=edge:0;stub=edge:2;upgrade=cost:50',
          },
          gray: {
            # Germany - Prussia
            ['F26'] =>
              'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;frame=color:#d0c1de',
            ['H26'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'frame=color:#d0c1de',

            # Astro-Hungary
            %w[L26 P26] =>
              'city=revenue:yellow_10|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'frame=color:#e2ceb6',
            ['N26'] =>
              'city=revenue:yellow_20|green_40|brown_50|gray_60,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'label=Y;frame=color:#e2ceb6',
            ['J26'] =>
              'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;frame=color:#e2ceb6',

            # France
            ['J0'] =>
              'junction;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#fffbcc',

            # Great Britain
            ['A3'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1;frame=color:#fde2c5',

            # Spain
            ['R0'] =>
              'city=revenue:yellow_30|green_50|brown_70|gray_90,slots:1;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
              'frame=color:#bea481',
            ['P0'] =>
              'junction;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#bea481',

            # Africa
            ['W9'] =>
              'city=revenue:yellow_30|green_50|brown_70|gray_100,slots:4;frame=color:#a67c52',

            # America
            ['C0'] =>
              'city=revenue:yellow_30|green_50|brown_70|gray_100,slots:4;frame=color:#a67c52',
          },
          blue: {
            # Water tiles
            %w[C7 E11] =>
              'junction;path=a:0,b:_0,terminal:1',
            ['S3'] =>
              'junction;path=a:1,b:_0,terminal:1',
            %w[T2 U13] =>
              'junction;path=a:2,b:_0,terminal:1',
            %w[F0 H0 Q11 W17] =>
              'junction;path=a:3,b:_0,terminal:1',
            ['R16'] =>
              'junction;path=a:4,b:_0,terminal:1',
            %w[D24 M1 R22 S11] =>
              'junction;path=a:5,b:_0,terminal:1',
            ['H2'] =>
              'junction;path=a:0,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['U19'] =>
              'junction;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['P14'] =>
              'path=a:2,b:5;border=edge:5',
            ['Q15'] =>
              'path=a:0,b:2;border=edge:0;border=edge:2',
            ['R12'] =>
              'path=a:3,b:5',
            ['R14'] =>
              'path=a:0,b:3;border=edge:3',
            ['S17'] =>
              'path=a:1,b:3;border=edge:1',
            %w[S15 T14] =>
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
