# frozen_string_literal: true

module Engine
  module Game
    module G1828
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 4,
          '7' => 6,
          '8' => 16,
          '9' => 16,
          '14' => 6,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 3,
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
          '53' => 1,
          '54' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 8,
          '58' => 3,
          '59' => 3,
          '61' => 1,
          '62' => 1,
          '63' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 2,
          '121' => 1,
          '205' => 1,
          '206' => 1,
          '448' => 2,
          '449' => 2,
          '997' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A3' => 'Copper Country',
          'A5' => 'Marquette',
          'B14' => 'Barrie',
          'A7' => 'Mackinaw City',
          'C5' => 'Muskegon',
          'D4' => 'Grand Rapids',
          'D6' => 'Lansing',
          'D8' => 'Flint',
          'D10' => 'Sarnia',
          'D14' => 'Hamilton & Toronto',
          'E7' => 'Adrian & Ann Arbor',
          'E9' => 'Detroit & Windsor',
          'F8' => 'Toledo',
          'F10' => 'Cleveland',
          'F14' => 'Erie',
          'A13' => 'Canada',
          'A23' => 'Montreal',
          'B20' => 'Ottawa',
          'B24' => 'Burlington',
          'B28' => 'Maine',
          'C15' => 'Peterborough',
          'C19' => 'Kingston',
          'D18' => 'Rochester',
          'D24' => 'Schenectady',
          'E15' => 'Dunkirk & Buffalo',
          'E23' => 'Albany',
          'E27' => 'Boston',
          'F20' => 'Scranton',
          'F24' => 'New Haven & Hartford',
          'F26' => 'Providence',
          'F28' => 'Mansfield',
          'G3' => 'Chicago',
          'G11' => 'Akron & Canton',
          'H6' => 'Louisville',
          'H8' => 'Cincinnati',
          'H12' => 'Pittsburgh',
          'H14' => 'Johnstown',
          'I1' => 'West',
          'I3' => 'St Louis',
          'I11' => 'Washington',
          'J6' => 'Nashville',
          'K3' => 'New Orleans',
          'K11' => 'Virginia Coalfields',
          'K13' => 'Virginia Tunnel',
          'G21' => 'Reading & Allentown',
          'G23' => 'Newark & New York',
          'H16' => 'Altoona',
          'H20' => 'Lancaster',
          'H22' => 'Philadelphia & Trenton',
          'I19' => 'Baltimore',
          'I23' => 'Atlantic City',
          'J18' => 'Washington',
          'K15' => 'Richmond',
          'K19' => 'Norfolk',
          'L16' => 'Deep South',
          'L18' => 'Suffolk',
        }.freeze

        HEXES = {
          white: {
            %w[B16
               B18
               B26
               C7
               C13
               C27
               D12
               D20
               D22
               E5
               E17
               E19
               F6
               F16
               F18
               F22
               G5
               G7
               G9
               G13
               G15
               H4
               H10
               H18
               I5
               I7
               I9
               I13
               I17
               J4
               J8
               J10
               J12
               K17] => '',
            ['C17'] => 'border=edge:0,type:impassable',
            ['D16'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['F12'] => 'border=edge:2,type:impassable',
            %w[B6 B8 B22 C23 H2 I21 J2] =>
                   'upgrade=cost:80,terrain:water',
            ['E11'] => 'border=edge:5,type:impassable;upgrade=cost:80,terrain:water',
            ['C21'] => 'border=edge:2,type:impassable;upgrade=cost:120,terrain:mountain',
            %w[C25 D26 E21 E25 G17 G19 I15 J14 J16] =>
                   'upgrade=cost:120,terrain:mountain',
            %w[B14 D6 F8 F26 I3 J18] =>
                   'city=revenue:0;upgrade=cost:80,terrain:water',
            ['B20'] => 'city=revenue:0;border=edge:5,type:impassable',
            %w[D8 E23 H6 H8 H12 H20 K15] => 'city=revenue:0',
            ['F20'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[B24 D10 F14 H14 I11] => 'town=revenue:0',
            ['K13'] => 'town=revenue:0;upgrade=cost:120,terrain:mountain;icon=image:1828/coal',
            %w[E7 F24 G11 G21] => 'town=revenue:0;town=revenue:0',
          },
          yellow: {
            ['C15'] => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;' \
                       'upgrade=cost:80,terrain:water;border=edge:5,type:impassable',
            %w[D14 E9] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:water',
            %w[E15 H22] => 'city=revenue:0;city=revenue:0;label=OO',
            ['E27'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=Bo',
            ['G23'] =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;label=NY;upgrade=cost:80,terrain:water',
            ['I19'] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=Ba',
            ['J6'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
          },
          gray: {
            ['A5'] => 'town=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            ['A7'] => 'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0',
            ['A21'] => 'path=a:0,b:5',
            ['A23'] => 'city=revenue:40;path=a:0,b:_0;path=a:5,b:_0',
            ['C5'] => 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['C19'] => 'town=revenue:10;path=a:1,b:_0;path=a:3,b:_0',
            ['D4'] => 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['D18'] => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0',
            ['D24'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['D28'] => 'path=a:0,b:1;path=a:0,b:2',
            ['E13'] => 'path=a:2,b:3',
            ['F10'] => 'city=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            %w[F28 I23] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['H16'] => 'city=revenue:yellow_20|brown_30,loc:2.5;' \
                       'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:1,b:4',
            ['K11'] => 'city=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                       'icon=image:1828/coal;icon=image:1828/coal',
            ['K19'] => 'city=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['L18'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
          },
          red: {
            ['A3'] => 'offboard=revenue:60;path=a:4,b:_0',
            ['A13'] => 'offboard=revenue:yellow_30|brown_50,groups:Canada;path=a:4,b:5;border=edge:4',
            ['A15'] => 'city=revenue:yellow_30|brown_50,groups:Canada;' \
                       'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1;border=edge:1',
            ['B28'] => 'offboard=revenue:yellow_20|brown_30;path=a:0,b:_0;path=a:1,b:_0',
            ['G3'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I1'] => 'offboard=revenue:yellow_20|brown_60;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[K3 L16] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
