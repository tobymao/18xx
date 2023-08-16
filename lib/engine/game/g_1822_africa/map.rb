# frozen_string_literal: true

module Engine
  module Game
    module G1822Africa
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 6,
          '4' => 6,
          '5' => 6,
          '6' => 8,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '58' => 6,
          '69' => 1,
          '14' => 6,
          '15' => 6,
          '80' => 6,
          '81' => 6,
          '82' => 8,
          '83' => 8,
          '141' => 4,
          '142' => 4,
          '143' => 4,
          '144' => 4,
          '207' => 2,
          '208' => 1,
          '619' => 6,
          '622' => 1,
          '63' => 8,
          '448' => 'unlimited',
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 4,
          '768' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '767' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '769' =>
            {
              'count' => 6,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=Y',
            },
        }.freeze

        LOCATION_NAMES = {
          'A5' => 'Nouakchott',
          'A7' => 'Dakar',
          'A9' => 'Freetown',
          'B2' => 'Casablanca',
          'B10' => 'Abidjan',
          'C9' => 'Lagos',
          'D2' => 'Algeris',
          'D4' => 'Tammanrasset',
          'D8' => 'Kano',
          'D10' => 'Libreville',
          'E1' => 'Tunis',
          'E9' => 'Yaounde',
          'E11' => 'Kinshasa',
          'E13' => 'Luanda',
          'E15' => 'Windhoek',
          'F18' => 'Cape Town',
          'G3' => 'Cairo',
          'G7' => 'Khartoum',
          'G9' => 'Kampala',
          'G17' => 'Yohannesburg',
          'H8' => 'Addis Ababa',
          'H10' => 'Nairobi',
          'H12' => 'Dar es Salaam',
          'I7' => 'Djibouti',
          'I11' => 'Mombasa',
        }.freeze

        HEXES = {
          white: {
            %w[B4 B8 E3 E17 F2 F4 F8 F10 F12 F14 F16 G5 H6 H16 I9] => '',
            %w[B6 C3 C5 C7 D6 E5 E7 F6] => 'upgrade=cost:20,terrain:desert',
            %w[G11 G15 H14] => 'upgrade=cost:20,terrain:hill',
            %w[A5 A9 D10 E15 G9 I11] => 'town=revenue:0',
            %w[B2 B10 D2 E9 F18 H8 I7] => 'city=revenue:20',
            %w[D4 D8] => 'town=revenue:0;upgrade=cost:20,terrain:desert',
            ['G7'] => 'city=revenue:20;upgrade=cost:20,terrain:desert',
            ['H10'] => 'city=revenue:20;upgrade=cost:20,terrain:hill',
          },
          yellow: {
            %w[E11 E13] => 'city=revenue:20,slots:1;path=a:0,b:_0;path=a:3,b:_0',
            ['C9'] => 'city=revenue:30,slots:1;path=a:1,b:_0;path=a:4,b:_0;label=Y',
            ['G3'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;label=Y',
            ['G17'] => 'city=revenue:30,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=Y',
          },
          gray: {
            ['A7'] => 'city=revenue:yellow_30|green_40|brown_50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0',
            ['C1'] => 'path=a:0,b:1',
            ['E1'] => 'city=revenue:yellow_30|green_40|brown_50,slots:1;path=a:0,b:_0;path=a:1,b:_0',
            ['H12'] => 'city=revenue:yellow_30|green_40|brown_50,slots:2;path=a:0,b:_0;path=a:4,b:_0;'\
                       'path=a:0,b:_0;path=a:2,b:_0',
          },
          purple: {
            ['G13'] => 'offboard=revenue:20;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
          },
          blue: {
            ['A3'] => 'junction;path=a:4,b:_0,terminal:1',
            ['A11'] => 'junction;path=a:4,b:_0,terminal:1',
            ['E19'] => 'junction;path=a:4,b:_0,terminal:1',
            ['G1'] => 'junction;path=a:0,b:_0,terminal:1',
            ['J8'] => 'junction;path=a:2,b:_0,terminal:1',
          },
        }.freeze
      end
    end
  end
end
