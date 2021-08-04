# frozen_string_literal: true

module Engine
  module Game
    module G1846
      module Map
        LAYOUT = :pointy

        TILES = {
          '5' => 3,
          '6' => 4,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 4,
          '15' => 5,
          '16' => 2,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '51' => 2,
          '57' => 4,
          '70' => 1,
          '290' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;label=Z;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '291' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;label=Z',
          },
          '292' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;label=Z',
          },
          '293' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;label=Z',
          },
          '294' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Z',
          },
          '295' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;label=Z',
          },
          '296' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Z',
          },
          '297' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;label=Z',
          },
          '298' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                      'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;'\
                      'path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=Chi',
          },
          '299' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;'\
                      'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;'\
                      'path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=Chi',
          },
          '300' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90;city=revenue:90;city=revenue:90;city=revenue:90;'\
                      'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;'\
                      'path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=Chi',
          },
          '611' => 4,
          '619' => 3,
        }.freeze

        LOCATION_NAMES = {
          'B8' => 'Holland',
          'B16' => 'Port Huron',
          'B18' => 'Sarnia',
          'C5' => 'Chicago Connections',
          'C9' => 'South Bend',
          'C15' => 'Detroit',
          'C17' => 'Windsor',
          'D6' => 'Chicago',
          'D14' => 'Toledo',
          'D20' => 'Erie',
          'D22' => 'Buffalo',
          'E11' => 'Fort Wayne',
          'E17' => 'Cleveland',
          'E21' => 'Salamanca',
          'E23' => 'Binghamton',
          'F20' => 'Homewood',
          'G3' => 'Springfield',
          'G7' => 'Terre Haute',
          'G9' => 'Indianapolis',
          'G13' => 'Dayton',
          'G15' => 'Columbus',
          'G19' => 'Wheeling',
          'G21' => 'Pittsburgh',
          'H12' => 'Cincinnati',
          'H20' => 'Cumberland',
          'I1' => 'St. Louis',
          'I5' => 'Centralia',
          'I15' => 'Huntington',
          'I17' => 'Charleston',
          'J10' => 'Louisville',
          'K3' => 'Cairo',
        }.freeze

        HEXES = {
          white: {
            %w[B14 C11 C13 D8 D10 D12 E7 E9 E13 E15 F4 F8 F10 F12 G11 H2 H4 H8
               H10 I3 I7 I9 J8 D18 B10 B12 F14 F16] => '',
            ['E19'] => 'border=edge:5,type:mountain,cost:40',
            %w[E5 F6 G5 H6] => 'icon=image:1846/ic',
            ['J4'] => 'border=edge:4,type:water,cost:40;icon=image:1846/ic',
            ['J6'] => 'border=edge:1,type:water,cost:40',
            ['I11'] => 'border=edge:3,type:water,cost:40',
            %w[C9 E11 G3 G7 G9 G15] => 'city=revenue:0',
            %w[G13] => 'city=revenue:0;icon=image:1846/lm,sticky:1',
            ['B16'] => 'city=revenue:0;border=edge:4,type:mountain,cost:40',
            ['D14'] => 'city=revenue:0;icon=image:port,sticky:1;icon=image:1846/lsl,sticky:1',
            ['E17'] => 'city=revenue:0;label=Z;icon=image:1846/lsl,sticky:1',
            ['H12'] => 'city=revenue:0;label=Z;border=edge:0,type:water,cost:40;'\
                       'icon=image:1846/lm,sticky:1;icon=image:1846/boom,sticky:1',
            ['F18'] => 'upgrade=cost:40,terrain:mountain;border=edge:5,type:water,cost:40',
            ['H16'] => 'upgrade=cost:40,terrain:mountain',
            ['G17'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:water,cost:20',
            ['H14'] => 'upgrade=cost:60,terrain:mountain',
          },
          gray: {
            %w[A15 C7] => 'path=a:0,b:5',
            ['F20'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                       'border=edge:2,type:mountain,cost:40',
            ['I5'] => 'city=revenue:10,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0',
            ['I15'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['E21'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['K3'] => 'city=revenue:20;path=a:3,b:_0',
          },
          red: {
            ['B8'] => 'offboard=revenue:yellow_40|brown_10;path=a:4,b:_0;icon=image:port;icon=image:port',
            ['B18'] => 'offboard=revenue:yellow_30|brown_50,groups:E;icon=image:1846/20;'\
                       'path=a:1,b:_0;label=E;border=edge:1,type:mountain,cost:40 ',
            ['C5'] => 'offboard=revenue:yellow_20|brown_40;icon=image:1846/50;path=a:5,b:_0;label=W;icon=image:port',
            ['C17'] => 'offboard=revenue:yellow_40|brown_60,groups:E;icon=image:1846/30;'\
                       'path=a:1,b:_0;label=E;border=edge:1,type:mountain,cost:60',
            ['C21'] => 'offboard=revenue:yellow_30|brown_60,hide:1,groups:E;icon=image:1846/30;'\
                       'path=a:0,b:_0;border=edge:5',
            ['D22'] => 'offboard=revenue:yellow_30|brown_60,groups:E;icon=image:1846/30;'\
                       'path=a:1,b:_0;label=E;border=edge:2',
            ['E23'] => 'offboard=revenue:yellow_20|brown_50,groups:E;icon=image:1846/30;path=a:1,b:_0;label=E',
            ['I17'] => 'offboard=revenue:yellow_20|brown_50,groups:E;icon=image:1846/20;path=a:1,b:_0;label=E',
            ['F22'] => 'offboard=revenue:yellow_30|brown_70,hide:1,groups:E;icon=image:1846/20;'\
                       'path=a:1,b:_0;border=edge:0',
            ['G21'] => 'offboard=revenue:yellow_30|brown_70,groups:E;'\
                       'border=edge:1,type:mountain,cost:20;icon=image:1846/20;path=a:1,b:_0;'\
                       'path=a:2,b:_0;label=E;border=edge:3',
            ['H20'] => 'offboard=revenue:yellow_20|brown_40,groups:E;icon=image:1846/30;path=a:2,b:_0;label=E',
            ['I1'] => 'offboard=revenue:yellow_50|brown_70,groups:St. Louis;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=W;icon=image:port;icon=image:1846/meat;icon=image:1846/20',
            ['J10'] => 'offboard=revenue:yellow_50|brown_70,groups:Louisville;path=a:2,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['C15'] => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;label=Z;'\
                       'upgrade=cost:40,terrain:water;border=edge:4,type:mountain,cost:60',
            ['D6'] => 'city=revenue:10,groups:Chicago;city=revenue:10,groups:Chicago;'\
                      'city=revenue:10,groups:Chicago;city=revenue:10,groups:Chicago;path=a:0,b:_0;'\
                      'path=a:3,b:_1;path=a:4,b:_2;path=a:5,b:_3;label=Chi;icon=image:1846/meat,sticky:1',
            ['D20'] => 'city=revenue:10,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0',
            ['G19'] => 'city=revenue:10;path=a:5,b:_0;border=edge:1,type:water,cost:20;'\
                       'border=edge:2,type:water,cost:40;border=edge:4,type:mountain,cost:20;'\
                       'icon=image:port,sticky:1;icon=image:port,sticky:1',
          },
          blue: { ['D16'] => '' },
        }.freeze
      end
    end
  end
end
