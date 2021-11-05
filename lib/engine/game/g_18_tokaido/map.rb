# frozen_string_literal: true

module Engine
  module Game
    module G18Tokaido
      module Map
        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 3,
          '15' => 3,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 3,
          '58' => 3,
          '70' => 1,
          '87' => 1,
          '88' => 1,
          '201' => 2,
          '202' => 2,
          '204' => 2,
          '207' => 2,
          '208' => 2,
          '611' => 3,
          '619' => 3,
          '621' => 2,
          '622' => 2,
          '915' => 1,
          'X1' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;label=Y',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
          },
          'X10' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:3,b:_1;path=a:_1,b:4;label=O',
          },
          'X11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=O',
          },
          'X13' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=O',
          },
          'X14' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
          'X20' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=T',
          },
          'X21' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:3,b:_1;path=a:_1,b:4;label=T',
          },
          'X22' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=T',
          },
          'X23' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=T',
          },
          'X24' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:100,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=T',
          },
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Chugoku',
          'A13' => 'Awaji and Shikoku',
          'B6' => 'Maizuru',
          'B12' => 'Kobe',
          'C9' => 'Kyoto',
          'C11' => 'Osaka',
          'C13' => 'Osaka-wan',
          'D6' => 'Tsuruga',
          'D10' => 'Nara',
          'D12' => 'Wakayama',
          'E3' => 'Nihon-kai',
          'E7' => 'Biwa-ko',
          'F4' => 'Kanazawa',
          'F8' => 'Nagoya',
          'F10' => 'Ise-wan',
          'G1' => 'Toyama-wan',
          'G3' => 'Toyama',
          'G5' => 'Takayama',
          'G9' => 'Hamamatsu',
          'H10' => 'Shizuoka',
          'I3' => 'Matsumoto',
          'I7' => 'Hachioji',
          'I9' => 'Yokohama',
          'J2' => 'Nagano',
          'J6' => 'Takasaki',
          'J8' => 'Tokyo',
          'J10' => 'Tokyo-wan',
          'K1' => 'Niigata and Tohoku',
          'K7' => 'Tsukuba',
          'K9' => 'Chiba',
          'L6' => 'Mito and Tohoku',
        }.freeze

        LAYOUT = :flat

        HEXES = {
          white: {
            %w[D8 E5 E9 E11 F2 G7 K5] => '',
            %w[B8 B10 C7 F6 H2 H4 H6 H8 I1 I5 J4 K3] => 'upgrade=cost:40,terrain:mountain',
            %w[B6 D10 D6 D12 I3 I7 J6 K7 K9] => 'town=revenue:0',
            %w[G5] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B12 G3 I9] => 'city=revenue:0',
            %w[C9 F8] => 'city=revenue:0;label=Y',
          },
          yellow: {
            ['C11'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_1;label=O',
            ['F4'] => 'city=revenue:20;path=a:2,b:_0;path=a:4,b:_0',
            ['J8'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=T',
            ['J2'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=Y',
          },
          gray: {
            ['A11'] => 'path=a:4,b:5',
            ['E13'] => 'path=a:2,b:3',
            ['G9'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:5',
            ['H10'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:4',
          },
          red: {
            ['A7'] =>
              'offboard=revenue:yellow_30|green_40|brown_60|gray_80,hide:1,groups:Chuugoku;path=a:4,b:_0;' \
              'path=a:5,b:_0;border=edge:0',
            ['A9'] =>
              'offboard=revenue:yellow_30|green_40|brown_60|gray_80,groups:Chuugoku;path=a:4,b:_0;path=a:5,b:_0;border=edge:3',
            ['A13'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:4,b:_0',
            ['K1'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0',
            ['L6'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:1,b:_0;path=a:2,b:_0',
          },
          blue: {
            ['E7'] => '',
            ['C13'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0',
            ['E3'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:5,b:_0',
            ['F10'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:3,b:_0',
            ['G1'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0',
            ['J10'] => 'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
