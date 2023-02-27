# frozen_string_literal: true

module Engine
  module Game
    module G1830
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 4,
          '8' => 8,
          '9' => 7,
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '53' => 2,
          '54' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '59' => 2,
          '61' => 2,
          '62' => 1,
          '63' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'D2' => 'Lansing',
          'F2' => 'Chicago',
          'J2' => 'Gulf',
          'F4' => 'Toledo',
          'J14' => 'Washington',
          'F22' => 'Providence',
          'E5' => 'Detroit & Windsor',
          'D10' => 'Hamilton & Toronto',
          'F6' => 'Cleveland',
          'E7' => 'London',
          'A11' => 'Canadian West',
          'K13' => 'Deep South',
          'E11' => 'Dunkirk & Buffalo',
          'H12' => 'Altoona',
          'D14' => 'Rochester',
          'C15' => 'Kingston',
          'I15' => 'Baltimore',
          'K15' => 'Richmond',
          'B16' => 'Ottawa',
          'F16' => 'Scranton',
          'H18' => 'Philadelphia & Trenton',
          'A19' => 'Montreal',
          'E19' => 'Albany',
          'G19' => 'New York & Newark',
          'I19' => 'Atlantic City',
          'F24' => 'Mansfield',
          'B20' => 'Burlington',
          'E23' => 'Boston',
          'B24' => 'Maritime Provinces',
          'D4' => 'Flint',
          'F10' => 'Erie',
          'G7' => 'Akron & Canton',
          'G17' => 'Reading & Allentown',
          'F20' => 'New Haven & Hartford',
          'H4' => 'Columbus',
          'B10' => 'Barrie',
          'H10' => 'Pittsburgh',
          'H16' => 'Lancaster',
        }.freeze

        HEXES = {
          red: {
            ['F2'] =>
                     'offboard=revenue:yellow_40|brown_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I1'] =>
                   'offboard=revenue:yellow_30|brown_60,hide:1,groups:Gulf;path=a:4,b:_0;border=edge:5',
            ['J2'] =>
                   'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['A9'] =>
                   'offboard=revenue:yellow_30|brown_50,hide:1,groups:Canada;path=a:5,b:_0;border=edge:4',
            ['A11'] =>
                   'offboard=revenue:yellow_30|brown_50,groups:Canada;path=a:5,b:_0;path=a:0,b:_0;border=edge:1',
            ['K13'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            ['B24'] => 'offboard=revenue:yellow_20|brown_30;path=a:1,b:_0;path=a:0,b:_0',
          },
          gray: {
            ['D2'] => 'city=revenue:20;path=a:5,b:_0;path=a:4,b:_0',
            ['F6'] => 'city=revenue:30;path=a:5,b:_0;path=a:0,b:_0',
            ['E9'] => 'path=a:2,b:3',
            ['H12'] => 'city=revenue:10,loc:2.5;path=a:1,b:_0;path=a:4,b:_0;path=a:1,b:4',
            ['D14'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0',
            ['C15'] => 'town=revenue:10;path=a:1,b:_0;path=a:3,b:_0',
            ['K15'] => 'city=revenue:20;path=a:2,b:_0',
            ['A17'] => 'path=a:0,b:5',
            ['A19'] => 'city=revenue:40;path=a:5,b:_0;path=a:0,b:_0',
            %w[I19 F24] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['D24'] => 'path=a:1,b:0',
          },
          white: {
            %w[F4 J14 F22] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            ['E7'] => 'town=revenue:0;border=edge:5,type:impassable',
            ['F8'] => 'border=edge:2,type:impassable',
            ['C11'] => 'border=edge:5,type:impassable',
            ['C13'] => 'border=edge:0,type:impassable',
            ['D12'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['B16'] => 'city=revenue:0;border=edge:5,type:impassable',
            ['C17'] => 'upgrade=cost:120,terrain:mountain;border=edge:2,type:impassable',
            %w[B20 D4 F10] => 'town',
            %w[I13
               D18
               B12
               B14
               B22
               C7
               C9
               C23
               D8
               D16
               D20
               E3
               E13
               E15
               F12
               F14
               F18
               G3
               G5
               G9
               G11
               H2
               H6
               H8
               H14
               I3
               I5
               I7
               I9
               J4
               J6
               J8] => 'blank',
            %w[G15 C21 D22 E17 E21 G13 I11 J10 J12] =>
            'upgrade=cost:120,terrain:mountain',
            %w[E19 H4 B10 H10 H16] => 'city',
            ['F16'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[G7 G17 F20] => 'town=revenue:0;town=revenue:0',
            %w[D6 I17 B18 C19] => 'upgrade=cost:80,terrain:water',
          },
          yellow: {
            %w[E5 D10] =>
                     'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:water',
            %w[E11 H18] => 'city=revenue:0;city=revenue:0;label=OO',
            ['I15'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',
            ['G19'] =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:0,b:_1;label=NY;upgrade=cost:80,terrain:water',
            ['E23'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
