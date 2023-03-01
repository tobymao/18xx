# frozen_string_literal: true

module Engine
  module Game
    module G18FL
      module Map
        TILE_TYPE = :lawson

        TILES = {
          '3' => 6,
          '4' => 8,
          '6o' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=O',
          },
          '6fl' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=FL',
          },
          '8' => 10,
          '9' => 14,
          '58' => 8,
          '15' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          '80' => 4,
          '81' => 4,
          '82' => 6,
          '83' => 6,
          '141' => 5,
          '142' => 5,
          '143' => 5,
          '405' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=T',
          },
          '443o' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=O',
          },
          '443fl' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=FL',
          },
          '487' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:1;city=revenue:40,slots:1;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=Jax',
          },
          '63' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;label=O;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0',
          },
          '146' => 8,
          '431' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:1,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=T',
          },
          '488' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:1;city=revenue:50,slots:1;label=Jax;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1',
          },
          '544' => 2,
          '545' => 2,
          '546' => 2,
          '611' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;label=FL;'\
            'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '489' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Jax',
          },
        }.freeze

        LOCATION_NAMES = {
          'A22' => 'Savannah',
          'B1' => 'New Orleans',
          'B5' => 'Mobile',
          'B7' => 'Pensacola',
          'B13' => 'Chattahoochee',
          'B15' => 'Tallahassee',
          'B19' => 'Lake City',
          'B23' => 'Jacksonville',
          'C14' => 'St. Marks',
          'C24' => 'St. Augustine',
          'D19' => 'Cedar Key',
          'D23' => 'Palatka',
          'D25' => 'Daytona',
          'E26' => 'Titusville',
          'F23' => 'Orlando',
          'G20' => 'Tampa',
          'I22' => 'Punta Gorda',
          'I28' => 'West Palm Beach',
          'J27' => 'Fort Lauderdale',
          'K28' => 'Miami',
          'M24' => 'Key West',
          'N23' => 'Havana',
        }.freeze

        HEXES = {
          white: {
            %w[B3 B9 B11 B17 B21 C12 C16 C18 C20 C22 D21 E20 E22 E24 F21 F25 G22 G26 H21] => '',
            %w[G24 H23 I24 J23 J25 K24] => 'upgrade=cost:40,terrain:swamp',
            ['H25'] => 'upgrade=cost:40,terrain:swamp;border=edge:5,type:impassable;border=edge:4,type:impassable',
            ['I26'] => 'upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['H27'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['K26'] => 'upgrade=cost:40,terrain:swamp;border=edge:5,type:impassable',
            ['L27'] => 'upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable',
            ['J27'] => 'city=revenue:0;label=FL',
            ['F23'] => 'city=revenue:0;label=O',
            %w[B7 B13 B19 C14 C24 D19 D23 D25 E26 I22 I28] => 'town=revenue:0',
            ['M26'] => 'upgrade=cost:80,terrain:water',
            ['M24'] => 'town=revenue:0;upgrade=cost:80,terrain:water',
          },
          yellow: {
            ['B5'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;label=K;icon=image:port,sticky:1',
            ['B15'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:6,b:_0;label=K',
            ['B23'] => 'city=revenue:30;city=revenue:30;path=a:5,b:_0;path=a:6,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=Jax;'\
                       'icon=image:port,sticky:1',
            ['G20'] => 'city=revenue:30;path=a:5,b:_0;path=a:3,b:_0;label=T;icon=image:port,sticky:1',
            ['K28'] => 'city=revenue:30;path=a:6,b:_0;path=a:2,b:_0;label=T;icon=image:port,sticky:1',
          },
          red: {
            ['A22'] => 'offboard=revenue:yellow_30|brown_80;path=a:5,b:_0',
            ['B1'] => 'offboard=revenue:yellow_40|brown_70;path=a:4,b:_0',
            ['N23'] => 'offboard=revenue:yellow_60|brown_100;path=a:3,b:_0',
          },
          gray: {
            %w[A2 A8 A10 A12 A14 A16 A18 A20] => '',
            ['A4'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:5,b:_0',
            ['A6'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:6,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
