# frozen_string_literal: true

module Engine
  module Game
    module G1804
      module Map
        TILES = {
          '1' => 1,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 3,
          '15' => 3,
          '16' => 'unlimited',
          '17' => 'unlimited',
          '18' => 'unlimited',
          '19' => 'unlimited',
          '20' => 'unlimited',
          '21' => 'unlimited',
          '22' => 'unlimited',
          '23' => 'unlimited',
          '24' => 'unlimited',
          '28' => 'unlimited',
          '29' => 'unlimited',
          '43' => 'unlimited',
          '47' => 'unlimited',
          '53' => 1,
          '54' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '59' => 1,
          '61' => 1,
          '62' => 1,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '611' => 4,
          '625' => 'unlimited',
          '626' => 'unlimited',
          '633' => 1,
          '778' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:5;path=a:2,b:4',
          },
          '779' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'path=a:4,b:5;path=a:1,b:3;path=a:0,b:2',
          },
          '780' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'path=a:1,b:2;path=a:4,b:5;path=a:0,b:3',
          },
          '781' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'path=a:0,b:1;path=a:2,b:3;path=a:4,b:5',
          },
          '798' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:4;path=a:2,b:5',
          },
          '1804_1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30,slots:1;path=a:0,b:_0;path=a:4,b:_0;label=B',
          },
        }.freeze

        LOCATION_NAMES = {
          'A10' => 'Philanthropy Class',
          'B3' => 'Hollywood',
          'B7' => 'Progressive Caucus',
          'B13' => 'New Democrats',
          'C4' => 'Socialists',
          'C10' => 'Neoliberals',
          'C12' => 'Wonks',
          'C14' => 'Silicon Valley',
          'D1' => 'Influencers',
          'D7' => 'Liberals',
          'E2' => 'Populist Left',
          'E4' => 'Democratic Socialists',
          'E10' => 'Blue Dog Coalition',
          'F7' => 'Black Caucus',
          'F9' => 'Centrists',
          'F15' => 'Chamber of Commerce',
          'G4' => 'Labor Unions',
          'G10' => 'Problem Solvers Caucus',
          'G12' => 'Republican Governance Group',
          'G14' => 'Neoconservatives',
          'G18' => 'Wall Street',
          'H15' => 'Liberty Caucus',
          'I12' => 'Main Street Caucus',
          'I16' => 'Libertarian Party',
          'I18' => 'Crypto Whales',
          'J7' => 'Populist Right & Nationalists',
          'J9' => 'Paleoconservatives',
          'J13' => 'Freedom Caucus',
          'K14' => 'Evangelicals',
        }.freeze

        HEXES = {
          red: {
            ['A8'] =>
                     'offboard=revenue:yellow_30|brown_50,hide:1,groups:Philanthropy;path=a:0,b:_0;border=edge:4',
            ['A10'] =>
                     'offboard=revenue:yellow_30|brown_50,groups:Philanthropy;path=a:0,b:_0',
            ['A12'] =>
                     'offboard=revenue:yellow_30|brown_50,hide:1,groups:Philanthropy;path=a:0,b:_0;border=edge:1',
            ['B3'] =>
                   'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:5,b:_0',
            ['C14'] =>
                   'offboard=revenue:yellow_20|brown_50;path=a:0,b:_0;path=a:1,b:_0',
            ['F15'] =>
                   'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0',
            ['G4'] =>
                   'offboard=revenue:yellow_20|green_30;path=a:2,b:_0;path=a:4,b:_0',
            ['G18'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:0,b:_0;path=a:1,b:_0',
            ['K14'] => 'offboard=revenue:yellow_10|green_40;path=a:1,b:_0;path=a:3,b:_0',
          },

          white: {
            %w[C4 C12 G14 J9] => 'town=revenue:0;town=revenue:0',
            %w[C10 G10] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[E12 F11 F13 G6 G8 H7] => 'upgrade=cost:80,terrain:mountain',
            ['I8'] => 'upgrade=cost:120,terrain:mountain',
            %w[B7 E2 E4 E10 F7 G12 H15 I12 I16 J13] => 'city',
            %w[B9 B11 C6 C8 D3 D5 D9 D11 E6 E8 F3 F5 G16 H9 H11 H13 H17 I10 I14 J11 J15 K8 K10 K12] => 'blank',
            ['D7'] => 'city=revenue:0;label=B',
          },

          gray: {
            ['B13'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0',
            ['I18'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            ['D1'] => 'town=revenue:10;path=a:3,b:_0;path=a:5,b:_0',
            %w[G2 J17] => 'path=a:2,b:3',
            %w[F1 I6] => 'path=a:3,b:5',
            ['B5'] => 'path=a:0,b:4',
            ['D13'] => 'path=a:0,b:3',
            ['C2'] => 'path=a:3,b:0;path=a:3,b:5',
          },

          yellow: {
            ['F9'] => 'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:mountain',
            ['J7'] => 'city=revenue:40;city=revenue:40;path=a:2,b:_0;path=a:5,b:_1;label=NY;upgrade=cost:80,terrain:mountain',
          },
        }.freeze
        LAYOUT = :pointy
      end
    end
  end
end
