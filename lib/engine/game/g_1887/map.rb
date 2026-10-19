# frozen_string_literal: true

module Engine
  module Game
    module G1887
      module Map
        LAYOUT = :flat

        LOCATION_NAMES = {
          'A5' => 'Kalama',
          'B6' => 'Rainier (1L)',
          'B16' => 'Mt. Rainier N.P.',
          'C1' => 'Aberdeen',
          'C5' => 'Olympia',
          'C9' => 'Steilacoom',
          'C11' => 'Meeker',
          'C13' => 'Wilson Spur (5L)',
          'C15' => 'Wilkeson & Carbonado',
          'C19' => 'Yakima Valley (6A)',
          'D2' => 'Montesano',
          'D4' => 'Shelton (8L)',
          'D10' => 'Tacoma',
          'E3' => 'Union',
          'E9' => 'Red Ferry',
          'E13' => 'Renton',
          'E17' => 'Snoqualmie (10L)',
          'E21' => 'Tri-Cities',
          'F14' => 'Bellevue',
          'F16' => 'Issaquah',
          'G9' => 'Orange Ferry',
          'G13' => 'Seattle & Ballard',
          'G15' => 'Kirkland',
          'H6' => 'Olympic N.P.',
          'H8' => 'Quilcene',
          'H16' => 'Monroe',
          'H20' => 'Wenatchee Valley (15A)',
          'I5' => 'Historical Accuracy (16A)',
          'I9' => 'Port Ludlow (17L)',
          'I15' => 'Everett',
          'I19' => 'Sultan',
          'J10' => 'Port Townsend',
          'J12' => 'Yellow Ferry',
          'J22' => 'Spokane',
          'K7' => 'Port Angeles',
          'K15' => 'Mt. Vernon & Burlington',
          'K17' => 'Sedro-Woolley (20L)',
          'K21' => 'Grand Coulee',
          'M15' => 'Bellingham',
          'M19' => 'Okanagan (22A)',
        }.freeze

        LUMBER_HOME = 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=L'
        FERRY = 'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2'

        HEXES = {
          white: {
            %w[B4 B8 B10 C7 D14 D16 E15 F4 F6 F18 G7 G17 H14 I17 J8 J16 J18] => '',
            %w[C17 D20 F20 G19 H18 I7 J6 J20 K19 L18 L20] => 'upgrade=cost:40,terrain:mountain',
            %w[A7 C3] => 'upgrade=cost:20,terrain:swamp',
            %w[C9 C11 D2 E3 E13 H8 H16] => 'city=revenue:0',
            %w[C5 I15] => 'city=revenue:0;label=Y',
            %w[J10 K7] => 'city=revenue:0;label=P',
            %w[C15 K15] => 'city=revenue:0;city=revenue:0;label=OO',
            %w[B6 C13 D4 E17 I9 K17] => LUMBER_HOME,
            %w[C19] => 'town=revenue:20;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=A',
            %w[H20] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=A',
            %w[I5] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=A',
            %w[M19] => 'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=A',
            %w[I19] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[D10] => 'city=revenue:0;label=T;border=edge:0,type:water,cost:20',
            %w[D18] => 'upgrade=cost:40,terrain:mountain;border=edge:5,type:water,cost:20',
            %w[E19 M17] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:water,cost:20',
            %w[L16] => 'upgrade=cost:20,terrain:swamp;border=edge:5,type:water,cost:20',
            %w[D12] => 'border=edge:3,type:water,cost:20',
            %w[F12] => 'border=edge:0,type:water,cost:40',
            %w[F14] => 'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:3,type:water,cost:40;'\
                       'border=edge:4,type:water,cost:40',
            %w[F16 G15] => 'city=revenue:0;border=edge:3,type:water,cost:40',
            %w[G13] => 'city=revenue:20;city=revenue:20;path=a:2,b:_0;path=a:5,b:_1;label=S;'\
                       'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
          },
          gray: {
            %w[A5] => 'city=revenue:yellow_20|green_40|brown_50|gray_60,slots:2;'\
                      'path=a:0,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            %w[C1] => 'city=revenue:yellow_20|green_40|brown_20|gray_20,slots:2;'\
                      'path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            %w[E21] => 'city=revenue:yellow_20|green_40|brown_20|gray_20,slots:2;'\
                       'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            %w[J22] => 'city=revenue:yellow_20|green_40|brown_50|gray_60,slots:2;'\
                       'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            %w[M15] => 'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;'\
                       'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            %w[K21] => 'city=revenue:0,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[B16] => 'city=revenue:yellow_10|green_20|brown_40|gray_60,slots:2;'\
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[H6] => 'city=revenue:yellow_10|green_20|brown_40|gray_60,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[B12] => '',
            %w[B14] => 'path=a:0,b:4',
            %w[G5] => 'path=a:2,b:5',
            %w[I21] => 'path=a:3,b:5',
          },
          blue: {
            %w[D8 E11 K13 L14] => '',
            %w[E9] => "#{FERRY};path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0",
            %w[G9 J12] => "#{FERRY};path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0",
            %w[E5 K9] => 'path=a:0,b:3',
            %w[E7] => 'path=a:0,b:3;path=a:2,b:5',
            %w[D6 F8 F10] => 'path=a:2,b:5',
            %w[H10] => 'path=a:1,b:5',
            %w[H12] => 'path=a:2,b:5;path=a:1,b:4',
            %w[G11] => 'path=a:2,b:4;path=a:3,b:5',
            %w[I11] => 'path=a:1,b:5;path=a:2,b:4',
            %w[I13] => 'path=a:0,b:2',
            %w[J14] => 'path=a:3,b:5',
            %w[K11] => 'path=a:1,b:3',
          },
        }.freeze

        TILES = {
          'WA12' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:4,b:_1;label=OO',
            },
          'WA26' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:40,slots:2;city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:5,b:_1;label=S',
            },
          'WA27' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:40;city=revenue:40,slots:2;path=a:2,b:_0;path=a:1,b:_1;'\
                        'path=a:5,b:_1;label=S',
            },
          'WA1' =>
            {
              'count' => 6,
              'color' => 'yellow',
              'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'WA3' =>
            {
              'count' => 6,
              'color' => 'green',
              'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'WA5' =>
            {
              'count' => 6,
              'color' => 'brown',
              'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'WA6' =>
            {
              'count' => 6,
              'color' => 'gray',
              'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'WA7' =>
            {
              'count' => 4,
              'color' => 'yellow',
              'code' => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=A',
            },
          'WA9' =>
            {
              'count' => 4,
              'color' => 'green',
              'code' => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=A',
            },
          'WA10' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=A',
            },
          'WA11' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=A',
            },
          'WA13' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;label=OO',
            },
          'WA14' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;label=OO',
            },
          'WA15' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;label=OO',
            },
          'WA16' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;path=a:5,b:_0;label=L',
            },
          'WA17' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=A',
            },
          'WA18' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=P',
            },
          'WA19' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=P',
            },
          'WA20' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=P',
            },
          'WA21' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=P',
            },
          'WA22' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=T',
            },
          'WA23' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                        'label=T',
            },
          'WA24' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                        'label=T',
            },
          'WA25' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                        'label=T',
            },
          'WA28' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
            },
          'WA29' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:60,slots:4;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
            },
          'WA30' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;label=S',
            },
          'WA31' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;label=S',
            },
          'WA32' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;label=Y',
            },
          'WA33' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=Y',
            },
          'WA34' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Y',
            },
          'WA35' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=Y',
            },
          'WA36' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'label=Y',
            },
          'WA37' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                        'label=Y',
            },
          'WA38' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'label=Y',
            },
          'WA39' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;label=Y',
            },
          'WA40' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;label=Y',
            },
          'WA41' =>
            {
              'count' => 4,
              'color' => 'yellow',
              'code' => 'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            },
          'WA42' =>
            {
              'count' => 6,
              'color' => 'yellow',
              'code' => 'city=revenue:10;path=a:0,b:_0;path=a:2,b:_0',
            },
          'WA43' =>
            {
              'count' => 6,
              'color' => 'yellow',
              'code' => 'city=revenue:10;path=a:0,b:_0;path=a:3,b:_0',
            },
          'WA44' =>
            {
              'count' => 6,
              'color' => 'green',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          'WA45' =>
            {
              'count' => 6,
              'color' => 'green',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'WA46' =>
            {
              'count' => 6,
              'color' => 'green',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            },
          'WA47' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0;path=a:5,b:_0',
            },
          'WA48' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_0',
            },
          '7' => 4,
          '8' => 6,
          '9' => 6,
          '80' => 3,
          '81' => 3,
          '82' => 3,
          '83' => 3,
          '63' => 4,
          '448' => 4,
          '611' => 4,
          '544' => 3,
          '545' => 3,
          '546' => 3,
        }.freeze
      end
    end
  end
end
