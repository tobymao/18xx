# frozen_string_literal: true

module Engine
  module Game
    module G1866
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 8,
          '4' => 8,
          '5' => 10,
          '6' => 11,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 10,
          '58' => 11,
          '69' => 1,
          '201' => 5,
          '202' => 4,
          '621' => 2,
          '14' => 6,
          '15' => 14,
          '80' => 3,
          '81' => 3,
          '82' => 6,
          '83' => 6,
          '141' => 6,
          '142' => 6,
          '143' => 3,
          '144' => 3,
          '207' => 6,
          '208' => 3,
          '619' => 10,
          '622' => 3,
          '63' => 8,
          '216' => 2,
          '448' => 6,
          '544' => 2,
          '545' => 2,
          '546' => 2,
          '611' => 4,
          '767' => 2,
          '768' => 2,
          '769' => 2,
          '51' => 6,
          '60' => 1,
          '895' => 11,
          '912' => 1,
          'X1' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
          'X2' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=Y',
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
              'count' => 7,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X4' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
            },
          'X5' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=Y',
            },
          'X6' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
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
              'color' => 'yellow',
              'code' =>
                'city=revenue:30,slots:1;path=a:1,b:_0;path=a:4,b:_0;'\
                'city=revenue:30,slots:1;path=a:2,b:_1;path=a:5,b:_1;'\
                'city=revenue:30,slots:1;path=a:0,b:_2;path=a:3,b:_2;label=C',
            },
          'C7' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C8' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C9' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C10' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:50,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C11' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:50,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:50,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
          'C12' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:1;path=a:1,b:_0;path=a:4,b:_0;'\
                'city=revenue:50,slots:1;path=a:2,b:_1;path=a:5,b:_1;'\
                'city=revenue:50,slots:1;path=a:0,b:_2;path=a:3,b:_2;label=C',
            },
          'C13' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C14' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C15' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C16' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:70,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C17' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:70,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:70,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
          'C18' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:70,slots:1;path=a:1,b:_0;path=a:4,b:_0;'\
                'city=revenue:70,slots:1;path=a:2,b:_1;path=a:5,b:_1;'\
                'city=revenue:70,slots:1;path=a:0,b:_2;path=a:3,b:_2;label=C',
            },
          'C19' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
            },
          'C20' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
            },
          'C21' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
            },
          'C22' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'city=revenue:90,slots:1;path=a:0,b:_1;path=a:5,b:_1;label=C',
            },
          'C23' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:1;path=a:1,b:_0;path=a:2,b:_0;'\
                'city=revenue:90,slots:1;path=a:3,b:_1;path=a:4,b:_1;'\
                'city=revenue:90,slots:1;path=a:0,b:_2;path=a:5,b:_2;label=C',
            },
          'C24' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:1;path=a:1,b:_0;path=a:4,b:_0;'\
                'city=revenue:90,slots:1;path=a:2,b:_1;path=a:5,b:_1;'\
                'city=revenue:90,slots:1;path=a:0,b:_2;path=a:3,b:_2;label=C',
            },
          'L1' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:90,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'label=L',
            },
        }.freeze

        LOCATION_NAMES = {
          'A18' => 'Prussia',
          'A20' => 'Hannover',
          'A22' => 'Bavaria',
          'A24' => 'Württemberg',
          'A26' => 'Saxony',
          'B17' => 'Kgdm 2 Sicilies',
          'B19' => 'Sardinia',
          'B21' => 'Lombardy-Venetia',
          'B23' => 'Papal States',
          'B25' => 'Tuscany',
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
          'O21' => 'Rejika',
          'O23' => 'Zagreb',
          'P10' => 'Marseilles',
          'P12' => 'Nice',
          'P18' => 'Bologna',
          'P26' => 'Belgrade',
          'Q17' => 'Florence',
          'Q19' => 'San Marino',
          'Q25' => 'Sarajevo',
          'R0' => 'Madrid',
          'R4' => 'Barcelona',
          'R18' => 'Rome',
          'S23' => 'Bari',
          'T2' => 'Valencia',
          'T12' => 'Cagliari',
          'T20' => 'Naples',
          'U1' => 'Murcia',
          'V18' => 'Palermo',
          'V20' => 'Catania',
          'B11' => 'Port Token Bonus',
          'U8' => 'Port Token Bonus',
        }.freeze

        HEXES = {
          white: {
            # Explaination
            ['A18'] =>
              'frame=color:#d9cde4',
            ['A20'] =>
              'frame=color:#a386be',
            ['A22'] =>
              'frame=color:#b8a2cd',
            ['A24'] =>
              'frame=color:#8e6aae',
            ['A26'] =>
              'frame=color:#78539a',
            ['B17'] =>
              'frame=color:#ffd8fe',
            ['B19'] =>
              'frame=color:#ff62fa',
            ['B21'] =>
              'frame=color:#ff7ffe,color2:#e2ceb6',
            ['B23'] =>
              'frame=color:#ff33f9',
            ['B25'] =>
              'frame=color:#ffa8fc',

            # Germany - Bavaria - I17 I19 J16 J18 J20 K17 K19 K21
            ['K19'] =>
              'city=revenue:0;frame=color:#b8a2cd',
            %w[I17 I19 J20 K17] =>
              'frame=color:#b8a2cd',
            ['J16'] =>
              'town=revenue:0;frame=color:#b8a2cd',
            ['J18'] =>
              'town=revenue:0;town=revenue:0;frame=color:#b8a2cd',
            ['K21'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;'\
              'frame=color:#b8a2cd',

            # Germany - Hannover - D18 E15 E17 E19 E21 F16 F18
            ['E19'] =>
              'city=revenue:0;frame=color:#a386be',
            ['F18'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#a386be',
            ['E17'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;icon=image:1866/port,sticky:1;frame=color:#a386be',
            %w[E21 F16] =>
              'frame=color:#a386be',
            %w[D18 E15] =>
              'town=revenue:0;frame=color:#a386be',

            # Germany - Prussia - E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25
            ['E25'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#d9cde4',
            ['F22'] =>
              'city=revenue:0;label=C;frame=color:#d9cde4',
            ['H14'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=Y;frame=color:#d9cde4',
            %w[F20 G17 G21 G23 H16 H18 H24 I25] =>
              'frame=color:#d9cde4',
            ['G15'] =>
              'town=revenue:0;town=revenue:0;frame=color:#d9cde4',
            ['G19'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#d9cde4',
            ['F24'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#d9cde4',
            %w[E23 G25] =>
              'upgrade=cost:20,terrain:swamp;frame=color:#d9cde4',

            # Germany - Saxony - H20 H22 I21 I23
            ['I23'] =>
              'city=revenue:0;frame=color:#78539a',
            ['H20'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#78539a',
            ['I21'] =>
              'frame=color:#78539a',
            ['H22'] =>
              'town=revenue:0;frame=color:#78539a',

            # Germany - Wurttemburg - I13 I15 J14 K15
            ['I15'] =>
              'city=revenue:0;frame=color:#8e6aae',
            ['K15'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;label=Y;frame=color:#8e6aae',
            ['J14'] =>
              'frame=color:#8e6aae',
            ['I13'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#8e6aae',

            # Italy - Kgdm 2 Sicilies - S21 S23 T20 T22 T24 U21 V18 V20 W19
            ['S23'] =>
              'city=revenue:0;border=edge:3,type:impassable;border=edge:4,type:impassable;label=Y;frame=color:#ffd8fe',
            ['T20'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#ffd8fe',
            ['V18'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#ffd8fe',
            ['V20'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ffd8fe',
            ['T22'] =>
              'frame=color:#ffd8fe',
            ['T24'] =>
              'town=revenue:0;border=edge:3,type:impassable;frame=color:#ffd8fe',
            %w[S21 U21 W19] =>
              'town=revenue:0;frame=color:#ffd8fe',

            # Italy - Papal States - Q19 R18 R20 S19
            ['R18'] =>
              'city=revenue:0;label=C;frame=color:#ff33f9',
            ['Q19'] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ff33f9',
            ['R20'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ff33f9',
            ['S19'] =>
              'upgrade=cost:60,terrain:hill;frame=color:#ff33f9',

            # Italy - Sardinia - N12 O13 O15 S13 T12
            ['N12'] =>
              'city=revenue:0;frame=color:#ff62fa',
            ['O13'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#ff62fa',
            ['T12'] =>
              'city=revenue:0;label=Y;icon=image:1866/port,sticky:1;frame=color:#ff62fa',
            ['S13'] =>
              'frame=color:#ff62fa',
            ['O15'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill;frame=color:#ff62fa',

            # Italy - Tuscany - P16 Q17
            ['Q17'] =>
              'city=revenue:0;frame=color:#ffa8fc',
            ['P16'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ffa8fc',

            # Italy - Lombardy-Venetia - M17 N14 N16 N18 N20 O17 P18
            %w[N14 P18] =>
              'city=revenue:0;frame=color:#ff7ffe,color2:#e2ceb6',
            ['N18'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=Y;icon=image:1866/port,sticky:1;'\
              'frame=color:#ff7ffe,color2:#e2ceb6',
            ['O17'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp;frame=color:#ff7ffe,color2:#e2ceb6',
            ['N20'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#ff7ffe,color2:#e2ceb6',
            ['N16'] =>
              'upgrade=cost:60,terrain:hill;frame=color:#ff7ffe,color2:#e2ceb6',
            ['M17'] =>
              'upgrade=cost:90,terrain:mountain;frame=color:#ff7ffe,color2:#e2ceb6',

            # Astro-Hungary - J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
            #                 P22 P24 P26 Q23 Q25 R24
            %w[K25 L18 N22 O23] =>
              'city=revenue:0;frame=color:#e2ceb6',
            ['O21'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#e2ceb6',
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

            # Benelux - E13 F10 F12 F14 G9 G11 G13 H10 H12 I11
            ['F10'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;border=edge:1,type:impassable;'\
              'icon=image:1866/port,sticky:1;frame=color:#7eff80',
            ['F12'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;label=Y;frame=color:#7eff80',
            ['G9'] =>
              'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable;frame=color:#7eff80',
            ['G11'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;frame=color:#7eff80',
            ['H10'] =>
              'city=revenue:0;label=C;frame=color:#7eff80',
            ['I11'] =>
              'city=revenue:0;frame=color:#7eff80',
            ['F14'] =>
              'frame=color:#7eff80',
            %w[H12 E13] =>
              'town=revenue:0;frame=color:#7eff80',
            ['G13'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#7eff80',

            # France - H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
            #          M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13
            %w[H8 I5] =>
              'city=revenue:0;border=edge:2,type:impassable;frame=color:#fffbcc',
            %w[I9 J10 K9 K13 M9 O5] =>
              'city=revenue:0;frame=color:#fffbcc',
            ['J6'] =>
              'city=revenue:0;label=C;frame=color:#fffbcc',
            ['I1'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#fffbcc',
            %w[K1 K3] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;frame=color:#fffbcc',
            ['N2'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;label=Y;icon=image:1866/port,sticky:1;'\
              'frame=color:#fffbcc',
            %w[O7 P12] =>
              'city=revenue:0;upgrade=cost:60,terrain:hill;frame=color:#fffbcc',
            ['P10'] =>
              'city=revenue:0;upgrade=cost:40,terrain:hill;label=Y;icon=image:1866/port,sticky:1;'\
              'frame=color:#fffbcc',
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
              'border=edge:0,type:impassable;border=edge:4,type:impassable;frame=color:#fde2c5',
            ['E7'] =>
              'border=edge:2,type:impassable;border=edge:5,type:impassable;frame=color:#fde2c5',
            %w[D6 G3] =>
              'city=revenue:0;border=edge:5,type:impassable;frame=color:#fde2c5',
            %w[E1 E3 G1] =>
              'city=revenue:0;frame=color:#fde2c5',
            ['D2'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#fde2c5',
            ['F2'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp;icon=image:1866/port,sticky:1;frame=color:#fde2c5',
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

            # Spain - P0 P2 P4 Q1 Q3 Q5 R2 R4 S1 S3 T2 U1
            ['T2'] =>
              'city=revenue:0;icon=image:1866/port,sticky:1;frame=color:#bea481',
            ['R4'] =>
              'city=revenue:0;label=Y;frame=color:#bea481',
            ['U1'] =>
              'city=revenue:0;frame=color:#bea481',
            %w[P0 Q1 Q3 S1 S3] =>
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
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:4,type:impassable;'\
              'border=edge:5,type:impassable;path=a:1,b:5',
            ['S25'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:2,type:impassable;'\
              'path=a:1,b:2',
          },
          brown: {
            # Ferry tiles
            ['F8'] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:4,type:impassable;'\
              'border=edge:5,type:impassable;path=a:2,b:4',
            ['H4'] =>
              'border=edge:0,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable;'\
              'border=edge:5,type:impassable;path=a:0,b:2',

            # London
            ['F6'] =>
              'city=revenue:yellow_30|green_50|brown_70;path=a:0,b:_0;'\
              'city=revenue:yellow_30|green_50|brown_70;path=a:1,b:_1;'\
              'city=revenue:yellow_30|green_50|brown_70;path=a:2,b:_2;'\
              'city=revenue:yellow_30|green_50|brown_70;path=a:3,b:_3;'\
              'border=edge:4,type:impassable;border=edge:5,type:impassable;'\
              'label=L;frame=color:#fde2c5',
          },
          gray: {
            # Germany - Prussia
            ['F26'] =>
              'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;frame=color:#d9cde4',
            ['H26'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'frame=color:#d9cde4',

            # Astro-Hungary
            %w[L26 P26] =>
              'city=revenue:yellow_10|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'frame=color:#e2ceb6',
            ['N26'] =>
              'city=revenue:yellow_20|green_40|brown_50|gray_60,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'frame=color:#e2ceb6',
            ['J26'] =>
              'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;frame=color:#e2ceb6',

            # France
            ['J0'] =>
              'junction;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#fffbcc',

            # Great Britain
            ['A3'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1;icon=image:1866/port,sticky:1;frame=color:#fde2c5',

            # Spain
            ['O1'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
              'icon=image:1866/port,sticky:1;frame=color:#bea481',
            ['R0'] =>
              'city=revenue:yellow_30|green_50|brown_70|gray_90,slots:1;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
              'frame=color:#bea481',
            ['T0'] =>
              'junction;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#bea481',
          },
          blue: {
            # Water tiles
            ['H6'] =>
              '',
            %w[C7 E11] =>
              'junction;path=a:0,b:_0,terminal:1',
            ['T4'] =>
              'junction;path=a:1,b:_0,terminal:1',
            %w[V2 U13] =>
              'junction;path=a:2,b:_0,terminal:1',
            %w[F0 H0 Q11 W17] =>
              'junction;path=a:3,b:_0,terminal:1',
            ['R16'] =>
              'junction;path=a:4,b:_0,terminal:1',
            %w[D24 M1 R22 S11] =>
              'junction;path=a:5,b:_0,terminal:1',
            ['H2'] =>
              'junction;path=a:0,b:_0,terminal:1;junction;path=a:2,b:_1,terminal:1',
            ['U19'] =>
              'junction;path=a:0,b:_0,terminal:1;junction;path=a:5,b:_1,terminal:1',
            ['U3'] =>
              'junction;path=a:1,b:_0,terminal:1;junction;path=a:2,b:_1,terminal:1',
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

            # Port bonus
            %w[B11 U8] =>
              'offboard=revenue:yellow_00|green_20|brown_30|gray_40;path=a:0,b:_0;'\
              'offboard=revenue:yellow_00|green_20|brown_30|gray_40;path=a:5,b:_0;'\
              'icon=image:1866/port,sticky:1',
          },
        }.freeze
      end
    end
  end
end
