# frozen_string_literal: true

module Engine
  module Game
    module G1861
      module Map
        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 2,
          '15' => 2,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 2,
          '22' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 2,
          '58' => 4,
          '63' => 3,
          '87' => 2,
          '88' => 2,
          '201' => 3,
          '202' => 3,
          '204' => 2,
          '207' => 5,
          '208' => 2,
          '611' => 3,
          '619' => 2,
          '621' => 2,
          '622' => 2,
          '623' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '635' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;city=revenue:40,loc:4.5;'\
                      'path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:3;label=K;upgrade=cost:40,terrain:water',
          },
          '636' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K',
          },
          '637' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;'\
                      'path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;'\
                      'path=a:2,b:_1;path=a:_1,b:3;label=M',
          },
          '638' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          '639' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          '640' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Kh',
          },
          '641' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S',
          },
          '642' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S',
          },
          '801' => 2,
          '911' => 3,
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Poland',
          'B4' => 'Riga',
          'B8' => 'Vilna',
          'B18' => 'Romania',
          'C5' => 'Dünaberg',
          'C9' => 'Minsk',
          'D14' => 'Kiev',
          'D20' => 'Odessa',
          'E1' => 'St. Petersburg',
          'E9' => 'Smolensk',
          'E11' => 'Gomel',
          'E13' => 'Chernigov',
          'F18' => 'Ekaterinoslav',
          'G5' => 'Tver',
          'G13' => 'Kursk',
          'G15' => 'Kharkov',
          'G19' => 'Alexandrovsk',
          'H8' => 'Moscow',
          'H10' => 'Tula',
          'H18' => 'Yuzovka',
          'I5' => 'Yaroslav',
          'I13' => 'Voronezh',
          'I17' => 'Lugansk',
          'I19' => 'Rostov',
          'J20' => 'Caucasus',
          'K7' => 'Nizhnii Novgorod',
          'K11' => 'Penza',
          'K17' => 'Tsaritsyn',
          'L12' => 'Saratov',
          'M7' => 'Kazan',
          'M9' => 'Simbirsk',
          'M19' => 'Astrakhan',
          'N10' => 'Samara',
          'P0' => 'Perm',
          'P8' => 'Ufa',
          'Q3' => 'Ekaterinburg (₽80 if includes M)',
          'Q11' => 'Central Asia',
        }.freeze

        HEXES = {
          white: {
            %w[B6 B10 B12 B14 B16 C3 C13 C15 D6 D8 D16 D18 E3 E5 E7 E17 F6 F8
               F10 F12 F14 F20 G3 G9 G11 G17 H2 H4 H6 H12 H14 H16 H20 I3 I7 I9
               I11 J2 J4 J8 J10 J12 J14 K3 K5 K9 K13 K15 K19 L2 L4 L8 L10 L14
               L18 L20 M3 M5 N2 N4 N8 N12 N20 O1 O3 O7 O9 O11 P6 P10 P12] => '',
            %w[B8 C9 E11 E13 G19 G13 H10 I17 K11] => 'town=revenue:0',
            ['I5'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            ['M9'] => 'town=revenue:0;upgrade=cost:80,terrain:water',
            %w[E9 H18 I13 I19 K17 L12 P8] => 'city=revenue:0',
            ['P2'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[F18 M7] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[B4 D20 M19 N10] => 'city=revenue:0;label=Y',
            ['G15'] => 'city=revenue:0;label=Y;future_label=label:Kh,color:gray',
            %w[C11 D12 M11] => 'upgrade=cost:80,terrain:water',
            %w[E15 E19 F16 I15 J16 J18] => 'upgrade=cost:40,terrain:water',
            %w[C17 C19 D10 J6 L6 N6 O5 P4] => 'upgrade=cost:20,terrain:water',
          },
          gray: {
            ['A5'] => 'path=a:4,b:5',
            ['C5'] => 'town=revenue:10;path=a:2,b:_0;path=a:5,b:_0;path=a:0,b:4',
            ['C21'] => 'path=a:4,b:3',
            ['M21'] => 'path=a:3,b:2',
            ['P0'] => 'path=a:0,b:1',
            ['Q7'] => 'path=a:1,b:2',
            ['Q5'] => 'path=a:3,b:2;path=a:3,b:1',
            ['Q3'] => 'city=revenue:40;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0',
          },
          yellow: {
            %w[C7 D4] => 'path=a:3,b:1',
            %w[F4 G7] => 'path=a:3,b:5',
            ['D2'] => 'path=a:0,b:4',
            ['F2'] => 'path=a:0,b:2',
            ['G5'] => 'town=revenue:10;path=a:2,b:_0;path=a:0,b:_0',
            ['H8'] =>
            'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=M',
            ['D14'] =>
            'city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=K',
            ['K7'] =>
            'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;label=Y;upgrade=cost:20,terrain:water',
          },
          green: {
            ['E1'] => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_1,b:5;label=S',
          },
          red: {
            ['A9'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Poland;'\
                      'path=a:5,b:_0;path=a:4,b:_0;border=edge:0',
            %w[A11 A13] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Poland;'\
                           'path=a:5,b:_0;path=a:4,b:_0;border=edge:3;border=edge:0',
            ['A15'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Poland;'\
                       'path=a:5,b:_0;path=a:4,b:_0;border=edge:3',
            ['B18'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30,groups:Romania;'\
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:0',
            ['B20'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30,hide:1,groups:Romania;'\
                       'path=a:4,b:_0;border=edge:3',
            ['J20'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,groups:Caucasus;'\
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;border=edge:5',
            ['I21'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1,groups:Caucasus;'\
                       'path=a:3,b:_0;border=edge:4',
            ['K21'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1,groups:Caucasus;'\
                       'path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['Q11'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:CentralAsia;'\
                       'path=a:1,b:_0;path=a:2,b:_0;border=edge:0',
            ['Q13'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:CentralAsia;'\
                       'path=a:2,b:_0;border=edge:3',
          },
          blue: {},
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
