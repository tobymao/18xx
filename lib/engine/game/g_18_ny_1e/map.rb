# frozen_string_literal: true

module Engine
  module Game
    module G18NY1E
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        TILES = {
          '3' => 5,
          '4' => 5,
          '5' => 5,
          '6' => 5,
          '7' => 5,
          '8' => 12,
          '9' => 12,
          '57' => 6,
          '58' => 5,
          'X10' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=A',
          },
          'X11' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:70,slots:2;path=a:2,b:_0;path=a:3,b:_0;label=N;upgrade=cost:80,terrain:water',
          },
          'X13' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=R',
          },
          '14' => 4,
          '15' => 8,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 1,
          '31' => 1,
          '619' => 4,
          'X20' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=A',
          },
          'X21' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Br',
          },
          'X22' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:100,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=N;' \
                      'upgrade=cost:80,terrain:water',
          },
          'X23' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=R',
          },
          'X24' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;' \
                      'label=S',
          },
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 3,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 6,
          '70' => 2,
          'X31' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Br',
          },
          'X32' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:120,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;label=N',
          },
          'X33' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=R',
          },
          'X34' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;' \
                      'label=S',
          },
          'X35' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=Bu',
          },
          '455' => 2,
        }.freeze

        LOCATION_NAMES = {
          'A11' => 'Ottawa',
          'A17' => 'Montreal',
          'A23' => 'Burlington',
          'B12' => 'Watertown',
          'C11' => 'Oswego',
          'C23' => 'Rutland',
          'C25' => 'Montpelier',
          'D0' => 'Toronto',
          'D2' => 'Niagara Falls',
          'D4' => 'Lockport',
          'D8' => 'Rochester',
          'D12' => 'Syracuse',
          'D14' => 'Rome',
          'D18' => 'Amsterdam',
          'D20' => 'Saratoga Springs',
          'E3' => 'Buffalo',
          'E5' => 'Batavia',
          'E9' => 'Geneva',
          'E11' => 'Auburn',
          'E15' => 'Utica',
          'E19' => 'Schenectady',
          'E21' => 'Troy',
          'F10' => 'Ithaca',
          'F12' => 'Cortland',
          'F20' => 'Albany',
          'F26' => 'Springfield',
          'G1' => 'Jamestown',
          'G9' => 'Elmira',
          'G13' => 'Binghamton',
          'G19' => 'Kingston',
          'G21' => 'Hudson',
          'G25' => 'Hartford',
          'H4' => 'Pittsburgh',
          'H8' => 'Williamsport',
          'H12' => 'Scranton',
          'H14' => 'Carbondale',
          'H20' => 'Poughkeepsie',
          'I19' => 'Newburgh',
          'I23' => 'Bridgeport',
          'I25' => 'New Haven',
          'J14' => 'Allentown',
          'J18' => 'Newark',
          'J20' => 'New York',
          'J22' => 'Hempstead',
          'J26' => 'Long Island',
          'K15' => 'Philadelphia',
          'K19' => 'Brooklyn',
        }.freeze

        CONNECTION_BONUS_HEXES =
          [%w[A13 A11], %w[A19 A15 A17 A21], %w[A23 A21], %w[C25 A25 B26], %w[G25 H26], %w[D0 E1], %w[J26], 'B12', 'C11',
           'C23', 'D18', 'D20', 'E9', 'F10', 'F12', 'G9', 'G13', 'G19', 'G21', 'I19', 'I23', 'J18', 'J22', 'K19'].freeze
        COAL_LOCATIONS = [%w[F0 G1], %w[H2 H4], %w[H6 H8 H10], ['H12'], %w[I13 J14], %w[K15 K17]].freeze

        HEXES = {
          red: {
            %w[A11] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_80,groups:Ottawa;path=a:5,b:_0;border=edge:4',
            %w[A13] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_80,groups:Ottawa,hide:1;' \
                       'path=a:0,b:_0;path=a:5,b:_0;border=edge:1',
            %w[A15] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80,groups:Montreal,hide:1;' \
                       'path=a:0,b:_0;path=a:5,b:_0;border=edge:1,type:divider;border=edge:4',
            %w[A17] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80,groups:Montreal;' \
                       'path=a:0,b:_0;path=a:5,b:_0;border=edge:1;border=edge:4',
            %w[A19] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80,groups:Montreal,hide:1;' \
                       'path=a:0,b:_0;path=a:5,b:_0;border=edge:1;border=edge:4',
            %w[A21] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80,hide:1;path=a:0,b:_0;' \
                       'offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1;path=a:5,b:_1;' \
                       'border=edge:1;border=edge:4;partition=a:0,b:3,type:divider',
            %w[A23] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,groups:Burlington;' \
                       'path=a:0,b:_0;path=a:5,b:_0;border=edge:1',
            %w[A25] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Montpelier,hide:1;' \
                       'path=a:0,b:_0;border=edge:1,type:divider;border=edge:5',
            %w[B26] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Montpelier,hide:1;' \
                       'path=a:1,b:_0;border=edge:0;border=edge:2',
            %w[C25] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:Montpelier;' \
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;border=edge:3',
            %w[D0] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_80,groups:Toronto;' \
                      'path=a:4,b:_0;border=edge:5',
            %w[E1] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_80,groups:Toronto,hide:1;path=a:3,b:_0;' \
                      'path=a:4,b:_0;border=edge:2;border=edge:4,type:water,cost:80',
            %w[D26] => 'border=edge:0;border=edge:2,type:divider',
            %w[E25] => 'path=a:1,b:5;path=a:2,b:5;border=edge:3;border=edge:5',
            %w[F26] => 'city=revenue:yellow_20|green_40|brown_80|gray_100,groups:Springfield,loc:2;' \
                       'path=a:1,b:_0;path=a:2,b:_0;border=edge:2',
            %w[F0] => 'offboard=revenue:yellow_10|green_20|brown_50|gray_100,groups:Jamestown,hide:1;' \
                      'path=a:4,b:_0;border=edge:3,type:divider;border=edge:5',
            %w[G1] => 'offboard=revenue:yellow_10|green_20|brown_50|gray_100,groups:Jamestown;' \
                      'path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            %w[H2] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_100,groups:Pittsburgh,hide:1;' \
                      'path=a:3,b:_0;border=edge:2,type:divider;border=edge:4',
            %w[H4] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_100,groups:Pittsburgh;' \
                      'path=a:2,b:_0;path=a:3,b:_0;border=edge:1',
            %w[H6] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_100,groups:Williamsport,hide:1;' \
                      'path=a:2,b:_0;path=a:3,b:_0;border=edge:1,type:divider;border=edge:4',
            %w[H8] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_100,groups:Williamsport;' \
                      'path=a:2,b:_0;path=a:3,b:_0;border=edge:1;border=edge:4',
            %w[H10] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_100,groups:Williamsport,hide:1;' \
                       'path=a:2,b:_0;path=a:3,b:_0;border=edge:1',
            %w[H12] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;' \
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1,type:divider',
            %w[G25] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_80,groups:Hartford;' \
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;border=edge:3,type:divider;border=edge:5',
            %w[H26] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_80,groups:Hartford,hide:1;' \
                       'path=a:1,b:_0;border=edge:2',
            %w[I25] => 'city=revenue:yellow_20|green_30|brown_40|gray_80;' \
                       'path=a:1,b:_0;path=a:2,b:_0;border=edge:3,type:divider',
            %w[J26] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_80;path=a:1,b:_0;border=edge:2,type:divider',
            %w[I13] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:Allentown,hide:1;' \
                       'path=a:3,b:_0;path=a:4,b:_0;border=edge:2,type:divider;border=edge:5',
            %w[J14] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50,groups:Allentown;' \
                       'path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            %w[K15] => 'offboard=revenue:yellow_40|green_60|brown_80|gray_120,groups:Philadelphia;' \
                       'path=a:3,b:_0;border=edge:2,type:divider;border=edge:4',
            %w[K17] => 'offboard=revenue:yellow_40|green_60|brown_80|gray_120,groups:Philadelphia,hide:1;' \
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1',
          },
          blue: {
            %w[B10 C1 C3 C5 C7 C9 K23 K25] => '',
          },
          white: {
            %w[B14 F4 F24 G7 G11 H24] => '',
            %w[K21] => '',
            %w[B16 B24 C15 C19 D24 E23 F2 F14 F16 F18 F22 G3 G5 G15 G23 H16 H22 I15 I17 J16] =>
              'upgrade=cost:60,terrain:mountain',
            %w[B18 G17] => 'upgrade=cost:120,terrain:mountain',
            %w[B20] => 'border=edge:4,type:water,cost:60;border=edge:5,type:impassable;' \
                       'upgrade=cost:60,terrain:mountain',
            %w[B22] => 'border=edge:1,type:water,cost:60',
            %w[C13] => 'border=edge:0,type:impassable',
            %w[J24] => 'border=edge:2,type:impassable',
            %w[C17] => 'border=edge:5,type:impassable;upgrade=cost:60,terrain:mountain',
            %w[C21] => 'border=edge:0,type:water,cost:40;border=edge:2,type:impassable',
            %w[D6] => 'border=edge:4,type:water,cost:60;border=edge:5,type:water,cost:60;' \
                      'icon=image:18_ny/canal',
            %w[D10 E13] => 'icon=image:18_ny/canal',
            %w[D16] => 'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:60',
            %w[D22] => 'border=edge:1,type:water,cost:60',
            %w[E7] => 'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:60;' \
                      'border=edge:2,type:water,cost:60',
            %w[E17] => 'border=edge:2,type:water,cost:60;border=edge:3,type:water,cost:60;icon=image:18_ny/canal',
            %w[F6] => 'border=edge:3,type:water,cost:40;upgrade=cost:60,terrain:mountain',
            %w[F8] => 'border=edge:4,type:impassable;upgrade=cost:60,terrain:mountain',
            %w[H18] => 'border=edge:4,type:water,cost:80',
            %w[I21] => 'border=edge:1,type:water,cost:80;border=edge:5,type:impassable',
            %w[B12] => 'town=revenue:0',
            %w[C11] => 'town=revenue:0',
            %w[C23] => 'town=revenue:0',
            %w[G9] => 'town=revenue:0',
            %w[G13] => 'town=revenue:0',
            %w[D18] => 'town=revenue:0;border=edge:0,type:water,cost:60;border=edge:2,type:impassable',
            %w[D20] => 'town=revenue:0;border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:60;' \
                       'border=edge:5,type:water,cost:60',
            %w[E9] => 'town=revenue:0;border=edge:4,type:impassable',
            %w[F10] => 'town=revenue:0;upgrade=cost:60,terrain:mountain;border=edge:1,type:impassable;' \
                       'border=edge:3,type:impassable',
            %w[F12] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[G19] => 'town=revenue:0;border=edge:4,type:water,cost:80;border=edge:5,type:water,cost:80',
            %w[G21] => 'town=revenue:0;border=edge:1,type:water,cost:80',
            %w[I19] => 'town=revenue:0;border=edge:3,type:water,cost:80;border=edge:4,type:water,cost:80',
            %w[I23] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            %w[J22] => 'town=revenue:0;border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[D2] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            %w[D4] => 'city=revenue:0;icon=image:18_ny/canal',
            %w[D14] => 'city=revenue:0;icon=image:18_ny/canal',
            %w[D8] => 'future_label=label:R,color:green;city=revenue:0;border=edge:1,type:water,cost:60;icon=image:18_ny/canal',
            %w[D12] => 'future_label=label:S,color:brown;city=revenue:0;border=edge:3,type:impassable;icon=image:18_ny/canal',
            %w[E5] => 'city=revenue:0;border=edge:4,type:water,cost:60',
            %w[E11] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:1,type:impassable',
            %w[E15] => 'city=revenue:0;border=edge:3,type:water,cost:40;icon=image:18_ny/canal',
            %w[E19] => 'city=revenue:0;border=edge:4,type:water,cost:80;upgrade=cost:60,terrain:water;' \
                       'icon=image:18_ny/canal',
            %w[E21] => 'city=revenue:0;border=edge:1,type:water,cost:80;border=edge:2,type:water,cost:60',
            %w[H14] => 'city=revenue:0',
            %w[J18] => 'city=revenue:0',
            %w[H20] => 'city=revenue:0;border=edge:0,type:water,cost:80;border=edge:1,type:water,cost:80;' \
                       'border=edge:2,type:water,cost:80',
            %w[K19] => 'future_label=label:Br,color:brown;city=revenue:0;upgrade=cost:80,terrain:water',
          },
          yellow: {
            %w[E3] => 'future_label=label:Bu,color:gray;city=revenue:20,slots:2;border=edge:1,type:water,cost:80;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[F20] => 'label=A;city=revenue:40;upgrade=cost:80,terrain:water;path=a:0,b:_0;path=a:2,b:_0',
            %w[J20] => 'label=N;city=revenue:50;upgrade=cost:80,terrain:water;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
