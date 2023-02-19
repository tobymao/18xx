# frozen_string_literal: true

module Engine
  module Game
    module G18MO
      module Map
        LAYOUT = :flat

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
          '296' => {
            'count' => 3,
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
          '611' => 4,
          '619' => 3,
          'X1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_40|brown_50;path=a:0,b:_0;label=R',
          },
          'X2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;'\
                      'path=a:0,b:_0;path=a:_0,b:4;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;'\
                      'path=a:_2,b:4;upgrade=cost:40,terrain:water;label=StL',
          },
          'X3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70;city=revenue:70;city=revenue:70;'\
                      'path=a:0,b:_0;path=a:_0,b:4;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;'\
                      'path=a:_2,b:4;upgrade=cost:40,terrain:water;label=StL',
          },
          'X4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90;city=revenue:90;city=revenue:90;'\
                      'path=a:0,b:_0;path=a:_0,b:4;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;'\
                      'path=a:_2,b:4;label=StL',
          },

        }.freeze

        LOCATION_NAMES = {
          'A7' => 'Topeka',
          'C13' => 'Joplin',
          'A15' => 'Dallas',
          'C5' => 'St. Joseph',
          'C7' => 'Kansas City',
          'D4' => 'Cameron',
          'D8' => 'Pleasant Hill',
          'E9' => 'Sedalia',
          'E1' => 'Des Moines',
          'E13' => 'Springfield, MO',
          'E15' => 'Branson',
          'E17' => 'Little Rock',
          'F4' => 'Chillicothe',
          'G7' => 'Columbia',
          'G9' => 'Jefferson City',
          'H4' => 'Quincy',
          'H6' => 'Hannibal',
          'H10' => 'Cuba',
          'H12' => 'Salem',
          'I7' => 'St. Charles',
          'J2' => 'Aurora',
          'J4' => 'Chapin',
          'J8' => 'St. Louis',
          'J14' => 'Poplar Bluff',
          'K3' => 'Joliet',
          'K5' => 'Springfield, IL',
          'K7' => 'East St. Louis',
          'K13' => 'Cape Girardeau',
          'K17' => 'Memphis',
          'L14' => 'Cairo',
        }.freeze

        HEXES = {
          white: {
            %w[A9 A11 B6 B8 B10 B12 C3 C9 C11 C15 D2 D14 E3 F12 L6 L8 L10 I11 J12 K15] => '',
            %w[C5 D4 E15 F4 H12] => 'city=revenue:0',
            %w[D16 F14 F16 G13 H14 G15 I13 I15] => 'upgrade=cost:20,terrain:mountain',
            ['C13'] => 'city=revenue:10;path=a:1,b:_0',
            ['H10'] => 'city=revenue:0;border=edge:2,type:water,cost:20',
            ['G11'] => 'border=edge:3,type:water,cost:20',
            ['J10'] => 'border=edge:4,type:water,cost:40',
            ['G3'] => 'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['D10'] => 'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:20',
            ['G7'] => 'city=revenue:0;border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20',
            %w[F10 H8] => 'upgrade=cost:20,terrain:water',
            ['K11'] => 'upgrade=cost:40,terrain:water',
            ['J6'] => 'border=edge:0,type:impassable;border=edge:1,type:water,cost:60;border=edge:2,type:water,cost:40',
            ['E9'] => 'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            ['K13'] => 'city=revenue:0;border=edge:4,type:water,cost:40',
            ['L12'] => 'border=edge:1,type:water,cost:40',
            ['E11'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;'\
                       'border=edge:3,type:water,cost:40',
            ['E5'] => 'border=edge:0,type:water,cost:20',
            ['D12'] => 'border=edge:4,type:water,cost:20',
            ['H2'] => 'border=edge:1,type:water,cost:40',
            ['D6'] => 'border=edge:0,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['G5'] => 'border=edge:4,type:water,cost:40',
            ['H4'] => 'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40;'\
                      'border=edge:2,type:water,cost:40',
            ['I7'] => 'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:3,type:water,cost:40;'\
                      'border=edge:4,type:water,cost:60',
            ['I9'] => 'border=edge:3,type:water,cost:40',
            ['I3'] => 'border=edge:5,type:water,cost:20',
            ['I5'] => 'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40;'\
                      'border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:40',
            ['K9'] => 'border=edge:1,type:water,cost:40',
            ['D8'] => 'border=edge:3,type:water,cost:20;city=revenue:0',
            ['E7'] => 'border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20;'\
                      'border=edge:4,type:water,cost:20',
            ['F6'] => 'border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20',
            ['F8'] => 'border=edge:3,type:water,cost:20;border=edge:4,type:water,cost:20',
            ['J4'] => 'city=revenue:10;path=a:_0,b:3;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            ['K5'] => 'city=revenue:10;path=a:_0,b:3',
            ['J14'] => 'city=revenue:10;path=a:0,b:_0;',
          },

          red: {
            ['A7'] => 'city=revenue:yellow_30|brown_40,groups:W;icon=image:1846/50;path=a:0,b:_0;path=a:5,b:_0;label=W',
            ['A15'] => 'offboard=revenue:yellow_30|brown_60,groups:W;icon=image:1846/30;path=a:4,b:_0;label=W;',
            ['E1'] => 'offboard=revenue:yellow_20|brown_50;path=a:0,b:_0',
            ['E17'] => 'offboard=revenue:yellow_20|brown_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[J2 K3] => 'offboard=revenue:yellow_30|brown_40,groups:E;icon=image:1846/50;path=a:0,b:_0;path=a:1,b:_0;label=E',
            ['K17'] => 'offboard=revenue:yellow_30|brown_60,groups:E;icon=image:1846/30;path=a:2,b:_0;label=E',

          },
          yellow: {
            ['B14'] => 'path=a:1,b:4',
            ['C7'] => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:5,b:_0;label=Z;'\
                      'upgrade=cost:40,terrain:water',
            ['E13'] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=Z',
            ['G9'] => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:4,b:_0;label=Z;'\
                      'upgrade=cost:40,terrain:water;border=edge:0,type:water,cost:20;'\
                      'border=edge:5,type:water,cost:20;border=edge:3,type:water,cost:20',
            ['H6'] => 'city=revenue:20;path=a:2,b:_0;border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40',
            ['J8'] => 'city=revenue:10;city=revenue:10;city=revenue:10;path=a:0,b:_0;'\
                      'path=a:1,b:_1;path=a:2,b:_2;label=StL;'\
                      'upgrade=cost:40,terrain:water;border=edge:3,type:impassable',
            ['J16'] => 'path=a:3,b:5',
          },

          gray: {
            ['K7'] => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['L14'] => 'city=revenue:20;path=a:1,b:_0',
          },
        }.freeze
      end
    end
  end
end
