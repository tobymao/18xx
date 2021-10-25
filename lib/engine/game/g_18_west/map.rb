# frozen_string_literal: true

module Engine
  module Game
    module G18West
      module Map
        TILES = {
          '4' => 6,
          '6' => 3,
          '8' => 21,
          '9' => 33,
          '14' => 4,
          '15' => 10,
          '57' => 3,
          '58' => 6,
          '63' => 7,
          '80' => 3,
          '81' => 3,
          '82' => 7,
          '83' => 7,
          '131' => 1,
          '141' => 4,
          '142' => 4,
          '143' => 3,
          '144' => 3,
          '243' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:4,b:_1;label=SF',
          },
          '246' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SF',
          },
          '251' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1;label=Chi',
          },
          '252' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1;label=M-K',
          },
          '253' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SD',
          },
          '254' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_0;label=StL',
          },
          '255' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Chi',
          },
          '256' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          '257' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SD',
          },
          '258' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=StL',
          },
          '259' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=D',
          },
          '260' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          '261' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SF',
          },
          '262' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=StL',
          },
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Seattle',
          'B3' => 'Portland',
          'B23' => 'Mesabi Range',
          'C2' => 'Eugene',
          'C10' => 'Helena',
          'C24' => 'Duluth',
          'D7' => 'Boise',
          'D23' => 'Minneapolis St. Paul',
          'E26' => 'Milwaukee',
          'F3' => 'Sacramento',
          'F9' => 'Salt Lake City',
          'F15' => 'Cheyenne',
          'F21' => 'Omaha',
          'F23' => 'Des Moines',
          'F25' => 'Cedar Rapids',
          'F27' => 'Chicago',
          'G2' => 'San Francisco',
          'G22' => 'Kansas City Topeka',
          'G26' => 'Springfield',
          'G28' => 'New York',
          'H13' => 'CMD',
          'H23' => 'Springfield',
          'H25' => 'St. Louis',
          'I4' => 'Los Angeles',
          'I14' => 'Santa Fe',
          'I26' => 'Memphis',
          'J5' => 'San Diego',
          'J25' => 'Little Rock',
          'K8' => 'Tucson',
          'K20' => 'Dallas Ft. Worth',
          'K24' => 'Shreveport',
          'L19' => 'Austin and San Antonio',
          'L21' => 'Houston',
          'L25' => 'New Orleans',
          'M20' => 'Corpus Christi',
          'M22' => 'Galveston',
        }.freeze

        LAYOUT = :pointy

        HEXES = {
          white: {
            %w[
              B7 B13 B15 B17 B19 B21 C14 C16 C18 C20 D1 D5 D17 D19 D21 D25 E16 E18 E20 E22 E24 F1 G16 G18 G24 H17 H19 I6
              I10 I16 I18 I20 I22 J15 J17 J19 J21 J23 K14 K16 K22 L13 L15 L17
            ] => '',
            %w[F5 F7 F11 F13 F17 F19] => 'path=a:1,b:4;',
            %w[C22] => 'offboard=revenue:0;path=a:5,b:_0;',
            %w[G20 K18] => 'offboard=revenue:0;path=a:4,b:_0;',
            %w[H3] => 'offboard=revenue:0;path=a:2,b:_0',
            %w[H21] => 'offboard=revenue:0;path=a:3,b:_0',
            %w[B5] => 'offboard=revenue:0;path=a:2,b:_0;upgrade=cost:40,terrain:mountain',
            %w[C2 C24 F23 K8] => 'town=revenue:0',
            %w[C10 D7 I14] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[J25 K24] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[
              B9 B11 C4 C6 C8 C12 D3 D9 D11 D13 D15 E2 E4 E6 E8 E10 E12 E14 G4 G6 G8 G10 G12 H5 H7 H9 H11 H15 I8 I12 I24 J7 J9
              J11 J13 K10 K12
            ] => 'upgrade=cost:40,terrain:mountain',
            %w[L23] => 'upgrade=cost:20,terrain:water',
            %w[G26 H23 L19] => 'city=revenue:0',
          },
          yellow: {
            ['B3'] => 'city=revenue:10;path=a:3,b:_0;path=a:5,b:_0',
            ['D23'] => 'city=revenue:10,loc:0;city=revenue:10,loc:3;path=a:1,b:_0;path=a:2,b:_1;label=M-K',
            ['E26'] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0',
            ['F3'] => 'city=revenue:20;path=a:0,b:_0;path=a:4,b:_0',
            %w[F9 F15] => 'town=revenue:10;path=a:1,b:_0;path=a:4,b:_0',
            ['F21'] => 'city=revenue:10;path=a:1,b:_0',
            ['F25'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            ['F27'] => 'city=revenue:40,loc:0;city=revenue:40,loc:3;path=a:1,b:_0;path=a:2,b:_1;label=Chi',
            ['G2'] => 'city=revenue:30;city=revenue:30;path=a:3,b:_0;path=a:5,b:_1;label=SF',
            ['G14'] => 'city=revenue:10;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=D',
            ['G22'] => 'city=revenue:10,loc:5;city=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_1;label=M-K',
            ['H25'] => 'city=revenue:40,loc:2;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:5,b:_1;label=StL',
            ['I4'] => 'city=revenue:10;city=revenue:10;path=a:2,b:_1;path=a:4,b:_0;path=a:5,b:_1;label=LA',
            ['J5'] => 'city=revenue:10,loc:0;path=a:2,b:_0;path=a:4,b:_0;path=a:2,b:4;label=SD',
            ['K20'] => 'city=revenue:10;path=a:1,b:_0;label=D',
            ['L21'] => 'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=D',
          },
          green: {
            ['I26'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          gray: {
            ['B23'] => 'town=revenue:yellow_10|brown_40|gray_50;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['H13'] => 'town=revenue:yellow_30|brown_10|gray_0;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                       'path=a:4,b:_0;path=a:5,b:_0',
            ['M20'] => 'town=revenue:10;path=a:3,b:_0',
            ['M22'] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
          },
          red: {
            ['A4'] => 'city=revenue:yellow_20|brown_40|gray_60;path=a:0,b:_0;path=a:5,b:_0',
            ['F29'] => 'offboard=revenue:yellow_30|brown_50|gray_80,hide:1;path=a:1,b:_0;border=edge:0',
            ['G28'] => 'offboard=revenue:yellow_30|brown_50|gray_80;path=a:2,b:_0;border=edge:0;border=edge:3',
            ['H27'] => 'offboard=revenue:yellow_30|brown_50|gray_80,hide:1;path=a:0,b:_0;path=a:1,b:_0;border=edge:3',
            ['L25'] => 'offboard=revenue:yellow_40|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0',
          },
        }.freeze
      end
    end
  end
end
