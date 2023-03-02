# frozen_string_literal: true

module Engine
  module Game
    module G1877
      module Map
        TILES = {
          '5' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '441' => 'unlimited',
          '442' => 'unlimited',
          '444' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '38' => 'unlimited',
          'X1' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' =>
            'city=revenue:50;city=revenue:50;path=a:1,b:_0;path=a:_1,b:5;label=C',
          },
          'X2' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:0,b:_0;label=M',
          },
          'X3' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:1,b:_0;path=a:_0,b:5;label=C',
          },
          'X4' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:0,b:_0;label=M',
          },
          'X5' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;label=⛏️',
          },
          'X6' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0;label=⛏️',
          },
          'X7' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:3,b:_0;label=⛏️',
          },
        }.freeze

        LOCATION_NAMES = {
          'E2' => 'Acarigua',
          'H3' => 'Barcelona',
          'D3' => 'Barquisimeto',
          'G6' => 'Cabruta',
          'F5' => 'Calabozo',
          'F1' => 'Caracas',
          'A6' => 'Colombia',
          'B5' => 'San Cristobal',
          'H5' => 'El Pilar',
          'I4' => 'Guayana City',
          'L5' => 'Guyana',
          'B1' => 'Maracaibo',
          'C4' => 'El Vigía',
          'F3' => 'San Juan de Los Morros',
          'J1' => 'Trinidad & Tobago',
          'G4' => 'Zaraza',
        }.freeze

        HEXES = {
          white: {
            %w[C6 D5 E4 E6 G2 G8 H7 I6 J5 D1] => '',
            ['C2'] => 'border=edge:2,type:impassable;border=edge:1,type:impassable',
            ['B3'] => 'border=edge:4,type:impassable',
            ['K4'] => 'border=edge:2,type:impassable',
            ['J3'] => 'border=edge:5,type:impassable',
            ['I2'] => 'upgrade=cost:15,terrain:mountain',
            %w[D3 C4] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[E2 H3 F5 B5 F3 G4] => 'city=revenue:0',
            ['F7'] => 'upgrade=cost:10,terrain:water',
            %w[G6 I4 H5] => 'city=revenue:0;upgrade=cost:10,terrain:water',
          },
          red: {
            ['A6'] => 'offboard=revenue:yellow_20|green_30;path=a:4,b:_0',
            ['L5'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:2,b:_0',
            ['J1'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0',
          },
          yellow: {
            ['F1'] =>
                     'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_1,b:5;label=C',
            ['B1'] =>
            'city=revenue:40;path=a:0,b:_0;label=M;border=edge:5,type:impassable',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
