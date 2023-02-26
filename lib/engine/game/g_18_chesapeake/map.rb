# frozen_string_literal: true

module Engine
  module Game
    module G18Chesapeake
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 5,
          '15' => 6,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 2,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 7,
          '58' => 2,
          '69' => 1,
          '70' => 1,
          '611' => 5,
          '915' => 1,
          'X1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=DC',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DC',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=OO',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
            'label=DC',
          },
          'X7' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=OO',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
            'label=DC',
          },
          'X9' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
          },
        }.freeze

        LOCATION_NAMES = {
          'B2' => 'Pittsburgh',
          'A7' => 'Ohio',
          'B14' => 'West Virginia Coal',
          'B4' => 'Charleroi & Connellsville',
          'C5' => 'Green Spring',
          'C13' => 'Lynchburg',
          'D2' => 'Berlin',
          'D8' => 'Leesburg',
          'D12' => 'Charlottesville',
          'E3' => 'Hagerstown',
          'E11' => 'Fredericksburg',
          'F2' => 'Harrisburg',
          'F8' => 'Washington DC',
          'G3' => 'Columbia',
          'G13' => 'Richmond',
          'H4' => 'Strasburg',
          'H6' => 'Baltimore',
          'H14' => 'Norfolk',
          'I5' => 'Wilmington',
          'I9' => 'Delmarva Peninsula',
          'J2' => 'Allentown',
          'J4' => 'Philadelphia',
          'J6' => 'Camden',
          'K1' => 'Easton',
          'K3' => 'Trenton & Amboy',
          'K5' => 'Burlington & Princeton',
          'L2' => 'New York',
        }.freeze
        HEXES = {
          white: {
            %w[B6 B8 B10 C3 C7 C9 C11 E7 E9 E13 F6 F12 G7 I7 J8 J10 L4 F4 G5 H2 I3] => '',
            %w[B12 D4 D6 D10 E5] => 'upgrade=cost:80,terrain:mountain',
            %w[F10 G9 G11 H12] => 'upgrade=cost:40,terrain:water',
            %w[B4 K3 K5] => 'town=revenue:0;town=revenue:0',
            %w[C5 D12 E3 F2 G13 J2] => 'city=revenue:0',
            %w[C13 D2 D8] => 'city=revenue:0;upgrade=cost:80,terrain:mountain',
            ['E11'] => 'town=revenue:0',
            ['F8'] => 'city=revenue:0;label=DC',
            %w[G3 I5] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[H4 J6] => 'city=revenue:0;upgrade=cost:40,terrain:water',
          },
          red: {
            ['A3'] =>
                     'city=revenue:yellow_40|green_50|brown_60|gray_80,hide:1,groups:Pittsburgh;path=a:5,b:_0;border=edge:4',
            ['B2'] =>
            'offboard=revenue:yellow_40|green_50|brown_60|gray_80,groups:Pittsburgh;path=a:0,b:_0;border=edge:1',
            ['A7'] =>
            'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:4,b:_0;path=a:5,b:_0',
            ['A13'] =>
            'offboard=revenue:yellow_40|green_50|brown_60|gray_80,hide:1,groups:West Virginia Coal;path=a:4,b:_0;border=edge:5',
            ['B14'] =>
            'offboard=revenue:yellow_40|green_50|brown_60|gray_80,groups:West Virginia Coal;path=a:3,b:_0;path=a:4,b:_0;'\
            'border=edge:2',
            ['H14'] =>
            'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0',
            ['L2'] =>
            'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:0,b:_0;path=a:1,b:_0',
          },
          gray: {
            ['E1'] => 'path=a:1,b:5',
            ['F14'] => 'path=a:3,b:4',
            ['G1'] => 'path=a:1,b:5;path=a:0,b:1',
            ['I9'] => 'town=revenue:30;path=a:3,b:_0;path=a:_0,b:5',
            ['K1'] => 'town=revenue:30;path=a:0,b:_0;path=a:_0,b:1',
            ['K7'] => 'path=a:2,b:3',
          },
          yellow: {
            ['H6'] =>
                     'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=OO;upgrade=cost:40,terrain:water',
            ['J4'] =>
            'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=OO',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
