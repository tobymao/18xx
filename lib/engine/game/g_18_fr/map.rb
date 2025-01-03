# frozen_string_literal: true

module Engine
  module Game
    module G18FR
      module Map
        LAYOUT = :pointy
        TILE_TYPE = :lawson

        TILES = {
          '5' => 3,
          '6' => 3,
          '57' => 3,
          'FRC1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;label=C',
          },
          'FRC2' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;label=C',
          },
          'FRC3' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;label=C',
          },
          'FRBY' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:30;town=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_1;'\
                      'upgrade=cost:20,terrain:water;label=B',
          },
          'FRVY' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:6,b:_0;'\
                      'label=V',
          },
          'FRX' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:green_30|brown_40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'FRY' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:green_30|brown_40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:6,b:_0',
          },
          'FRK' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:green_30|brown_40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'FRCX' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:green_40|brown_50|gray_60,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'label=C',
          },
          'FRCY' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:green_40|brown_50|gray_60,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:6,b:_0;'\
                      'label=C',
          },
          'FRCK' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:green_50|brown_50|gray_60,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'label=C',
          },
          'FRBG' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;upgrade=cost:20,terrain:water;'\
                      'label=B',
          },
          'FRAG' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60,loc:1.5;city=revenue:60,loc:4.5;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;'\
                      'upgrade=cost:20,terrain:water;label=A',
          },
          'FRVG' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'path=a:6,b:_0;label=V',
          },
          'FRBB' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:brown_60|gray_80,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=B',
          },
          'FRAB' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:brown_80|gray_100,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=A',
          },
          'FRW' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=W',
          },
        }.freeze

        LOCATION_NAMES = {
          'A10' => 'North Sea',
          'B5' => 'English Chanel',
          'B9' => 'Lille',
          'B11' => 'Belgium',
          'C6' => 'Le Havre',
          'C8' => 'Rouen',
          'C10' => 'Reims',
          'C12' => 'Luxembourg',
          'D1' => 'Atlantic Ocean',
          'D3' => 'Brest',
          'D5' => 'Rennes',
          'D7' => 'Le Mans',
          'D9' => 'Paris',
          'D13' => 'Strasbourg',
          'D15' => 'Germany',
          'E4' => 'Bay of Biscay',
          'E6' => 'Nantes',
          'E8' => 'Orléans',
          'E10' => 'Troyes',
          'E12' => 'Dijon',
          'E14' => 'Switzerland',
          'F7' => 'Poitiers',
          'F9' => 'Vichy',
          'F11' => 'Lyon',
          'F13' => 'Italy',
          'G6' => 'Bordeaux',
          'G12' => 'Nice',
          'H5' => 'Bayonne',
          'H7' => 'Toulouse',
          'H9' => 'Montpellier',
          'H11' => 'Marseille',
          'I6' => 'Spain',
          'I10' => 'Mediterranean',
        }.freeze

        HEXES = {
          blue: {
            %w[C4 G4] => 'offboard=revenue:20;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_fr/beach',
            ['A10'] => 'offboard=revenue:30;path=a:6,b:_0;icon=image:port',
            ['B5'] => 'offboard=revenue:20;path=a:5,b:_0;icon=image:port',
            ['D1'] => 'offboard=revenue:40;path=a:4,b:_0;icon=image:port',
            ['E4'] => 'offboard=revenue:20;path=a:4,b:_0;icon=image:port',
            ['H13'] => 'offboard=revenue:20;path=a:1,b:_0;path=a:2,b:_0;icon=image:18_fr/beach',
            ['I10'] => 'offboard=revenue:yellow_20|green_40;path=a:2,b:_0;path=a:3,b:_0;icon=image:port',
          },
          red: {
            ['B11'] => 'offboard=revenue:yellow_30|green_50|brown_60;path=a:1,b:_0;path=a:6,b:_0',
            ['C12'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_100;path=a:1,b:_0',
            ['D15'] => 'offboard=revenue:yellow_40|green_50|brown_60;path=a:1,b:_0',
            ['E14'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_80;path=a:1,b:_0;path=a:2,b:_0',
            ['F13'] => 'offboard=revenue:yellow_20|green_40|brown_50;path=a:1,b:_0;path=a:6,b:_0',
            ['I6'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          white: {
            %w[C6 C8 D5 D13 E10 E12 G12 H5 H9] => 'city=revenue:0',
            %w[B9 E6 F11] => 'city=revenue:0;label=C',
            ['C10'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            ['E8'] => 'city=revenue:0;upgrade=cost:40,terrain:water;label=B',
            ['F9'] => 'city=revenue:0;label=V',
            ['G6'] => 'city=revenue:0;upgrade=cost:20,terrain:water;label=C',
            ['H7'] => 'city=revenue:0;upgrade=cost:20,terrain:water;label=B',
            ['H11'] => 'city=revenue:0;upgrade=cost:10,terrain:water;label=C',
          },
          gray: {
            ['D3'] => 'town=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            ['D7'] => 'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:6,b:_0',
            ['D11'] => 'town=revenue:10;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:6,b:_0;icon=image:tree',
            ['F7'] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:6,b:_0',
            ['G8'] => 'town=revenue:10;path=a:3,b:_0;path=a:5,b:_0;path=a:6,b:_0;icon=image:tree',
            ['G10'] => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0;path=a:6,b:_0;icon=image:tree',
            ['I4'] => 'path=a:3,b:4',
          },
          yellow: {
            ['D9'] => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;upgrade=cost:20,terrain:water;label=A',
          },
        }.freeze
      end
    end
  end
end
