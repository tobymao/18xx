# frozen_string_literal: true

module Engine
  module Game
    module G18Hiawatha
      module Map
        LAYOUT = :pointy

        TILES = {
          # yellow
          '5' => 5,
          '6' => 5,
          '7' => 6,
          '8' => 6,
          '9' => 6,
          '57' => 5,
          'X00H' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=KEN',
          },
          # green
          '14' => 3,
          '15' => 3,
          '80' => 2,
          '81' => 2,
          '82' => 2,
          '83' => 2,
          '619' => 3,
          '592H' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=CHI',
          },
          '592H2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=KEN',
          },
          # brown
          '63' => 3,
          '448' => 2,
          '544' => 1,
          '545' => 1,
          '546' => 1,
          '611' => 2,
          '593H' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=CHI',
          },
          '593H2' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=KEN',
          },
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'Madison',
          'A5' => 'Waukesha',
          'A7' => 'Milwaukee',
          'A9' => 'Green Bay',
          'B6' => 'Oak Creek',
          'C3' => 'East Troy',
          'C7' => 'Racine',
          'D2' => 'Elkhorn',
          'D6' => 'Kenosha',
          'D10' => 'Great Lakes (+20 Milwaukee)',
          'E1' => 'Rockford (+40 Milwaukee)',
          'E7' => 'Waukegan',
          'F4' => 'Elgin',
          'F6' => 'Arlington Heights',
          'F8' => 'Skokie',
          'G7' => 'Des Plaines',
          'G9' => 'North Chicago',
          'G13' => 'Great Lakes',
          'H4' => 'Naperville',
          'H8' => 'Oak Park',
          'H10' => 'South Chicago',
          'I3' => 'Saint Louis',
          'I5' => 'Joliet',
          'I9' => 'Oak Lawn',
          'I11' => 'Gary',
          'I13' => 'Indianapolis',
        }.freeze

        HEXES = {
          blue: {
            %w[B8 C9 E9 F10] => '',
            ['D8'] => 'path=a:0,b:4;path=a:1,b:4;path=a:2,b:4',
            ['G11'] => 'path=a:0,b:4;path=a:1,b:4',
            ['H12'] => 'path=a:0,b:3;path=a:1,b:3',
          },
          gray: {
            ['A7'] => 'city=revenue:yellow_20|green_60|brown_40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0',
          },
          white: {
            %w[A3 C5 D4 G3 G5 H2 H6] => '',
            %w[B4 E5 I7] => 'upgrade=cost:15,terrain:water',
            %w[B6 C3 C7 D2 D6 E7 F4 F6 F8 G7 H4 I5 I9 I11] => 'city=revenue:0',
            %w[A5 H8] => 'city=revenue:0;upgrade=cost:15,terrain:water',
            %w[B2 C1 E3 F2] => 'icon=image:18_hiawatha/wheat',
          },
          yellow: {
            ['G9'] => 'city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;upgrade=cost:15,terrain:water;label=CHI',
            ['H10'] => 'city=revenue:40;path=a:1,b:_0;path=a:5,b:_0;label=CHI',
          },
          red: {
            ['A1'] => 'offboard=revenue:yellow_30|green_40|brown_50;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A9'] => 'offboard=revenue:yellow_20|green_30|brown_50;path=a:1,b:_0;icon=image:port',
            ['D10'] => 'offboard=revenue:green_30|brown_50;path=a:1,b:_0;icon=image:port',
            ['E1'] => 'offboard=revenue:yellow_30|green_40|brown_40;path=a:3,b:_0,terminal:1;'\
                      'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['G13'] => 'offboard=revenue:green_30|brown_40;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:port',
            ['I3'] => 'offboard=revenue:yellow_30|green_40|brown_60;path=a:2,b:_0,terminal:1;'\
                      'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['I13'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0',
          },
        }.freeze
      end
    end
  end
end
