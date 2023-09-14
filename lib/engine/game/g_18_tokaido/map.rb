# frozen_string_literal: true

module Engine
  module Game
    module G18Tokaido
      module Map
        LOCATION_NAMES = {
          'A7' => 'North Chūgoku',
          'A11' => 'South Chūgoku',
          'A13' => 'Shikoku',
          'B6' => 'Maizuru',
          'B12' => 'Kōbe',
          'C9' => 'Kyōto',
          'C11' => 'Ōsaka',
          'C13' => 'Ōsaka-wan',
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
          'H8' => 'Fuji-san',
          'H10' => 'Shizuoka',
          'I3' => 'Matsumoto',
          'I7' => 'Hachiōji',
          'I9' => 'Yokohama',
          'J2' => 'Nagano',
          'J6' => 'Takasaki',
          'J8' => 'Tōkyō',
          'J10' => 'Tōkyō-wan',
          'K1' => 'West Tōhoku',
          'K7' => 'Tsukuba',
          'K9' => 'Chiba',
          'L6' => 'East Tōhoku',
        }.freeze

        LAYOUT = :flat

        HEXES = {
          white: {
            %w[C7 D8 E5 E9 E11 F2 G7 K5] => '',
            %w[B8 B10 F6 H2 H4 H6 H8 I1 I5 J4 K3] => 'upgrade=cost:40,terrain:mountain',
            %w[B6 D10 D6 D12 I3 I7 J6 K7 K9] => 'town=revenue:0',
            %w[G5] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B12 G3 I9] => 'city=revenue:0',
            %w[C9 F8] => 'city=revenue:0;label=Y',
          },
          yellow: {
            ['C11'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_1;label=O',
            ['F4'] => 'city=revenue:20;path=a:2,b:_0;path=a:4,b:_0',
            ['J8'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=OO',
            ['J2'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=Y',
          },
          gray: {
            ['E13'] => 'path=a:2,b:3',
            ['G9'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:5',
            ['H10'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:4',
          },
          red: {
            ['A7'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:5,b:_0',
            ['A11'] =>
              'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:Chuugoku;path=a:4,b:_0;path=a:5,b:_0',
            ['A13'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0',
            ['K1'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:0,b:_0;path=a:1,b:_0',
            ['L6'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:2,b:_0',
          },
          blue: {
            ['E7'] => '',
            ['C13'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0',
            ['E3'] => 'offboard=revenue:yellow_30|green_40|brown_60;path=a:5,b:_0',
            ['F10'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:3,b:_0',
            ['G1'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:0,b:_0',
            ['J10'] => 'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
