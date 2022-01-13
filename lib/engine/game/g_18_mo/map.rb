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
          'A7' => 'Topeka',
          'B8' => 'Lawrence',
          'B14' => 'Parsons',
          'A15' => 'Dallas',
          'C5' => 'St. Joseph',
          'C7' => 'Kansas City',
          'C11' => 'Nevada City',
          'C13' => 'Joplin',
          'D8' => 'Pleasant Hill',
          'D14' => 'Aurora',
          'E9' => 'Sedalia',
          'E1' => 'Des Moines',
          'E13' => 'Springfield, MO',
          'E15' => 'Branson',
          'E17' => 'Little Rock',
          'F4' => 'Macon City',
          'F12' => 'Lebanon',
          'G7' => 'Columbia',
          'G9' => 'Jefferson City',
          'G11' => 'Rolla',
          'H4' => 'Quincy',
          'H6' => 'Hannibal',
          'I7' => 'St. Charles',
          'I11' => 'Bismarck',
          'J2' => 'Aurora',
          'J4' => 'Chapin',
          'J8' => 'St. Louis',
          'J12' => 'Thebes',
          'K3' => 'Joliet',
          'K5' => 'Springfield, IL',
          'K7' => 'East St. Louis',
          'K13' => 'Memphis',
        }.freeze

        HEXES = {
          white: {
            %w[A9 A11 B10 B12 C3 C9 C15 D2 D4 E3 L6 L8 L10] => '',
            %w[B8 C11 C13 D14 E15 I11 J12 K5] => 'city=revenue:0',
            %w[D16 F14 F16 G13 H12 H14 I13 I15] => 'upgrade=cost:60,terrain:mountain',
            ['G11'] => 'city=revenue:0;border=edge:3,type:water,cost:40',
            ['H10'] => 'border=edge:2,type:water,cost:40',
            %w[J10] => 'border=edge:4,type:water,cost:60',
            %w[G3] => 'border=edge:4,type:water,cost:60;border=edge:5,type:water,cost:60',
            %w[D10] => 'border=edge:4,type:water,cost:60;border=edge:5,type:water,cost:20',
            ['G7'] => 'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            %w[F10 H8 K11] => 'upgrade=cost:40,terrain:water',
            ['J6'] => 'border=edge:0,type:impassable;border=edge:1,type:water,cost:60;border=edge:2,type:water,cost:60',
            ['E9'] => 'city=revenue:0;border=edge:0,type:water,cost:60;border=edge:1,type:water,cost:60',
            ['E11'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;'\
                       'border=edge:3,type:water,cost:60',
            ['B6'] => 'border=edge:4,type:water,cost:20',
            ['E5'] => 'border=edge:0,type:water,cost:40',
            ['D12'] => 'border=edge:4,type:water,cost:20',
            ['H2'] => 'border=edge:1,type:water,cost:60',
            ['D6'] => 'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['G5'] => 'border=edge:4,type:water,cost:60',
            ['H4'] => 'city=revenue:0;border=edge:0,type:water,cost:60;border=edge:1,type:water,cost:60;'\
                      'border=edge:2,type:water,cost:60',
            ['H6'] => 'city=revenue:0;border=edge:3,type:water,cost:60;border=edge:4,type:water,cost:60',
            ['I7'] => 'city=revenue:0;border=edge:0,type:water,cost:60;border=edge:3,type:water,cost:60;'\
                      'border=edge:4,type:water,cost:60',
            ['I9'] => 'border=edge:3,type:water,cost:60',
            ['I3'] => 'border=edge:5,type:water,cost:40',
            ['I5'] => 'border=edge:0,type:water,cost:60;border=edge:1,type:water,cost:60;'\
                      'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:60',
            ['K9'] => 'border=edge:1,type:water,cost:60',
            ['D8'] => 'border=edge:3,type:water,cost:40;city=revenue:0',
            ['E7'] => 'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40;'\
                      'border=edge:4,type:water,cost:40',
            ['F6'] => 'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            ['F8'] => 'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40',
            ['J4'] => 'city=revenue:0;border=edge:1,type:water,cost:40;border=edge:2,type:water,cost:40',
            ['C5'] => 'city=revenue:0;border=edge:1,type:water,cost:20',
          },

          red: {
            ['A7'] => 'city=revenue:yellow_30|brown_60,slots:2;path=a:0,b:_0;path=a:5,b:_0',
            ['A15'] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0',
            ['E1'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0',
            ['E17'] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['J2'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0',
            ['K3'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0',
            ['K13'] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0',

          },
          yellow: {
            ['B14'] => 'city=revenue:10;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[F4] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0',
            %w[F12] => 'city=revenue:20;path=a:2,b:_0;path=a:4,b:_0',
            %w[C7] => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:5,b:_0;label=Z;'\
                      'upgrade=cost:40,terrain:water',
            %w[E13] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;label=Z;'\
                       'upgrade=cost:40,terrain:water;',
            %w[G9] => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:4,b:_0;label=Z;'\
                      'upgrade=cost:40,terrain:water;border=edge:0,type:water,cost:40;'\
                      'border=edge:5,type:water,cost:40;border=edge:3,type:water,cost:40',
            ['J8'] => 'city=revenue:10;city=revenue:10;city=revenue:10;city=revenue:10;path=a:0,b:_0;'\
                      'path=a:1,b:_1;path=a:2,b:_2;path=a:5,b:_3;label=Chi;'\
                      'upgrade=cost:60,terrain:water;border=edge:3,type:impassable',
          },
          gray: {
            ['K7'] => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
