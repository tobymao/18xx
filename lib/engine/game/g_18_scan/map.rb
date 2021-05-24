# frozen_string_literal: true

module Engine
  module Game
    module G18Scan
      module Map
        TILES = {
          '5' => 12,
          '8' => 8,
          '9' => 8,
          '15' => 6,
          '58' => 7,
          '80' => 3,
          '81' => 3,
          '82' => 3,
          '83' => 3,
          '121' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
              'city=revenue:50;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=COP',
            },
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '145' => 3,
          '146' => 3,
          '403' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
              'city=revenue:30,loc:center;town=revenue:10,loc:0;path=a:0,b:_1;'\
              'path=a:_1,b:_0;label=COP;upgrade=cost:40',
            },
          '544' => 3,
          '545' => 3,
          '546' => 4,
          '582' => 2,
          '584' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=COP',
            },
        }.freeze

        LOCATION_NAMES = {
          'A6' => 'Kiel',
          'B7' => 'Stettin',
          'C6' => 'Copenhagen & Odense',
          'D1' => 'Newcastle',
          'D3' => 'Stavanger',
          'D5' => 'Aarhus',
          'D7' => 'Malmö',
          'E2' => 'Bergen',
          'E4' => 'Kristiansand',
          'F5' => 'Götenborg',
          'G4' => 'Oslo',
          'G6' => 'Norrköping',
          'J5' => 'Gävle',
          'K2' => 'Trondheim',
          'K6' => 'Stockholm',
          'L3' => 'Östersund',
          'M6' => 'Turku',
          'M8' => 'Tallinn',
          'N7' => 'Helsinki',
          'O4' => 'Umeå',
          'O6' => 'Tampere',
          'P7' => 'Lahti',
          'Q8' => 'Vyborg',
          'R1' => 'Narvik',
          'R3' => 'Luleå',
          'S2' => 'Gällivare',
          'S4' => 'Oulu',
          'T1' => 'Kiruna',

        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          red: {
            ['A6'] => 'city=revenue:yellow_20|green_30|brown_50,slots:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['B7'] => 'city=revenue:yellow_10|green_30|brown_60,slots:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['D1'] => 'city=revenue:yellow_20|green_30|brown_80,slots:1;path=a:5,b:_0,terminal:1',
            ['M8'] => 'city=revenue:yellow_0|green_30|brown_60,slots:1;path=a:3,b:_0,terminal:1',
            ['Q8'] => 'city=revenue:yellow_30|green_50|brown_80,slots:1;path=a:2,b:_0,terminal:1',
            ['T1'] => 'town=revenue:yellow_10|green_50|brown_10;path=a:0,b:_0;path=a:1,b:_0',
          },
          blue: {
            ['L7'] => 'path=a:2,b:3,track:narrow',
          },
          white: {
            %w[B5 E6 F7 H5 H7 I4 I6 K4 N3 P3 Q6] => '',
            %w[F1 H1 J1 N1 P1 G2 I2 M2 O2 Q2 F3 H3 J3] => 'upgrade=cost:60,terrain:mountain',
            %w[G6 J5 L3 P7 R3] => 'town=revenue:0',
            %w[G4 N7 O6 S2] => 'city=revenue:0',
            ['K2'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            ['M6'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['C6'] => 'city=revenue:0;town=revenue:0,loc:1.5;upgrade=cost:40,terrain:water',
            ['D3'] => 'city=revenue:0;border=edge:3,type:impassable',
            ['D5'] => 'city=revenue:0;border=edge:3,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['D7'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['E2'] => 'city=revenue:0;border=edge:0,type:impassable',
            ['E4'] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['F5'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['L5'] => 'border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['M4'] => 'border=edge:5,type:impassable',
            ['N5'] => 'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['O4'] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['P5'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['Q4'] => 'border=edge:0,type:impassable;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['R1'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            ['R5'] => 'border=edge:2,type:impassable',
            ['S4'] => 'town=revenue:0;border=edge:1,type:impassable',
          },
          yellow: {
            ['K6'] => 'city=revenue:30,loc:0.5;city=revenue:30,loc:2.5;path=a:1,b:_0;path=a:2,b:_1;border=edge:4,type:impassable',
          },
        }.freeze
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
