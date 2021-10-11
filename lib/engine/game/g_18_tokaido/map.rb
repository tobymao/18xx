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
          '58' => 4,
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
            'count' => 2,
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
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=O',
          },
          'X14' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
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
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=T',
          },
          'X24' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=T',
          },
        }.freeze

        LOCATION_NAMES = {
          'A11' => 'Chugoku',
          'A15' => 'Shikoku',
          'B8' => 'Maizuru',
          'B14' => 'Kobe',
          'C11' => 'Kyoto',
          'C13' => 'Osaka',
          'C15' => 'Osaka-wan',
          'D8' => 'Tsuruga',
          'D12' => 'Nara',
          'D14' => 'Sakai',
          'E5' => 'Nihon-kai',
          'E9' => 'Biwa-ko',
          'F6' => 'Kanazawa',
          'F10' => 'Nagoya',
          'F12' => 'Ise-wan',
          'G3' => 'Toyama-wan',
          'G5' => 'Toyama',
          'G7' => 'Takayama',
          'G11' => 'Hamamatsu',
          'H12' => 'Shizuoka',
          'I5' => 'Matsumoto',
          'I9' => 'Saitama',
          'I11' => 'Yokohama',
          'J4' => 'Nagano',
          'J8' => 'Takasaki',
          'J10' => 'Tokyo',
          'J12' => 'Tokyo-wan',
          'K1' => 'Niigata',
          'K9' => 'Tsukuba',
          'K11' => 'Chiba',
          'L6' => 'Fukushima',
          'M3' => 'Aomori',
          'M5' => 'Sendai',
        }.freeze

        LAYOUT = :flat

        HEXES = {
          white: {
            %w[D10 E7 E11 E13 F4 G9 K7 L4] => '',
            %w[B10 B12 C9 F8 H4 H6 H8 H10 I3 I7 J2 J6 K3 K5] => 'upgrade=cost:40,terrain:mountain',
            %w[B8 D12 D8 D14 I5 I9 J8 K9 K11 L6] => 'town=revenue:0',
            %w[G7] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B14 F6 G5 I11 M5] => 'city=revenue:0',
            %w[C11 F10] => 'city=revenue:0;label=Y',
          },
          yellow: {
            ['C13'] =>
              'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_1;label=O',
            ['J10'] =>
              'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=T',
            ['J4'] =>
              'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=Y',
            ['L8'] =>
              'path=a:1,b:4',
            ['M7'] =>
              'path=a:1,b:3',
          },
          gray: {
            ['A13'] => 'path=a:4,b:5',
            ['E15'] => 'path=a:2,b:3',
            ['G11'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:5',
            ['H12'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:4',
          },
          red: {
            ['A9'] =>
              'offboard=revenue:yellow_30|brown_40|gray_50,hide:1,groups:Chuugoku;path=a:4,b:_0;' \
              'path=a:5,b:_0;border=edge:0',
            ['A11'] =>
              'offboard=revenue:yellow_30|brown_40|gray_50,groups:Chuugoku;path=a:4,b:_0;path=a:5,b:_0;border=edge:3',
            ['A15'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:4,b:_0',
            ['K1'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:0,b:_0;path=a:1,b:_0',
            ['M3'] =>
              'offboard=revenue:yellow_30|brown_40|gray_50;path=a:0,b:_0;path=a:1,b:_0',
          },
          blue: {
            ['E9'] => '',
            ['C15'] => 'offboard=revenue:yellow_30|brown_40|gray_50;path=a:2,b:_0;path=a:3,b:_0',
            ['E5'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:5,b:_0',
            ['F12'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:3,b:_0',
            ['G3'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:0,b:_0',
            ['J12'] =>
              'offboard=revenue:yellow_40|brown_50|gray_80;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
