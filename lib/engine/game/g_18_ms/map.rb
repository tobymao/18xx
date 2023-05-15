# frozen_string_literal: true

module Engine
  module Game
    module G18MS
      module Map
        LAYOUT = :pointy

        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 3,
          '7' => 4,
          '8' => 10,
          '9' => 10,
          '57' => 3,
          '58' => 3,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '87' => 2,
          '88' => 2,
          '143' => 2,
          '204' => 2,
          '619' => 3,
          '39' => 1,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '63' => 4,
          '446' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=BM',
          },
          'X31b' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Mob',
          },
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'Memphis',
          'B2' => 'Grenada',
          'B12' => 'Chattanooga',
          'C5' => 'Starkville',
          'C7' => 'Tuscaloosa',
          'C9' => 'Birmingham',
          'D6' => 'York',
          'E1' => 'Jackson',
          'E5' => 'Meridian',
          'E9' => 'Selma',
          'E11' => 'Montgomery',
          'E15' => 'Atlanta',
          'G3' => 'Hattiesburg',
          'H4' => 'Gulfport',
          'H6' => 'Mobile',
          'H8' => 'Pensacola',
          'H10' => 'Tallahassee',
          'I1' => 'New Orleans',
        }.freeze

        HEXES = {
          empty: { ['B14'] => '' },
          white: {
            %w[B4
               B6
               B8
               B10
               C1
               C3
               C11
               D2
               D4
               D8
               D10
               E3
               F4
               F10
               G5
               G9
               G11] => '',
            %w[E7 F2 F6 F8 G1 G7] => 'upgrade=cost:20,terrain:water',
            ['H2'] => 'upgrade=cost:40,terrain:water',
            ['H8'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[C7 E5 E9] => 'city=revenue:0',
            %w[H6] => 'city=revenue:0;future_label=label:Mob,color:brown',
            %w[C9 E11] => 'city=revenue:0;future_label=label:BM,color:gray',
            %w[B2 C5 D6 G3 H4] => 'town=revenue:0',
          },
          red: {
            ['B12'] =>
            'offboard=revenue:yellow_40|brown_60;path=a:1,b:_0;icon=image:18_ms/coins',
            ['H10'] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0',
            ['A1'] =>
            'city=revenue:yellow_40|brown_50;path=a:5,b:_0;path=a:4,b:_0;border=edge:4',
            ['I1'] =>
            'city=revenue:yellow_50|brown_80,loc:center;town=revenue:10,loc:5.5;path=a:3,b:_0;path=a:_1,b:_0;'\
            'icon=image:18_ms/coins',
            ['A3'] => 'path=a:1,b:5;border=edge:1',
            ['D12'] => 'path=a:0,b:5;border=edge:5',
            ['E13'] =>
            'path=a:0,b:4;path=a:1,b:4;path=a:2,b:4;border=edge:0;border=edge:2;border=edge:4',
            ['F12'] => 'path=a:2,b:3;border=edge:3',
            ['E15'] => 'offboard=revenue:yellow_40|brown_50;path=a:1,b:_0;border=edge:1',
          },
          gray: {
            ['E1'] =>
            'city=revenue:yellow_30|brown_60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze
      end
    end
  end
end
