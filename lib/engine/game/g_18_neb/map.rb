# frozen_string_literal: true

module Engine
  module Game
    module G18Neb
      module Map
        TILE_TYPE = :lawson

        # rubocop:disable Layout/LineLength
        TILES = {
          # Yellow
          '3a' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:1',
          },
          '4a' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:3',
          },
          '58a' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:2',
          },
          '7' => 4,
          '8' => 14,
          '9' => 14,

          # Green
          '80' => 2,
          '81' => 2,
          '82' => 6,
          '83' => 6,
          # Single City green tiles
          '226' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:1;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:6,b:_0',
          },
          '227' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:1;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:6,b:_0',
          },
          '228' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '229' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
          '407' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;path=a:5,b:_0;label=D',
          },

          # Brown
          '544' => 2,
          '545' => 2,
          '546' => 2,
          '611' => 6,
          '230' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
          '233' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LC',
          },
          '234' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=D',
          },

          # Gray
          '231' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
          '192' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
          '116' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=D',
          },
          '409' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
          '51' => 2,
        }.freeze
        # rubocop:enable Layout/LineLength

        LOCATION_NAMES = {
          'A5' => 'Powder River Basin',
          'A7' => 'West',
          'B2' => 'Pacific Northwest',
          'B6' => 'Scottsbluff',
          'C3' => 'Chadron',
          'C7' => 'Sidney',
          'C9' => 'Denver',
          'E7' => 'Sutherland',
          'F6' => 'North Platte',
          'G1' => 'Valentine',
          'G7' => 'Kearney',
          'G11' => 'McCook',
          'H8' => 'Grand Island',
          'H10' => 'Holdrege',
          'I3' => 'ONeill',
          'I5' => 'Norfolk',
          'J8' => 'Lincoln',
          'J12' => 'Beatrice',
          'K3' => 'South Sioux City',
          'K7' => 'Omaha',
          'L4' => 'Chicago Norh',
          'L6' => 'South Chicago',
          'L10' => 'Nebraska City',
          'L12' => 'Kansas City',
        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            # empty tiles
            %w[B4 B8 C5 D2 D4 D6 E3 E5 F2 F4 F8 F10 F12 G3 G5 G9 H2 H4 H6 H12 I7 I9 I11 J2 J4 J6 J10 K9 K11] => '',
            %w[K5 L8] => 'upgrade=cost:60,terrain:water',
            # town tiles
            %w[B6 C3 C7 E7 F6 G7 G11 H8 H10 I3 I5 J12] => 'town=revenue:0',
            %w[K3] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[J8] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[L10] => 'town=revenue:0;upgrade=cost:60,terrain:water',
          },
          yellow: {
            # city tiles
            ['C9'] => 'city=revenue:30;path=a:5,b:_0',
            # Omaha
            ['K7'] => 'city=revenue:30,loc:5;town=revenue:10,loc:4,to_city:1;path=a:1,b:_1;path=a:_1,b:4;path=a:1,b:_0;upgrade=cost:60,terrain:water',
          },
          gray: {
            ['D8'] => 'path=a:5,b:2',
            ['D10'] => 'path=a:4,b:2',
            ['E9'] => 'junction;path=a:5,b:_0;path=a:_0,b:2;path=a:_0,b:1;path=a:_0,b:3',
            ['I1'] => 'path=a:1,b:5',
            ['K1'] => 'path=a:1,b:6',
            ['K13'] => 'path=a:2,b:3',
            ['M9'] => 'path=a:2,b:1',
          },
          red: {
            # Powder River Basin
            ['A5'] => 'offboard=revenue:yellow_0|green_30|brown_60;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=W',
            # West
            ['A7'] => 'city=revenue:yellow_30|green_40|brown_50;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:3;label=W',
            # Pacific NW
            ['B2'] => 'offboard=revenue:yellow_30|green_40|brown_50;path=a:0,b:_0;path=a:5,b:_0;label=W',
            # Valentine
            ['G1'] => 'town=revenue:yellow_30|green_40|brown_50;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_0',
            # Chi North
            ['L4'] => 'city=revenue:yellow_30|green_50|brown_60;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;label=E',
            # South Chi
            ['L6'] => 'city=revenue:yellow_20|green_40|brown_60;path=a:2,b:_0,terminal:1;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;label=E',
            # KC
            ['L12'] => 'city=revenue:yellow_30|green_50|brown_60;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;label=E',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat
      end
    end
  end
end
