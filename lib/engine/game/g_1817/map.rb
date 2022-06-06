# frozen_string_literal: true

module Engine
  module Game
    module G1817
      module Map
        LAYOUT = :pointy
        TILE_TYPE = :lawson

        TILES = {
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '54' => 'unlimited',
          '57' => 'unlimited',
          '62' => 'unlimited',
          '63' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '592' => 'unlimited',
          '593' => 'unlimited',
          '597' => 'unlimited',
          '611' => 'unlimited',
          '619' => 'unlimited',
          'X00' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'X30' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
          },
        }.freeze

        LOCATION_NAMES = {
          'A20' => 'Montréal',
          'A28' => 'Maritime Prov.',
          'B5' => 'Lansing',
          'B13' => 'Toronto',
          'B17' => 'Rochester',
          'C8' => 'Detroit',
          'C14' => 'Buffalo',
          'C22' => 'Albany',
          'C26' => 'Boston',
          'D1' => 'Chicago',
          'D7' => 'Toledo',
          'D9' => 'Cleveland',
          'D19' => 'Scranton',
          'E22' => 'New York',
          'F3' => 'Indianapolis',
          'F13' => 'Pittsburgh',
          'F19' => 'Philadelphia',
          'G6' => 'Cincinnati',
          'G18' => 'Baltimore',
          'H1' => 'St. Louis',
          'H3' => 'Louisville',
          'H9' => 'Charleston',
          'I12' => 'Blacksburg',
          'I16' => 'Richmond',
          'J7' => 'Atlanta',
          'J15' => 'Raleigh-Durham',
        }.freeze

        HEXES = {
          red: {
            ['A20'] =>
                     'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:5,b:_0;path=a:0,b:_0',
            ['A28'] =>
                   'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0',
            ['D1'] =>
                   'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:4,b:_0;path=a:5,b:_0',
            ['H1'] =>
                   'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J7'] =>
                   'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0',
            ['J15'] =>
                   'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0',
          },
          white: {
            %w[B5 B17 C14 C22 F3 F13 F19 I16] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;upgrade=cost:20,terrain:lake',
            %w[D19 I12] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[G6 H3 H9] => 'city=revenue:0;upgrade=cost:10,terrain:water',
            %w[B25
               C20
               C24
               E16
               E18
               F15
               G12
               G14
               H11
               H13
               H15
               I8
               I10] => 'upgrade=cost:15,terrain:mountain',
            %w[D13 E12 F11 G4 G10 H7] => 'upgrade=cost:10,terrain:water',
            %w[B9 B27 D25 D27 G20 H17] => 'upgrade=cost:20,terrain:lake',
            %w[B3
               B7
               B11
               B15
               B19
               B21
               B23
               C4
               C6
               C16
               C18
               D3
               D5
               D15
               D17
               D21
               D23
               E2
               E4
               E6
               E8
               E10
               E14
               E20
               F5
               F7
               F9
               F17
               F21
               G2
               G8
               G16
               H5
               I2
               I4
               I6
               I14] => '',
            ['C10'] => 'border=edge:5,type:impassable',
            ['D11'] => 'border=edge:2,type:impassable',
          },
          gray: {
            ['B13'] =>
                     'town=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['D9'] =>
            'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:5,b:_0;path=a:0,b:_0',
            ['F1'] => 'junction;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          yellow: {
            ['C8'] =>
                     'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B;upgrade=cost:20,terrain:lake',
            ['C26'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B',
            ['E22'] =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;label=NY;upgrade=cost:20,terrain:lake',
            ['G18'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',
          },
          blue: { ['C12'] => '' },
        }.freeze
      end
    end
  end
end
