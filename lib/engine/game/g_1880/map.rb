# frozen_string_literal: true

module Engine
  module Game
    module G1880
      module Map
        LAYOUT = :pointy
        TILES = {
          '5' => 6,
          '6' => 6,
          '7' => 5,
          '8' => 15,
          '9' => 15,
          '14' => 4,
          '15' => 8,
          '16' => 2,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '23' => 4,
          '24' => 4,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 1,
          '31' => 1,
          '57' => 6,
          '63' => 6,
          '235' => 5,
          '455' => 3,
          '611' => 3,
          '619' => 4,
          '887' => 5,
          '888' => 3,
          '895' => 3,

          # special to be defined later
          '8850' =>
          {
            'count' => 5,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:5,b:_0',
          },
          '8851' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:4,b:_0',
          },
          '8852' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
          },
          '8854' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_1',
          },
          '8855' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0;path=a:3,b:_0;path=a:2,b:_1;path=a:5,b:_1',
          },
          '8856' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0;path=a:4,b:_0;path=a:3,b:_1;path=a:5,b:_1',
          },
          '8857' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:3,b:_1;path=a:5,b:_1',
          },
          '8858' => 2,
          '8860' => 1,

          '8861' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=OO',
          },
          '8862' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=OO',
          },
          '8863' => 1,
          '8864' => 1,
          '8865' => 1,
          '8866' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          '8871' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '8872' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=OO',
          },
          '8873' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=OO',
          },
          '8874' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=OO',
          },
          '8875' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
          },
          '8877' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:_0,b:3;label=S',
          },

          '8878' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
          },
          '8879' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
          },
          '8880' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
          },
          '8886' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=B',
          },
          '8887' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:6;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
          '8888' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:6;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
        }.freeze

        LOCATION_NAMES = {
          'A3' => 'Russia',
          'A5' => 'Qiqihar',
          'A15' => 'Vladivostok',
          'B8' => 'Harbin',
          'C9' => 'Changchun',
          'C11' => 'Jilin City',
          'D12' => 'Shenyang & Fushun',
          'E13' => 'Dalian',
          'F4' => 'Hohhot & Datong',
          'F8' => 'Beijing',
          'F10' => 'Tianjin',
          'G3' => 'Baotou',
          'H6' => 'Taiyuan',
          'H10' => 'Jinan',
          'H14' => 'Qingdao',
          'I1' => 'Urümqi',
          'J2' => 'Lanzhou',
          'J6' => "Xi'an",
          'I9' => 'Kaifeng & Zhengzhou',
          'J12' => 'Hefei',
          'K1' => 'Lhasa',
          'K13' => 'Manjing',
          'K15' => 'Shanghai',
          'L10' => 'Wuhan',
          'M3' => 'Chengdu',
          'M7' => 'Chongqing',
          'N12' => 'Changsha & Manchang',
          'N16' => 'Taiwan',
          'O5' => 'Kunming',
          'P8' => 'Nanning',
          'P12' => 'Macau',
          'P14' => 'Guangzhou',
          'Q7' => 'French Indonesia',
          'Q13' => 'Haikou',
          'Q15' => 'Hong Kong',
        }.freeze

        HEXES = {
          red: {
            %w[Q7] =>
                     'city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            %w[A15] =>
                     'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:0,b:_0;path=a:1,b:_0',
            %w[A3] =>
                     'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            %w[I1] =>
                     'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',

            %w[K1] =>
                     'offboard=revenue:yellow_0|green_0|brown_0|gray_80;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',

            %w[Q15] =>
                     'city=revenue:yellow_20|green_30|brown_10|gray_70;path=a:2,b:_0,terminal:1',
          },
          blue: {
            ['F12'] => 'path=a:3,b:1',
            %w[F14 J16] => 'path=a:2,b:0',
            ['I15'] => 'path=a:2,b:5',
            ['N16'] => 'offboard=revenue:yellow_30|green_30|brown_0|gray_0;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['Q13'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:2,b:_0;path=a:3,b:_0',
          },
          yellow: {
            %w[F8] => 'city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;'\
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:3,b:_2;path=a:4,b:_3;label=B',
          },
          white: {
            %w[A9 A11 A13 B6 B10 C13 D10 F2 G7 G13 I11 I13 J10 K11 M9 M11 M13 N14 O13] => '',
            %w[B4 C3 C5 C15 D6 D8 E3 E5 E7 H2 I3 J4 K3 K9 L4 L6 N8 O9] => 'upgrade=cost:30,terrain:mountain',
            %w[L2 M1 N2 P2] => 'upgrade=cost:40,terrain:mountain',
            %w[G1 H4 I5 N6] => 'upgrade=cost:20,terrain:river',
            %w[G5 I7 L8] => 'upgrade=cost:50,terrain:mountain|river',
            %w[O1] => 'upgrade=cost:60,terrain:mountain|river',
            %w[J2] => 'city=revenue:0;upgrade=cost:50,terrain:mountain|river',
            %w[G3 H10 K13 L10 M7] => 'city=revenue:0;upgrade=cost:20,terrain:river',
            %w[I9] => 'city=revenue:0;city=revenue:0;upgrade=cost:20,terrain:river',
            %w[G11 J14] => 'town=revenue:0;upgrade=cost:20,terrain:river',
            %w[L12 O3] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:river',
            %w[A5 B8 C9 C11 F10 H6 H14 J12 M3 O5 P8 P12 P14] => 'city=revenue:0',
            %w[K15] => 'city=revenue:0;label=S',
            %w[A7 C7 D14 G9 G15 L16 M15 P6] => 'town=revenue:0',
            %w[B12 H12 O11] => 'town=revenue:0;town=revenue:0',
            %w[B14 E9 F6 L14 N10] => 'town=revenue:0;city=revenue:0',
            %w[H8] => 'town=revenue:0;city=revenue:0;town=revenue:0;city=revenue:0',
            %w[N4] => 'town=revenue:0;city=revenue:0;town=revenue:0;city=revenue:0;upgrade=cost:20,terrain:river',
            %w[D4 K5 K7 M5 O15 P10] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[P4] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[J8] => 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[J6] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[O7] => 'city=revenue:0;town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[D12 F4 N12] => 'city=revenue:0;city=revenue:0',
            ['E11'] => 'border=edge:4,type:impassable',
            ['E13'] => 'city=revenue:0;border=edge:1,type:impassable',
          },
        }.freeze
      end
    end
  end
end
