# frozen_string_literal: true

require_relative '../g_1846/map'

module Engine
  module Game
    module G18LosAngeles
      module Map
        TILES =
          G1846::Map::TILES
            .reject { |k, _v| %w[298 299 300].include?(k) }
            .merge(
              {
                '7' => 4,
                '8' => 4,
                '9' => 4,
                '298LA' => {
                  'count' => 1,
                  'color' => 'green',
                  'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                            'label=LB;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;'\
                            'path=a:4,b:_3;path=a:0,b:_0;path=a:0,b:_1;path=a:0,b:_2;path=a:0,b:_3',
                },
                '299LA' => {
                  'count' => 1,
                  'color' => 'brown',
                  'code' => 'city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;'\
                            'label=LB;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;'\
                            'path=a:0,b:_0;path=a:0,b:_1;path=a:0,b:_2;path=a:0,b:_3',
                },
                '300LA' => {
                  'count' => 1,
                  'color' => 'gray',
                  'code' => 'city=revenue:90;city=revenue:90;city=revenue:90;city=revenue:90;'\
                            'label=LB;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;'\
                            'path=a:0,b:_0;path=a:0,b:_1;path=a:0,b:_2;path=a:0,b:_3',
                },
              }
            ).freeze

        LOCATION_NAMES = {
          'A2' => 'Reseda',
          'A4' => 'Van Nuys',
          'A6' => 'Burbank',
          'A8' => 'Pasadena',
          'A10' => 'Lancaster',
          'A12' => 'Victorville',
          'A14' => 'San Bernardino',
          'B1' => 'Oxnard',
          'B3' => 'Beverly Hills',
          'B5' => 'Hollywood',
          'B7' => 'South Pasadena',
          'B9' => 'Alhambra',
          'B11' => 'Azusa',
          'B13' => 'San Dimas',
          'B15' => 'Pomona',
          'C2' => 'Santa Monica',
          'C4' => 'Culver City',
          'C6' => 'Los Angeles',
          'C8' => 'Montebello',
          'C10' => 'Puente',
          'C12' => 'Walnut',
          'C14' => 'Riverside',
          'D1' => 'LAX',
          'D3' => 'El Segundo',
          'D5' => 'Gardena',
          'D7' => 'Compton',
          'D9' => 'Norwalk',
          'D11' => 'La Habra',
          'D13' => 'Yorba Linda',
          'D15' => 'Palm Springs',
          'E4' => 'Redondo Beach',
          'E6' => 'Torrance',
          'E8' => 'Long Beach',
          'E10' => 'Cypress',
          'E12' => 'Anaheim',
          'E14' => 'Alta Vista',
          'E16' => 'Corona',
          'F5' => 'San Pedro',
          'F7' => 'Port of Long Beach',
          'F9' => 'Westminster',
          'F11' => 'Garden Grove',
          'F13' => 'Santa Ana',
          'F15' => 'Irvine',
        }.freeze

        HEXES = {
          white: {
            ['C10'] => '',
            ['D3'] => 'upgrade=cost:30,terrain:water',
            ['A4'] => 'city=revenue:0;border=edge:0,type:mountain,cost:20',
            ['B3'] => 'border=edge:3,type:mountain,cost:20;border=edge:4,type:mountain,cost:20',
            ['B9'] => 'city=revenue:0;border=edge:3,type:mountain,cost:20;border=edge:1,type:water,cost:40',
            ['B13'] => 'city=revenue:0;border=edge:2,type:mountain,cost:20;'\
                       'border=edge:4,type:mountain,cost:20;label=Z',
            ['B7'] => 'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['C8'] => 'city=revenue:0;border=edge:2,type:water,cost:40',
            ['D5'] => 'city=revenue:0;border=edge:3,type:water,cost:40',
            ['C12'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            ['D9'] => 'city=revenue:0;border=edge:4,type:water,cost:40;stub=edge:0',
            ['D11'] => 'city=revenue:0;border=edge:1,type:water,cost:40',
            ['E4'] => 'city=revenue:0',
            ['E6'] => 'city=revenue:0;stub=edge:4',
            ['E10'] => 'city=revenue:0;border=edge:0,type:water,cost:20;stub=edge:1',
            ['E12'] => 'city=revenue:0;label=Z',
            ['E14'] => 'upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:20',
            %w[A6 C4 F11] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;stub=edge:5',
          },
          gray: {
            ['a5'] => 'offboard=revenue:0,visit_cost:100;path=a:0,b:_0;path=a:5,b:_0',

            ['B5'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'border=edge:1,type:mountain,cost:20',
            ['C2'] => 'city=revenue:10;icon=image:port;icon=image:port;path=a:2,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;path=a:0,b:_0;',
            ['D13'] => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                       'icon=image:18_los_angeles/meat;',
            ['F9'] => 'city=revenue:10;border=edge:3,type:water,cost:20;icon=image:port;'\
                      'icon=image:port;path=a:3,b:_0;path=a:4,b:_0',
            ['F3'] => 'offboard=revenue:0,visit_cost:100;path=a:3,b:_0',
            ['F5'] => 'path=a:2,b:3',
            ['a9'] => 'offboard=revenue:0,visit_cost:100;path=a:0,b:_0',
            ['G14'] => 'offboard=revenue:0,visit_cost:100;path=a:2,b:_0',
          },
          red: {
            ['A2'] => 'city=revenue:yellow_30|brown_50,groups:NW;label=N/W;icon=image:1846/20;'\
                      'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A10'] => 'offboard=revenue:yellow_20|brown_40,groups:NE;label=N/E;'\
                       'border=edge:0,type:mountain,cost:20;border=edge:1,type:mountain,cost:20;'\
                       'border=edge:5,type:mountain,cost:20;icon=image:1846/20;path=a:0,b:_0;'\
                       'path=a:1,b:_0;path=a:5,b:_0',
            ['A12'] => 'offboard=revenue:yellow_20|brown_40,groups:NE;label=N/E;'\
                       'border=edge:0,type:mountain,cost:20;border=edge:5,type:mountain,cost:20;'\
                       'icon=image:1846/20;path=a:0,b:_0;path=a:5,b:_0',
            ['A14'] => 'offboard=revenue:yellow_20|brown_40,groups:NE;label=N/E;'\
                       'icon=image:1846/20;path=a:0,b:_0',
            ['B1'] => 'offboard=revenue:yellow_40|brown_10,groups:W|NW|SW;label=W;icon=image:1846/30;'\
                      'icon=image:port;icon=image:18_los_angeles/meat;path=a:4,b:_0;path=a:5,b:_0',
            ['B15'] => 'offboard=revenue:yellow_30|brown_50,groups:E|NE|SE;label=E;'\
                       'icon=image:1846/30;path=a:1,b:_0;border=edge:1,type:mountain,cost:20',
            ['C14'] => 'offboard=revenue:yellow_20|brown_70,groups:E|NE|SE;label=E;'\
                       'icon=image:1846/30;path=a:1,b:_0;path=a:2,b:_0',
            ['D1'] => 'offboard=revenue:yellow_0|brown_60,groups:W|NW|SW;label=W;'\
                      'icon=image:1846/20;icon=image:port;icon=image:18_los_angeles/meat;'\
                      'path=a:3,b:_0;path=a:4,b:_0',
            ['D15'] => 'offboard=revenue:yellow_20|brown_40,groups:E|NE|SE;label=E;'\
                       'icon=image:1846/30;path=a:0,b:_0;path=a:1,b:_0',
            ['E16'] => 'offboard=revenue:yellow_20|brown_40,groups:SE;label=S/E;icon=image:1846/20;'\
                       'path=a:1,b:_0',
            ['F15'] => 'offboard=revenue:yellow_20|brown_50,groups:SE;label=S/E;'\
                       'border=edge:2,type:mountain,cost:20;path=a:1,b:_0;path=a:2,b:_0;'\
                       'icon=image:1846/20;icon=image:18_los_angeles/meat',
            ['F7'] => 'offboard=revenue:yellow_20|brown_40,groups:SW;label=S/W;path=a:3,b:_0;'\
                      'icon=image:1846/50',
          },
          yellow: {
            ['A8'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;border=edge:4,type:mountain,cost:20',
            ['B11'] => 'city=revenue:20;border=edge:2,type:mountain,cost:20;'\
                       'border=edge:3,type:mountain,cost:20;path=a:1,b:_0;path=a:4,b:_0',
            ['C6'] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;label=Z;'\
                      'border=edge:0,type:water,cost:40',
            ['E8'] => 'city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;'\
                      'city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;'\
                      'path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;stub=edge:0;label=LB',
            ['F13'] => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
