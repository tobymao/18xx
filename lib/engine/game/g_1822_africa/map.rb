# frozen_string_literal: true

module Engine
  module Game
    module G1822Africa
      module Map
        TILES = {
          '3' => 1,
          '4' => 2,
          '5' => 2,
          '6' => 4,
          '7' => 4,
          '8' => 12,
          '9' => 7,
          '57' => 4,
          '58' => 4,
          '14' => 2,
          '15' => 5,
          '80' => 1,
          '81' => 2,
          '82' => 2,
          '83' => 1,
          '141' => 1,
          '142' => 1,
          '143' => 1,
          '144' => 1,
          '207' => 2,
          '208' => 1,
          '619' => 1,
          '611' => 2,
          '448' => 5,
          'X1' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Y',
            },
          'X2' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            },
          'GR' =>
            {
              'count' => 1,
              'color' => 'purple',
              'code' => 'offboard=revenue:20,visit_cost:0;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;'\
                        'path=a:2,b:_0,terminal:1;icon=image:1822_africa/zebra;stripes=color:white',
            },
        }.freeze

        LOCATION_NAMES = {
          'A5' => 'Nouakchott',
          'A7' => 'Dakar',
          'A9' => 'Freetown',
          'B2' => 'Casablanca',
          'B10' => 'Abidjan',
          'C9' => 'Lagos',
          'D2' => 'Algiers',
          'D4' => 'Tamanrasset',
          'D8' => 'Kano',
          'D10' => 'Libreville',
          'E1' => 'Tunis',
          'E9' => 'Yaoundé',
          'E11' => 'Kinshasa',
          'E13' => 'Luanda',
          'E15' => 'Windhoek',
          'F18' => 'Cape Town',
          'G3' => 'Cairo',
          'G7' => 'Khartoum',
          'G9' => 'Kampala',
          'G17' => 'Johannesburg',
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
            %w[G11 G15 H14] => 'upgrade=cost:20,terrain:mountain',
            %w[A5 A9 D10 E15 G9 I11] => 'town=revenue:0',
            %w[B2 B10 D2 E9 F18 H8 I7] => 'city=revenue:20',
            %w[D4 D8] => 'town=revenue:0;upgrade=cost:20,terrain:desert',
            ['G7'] => 'city=revenue:20;upgrade=cost:20,terrain:desert',
            ['H10'] => 'city=revenue:20;upgrade=cost:20,terrain:mountain',
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
            ['G13'] => 'offboard=revenue:20,visit_cost:0;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                       'icon=image:1822_africa/elephant',
          },
          blue: {
            ['A3'] => 'junction;path=a:4,b:_0,terminal:1',
            ['A11'] => 'junction;path=a:4,b:_0,terminal:1',
            ['G1'] => 'junction;path=a:0,b:_0,terminal:1',
            %w[G19 J8] => 'junction;path=a:2,b:_0,terminal:1',
          },
        }.freeze
      end
    end
  end
end
