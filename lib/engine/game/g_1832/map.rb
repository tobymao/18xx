# frozen_string_literal: true

module Engine
  module Game
    module G1832
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          'A7' => 'Louisville',
          'A21' => 'Richmond',
          'B2' => 'Kansas City',
          'B14' => 'West Virgina Coal Fields',
          'B16' => 'Lynchburg',
          'B24' => 'Norfolk',
          'C3' => 'Jackson',
          'C7' => 'Nashville',
          'C11' => 'Knoxville',
          'C17' => 'Winston Salem & Greensboro',
          'D4' => 'Corinth',
          'D8' => 'Chattanooga',
          'D16' => 'Charlotte',
          'D20' => 'Raleigh',
          'E17' => 'Columbia',
          'E21' => 'Wilmington',
          'F6' => 'Birmingham',
          'F10' => 'Atlanta',
          'F14' => 'Augusta',
          'G3' => 'Meridian',
          'G9' => 'Columbus',
          'G11' => 'Macon',
          'G17' => 'Charleston',
          'H6' => 'Montgomery',
          'H8' => 'Eufaula',
          'H16' => 'Savannah',
          'I3' => 'Mobile',
          'J2' => 'New Orleans',
          'J4' => 'Pensacola',
          'J10' => 'Tallahassee',
          'J12' => 'Valdosta',
          'J14' => 'Jacksonville',
          'L14' => 'Orlando',
          'M13' => 'Tampa',
          'M15' => 'Lakeland & Winter Haven',
          'N16' => 'Miami',
        }.freeze

        TILES = {
          # yellow
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 4,
          '5' => 2,
          '7' => 7,
          '8' => 20,
          '9' => 20,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 4,
          '69' => 1,
          # green
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '141' => 1,
          '142' => 1,
          '143' => 1,
          '144' => 1,
          '190' => 1,

          # brown
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 4,
          '70' => 1,
          '145' => 1,
          '146' => 1,
          '147' => 1,
          '191' => 1,
          '193' => 1,
          '611' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=JC',
          },
        }.freeze

        HEXES = {
          white: {
            %w[B6 B8 B20 B22 C5 C19 C21 C23 D2 D14 D18 D22 E3 E5 E15 E19 F2 F4 F12 F16 F18 G5 G7 G13 H2 H4 H10 H12 H14 I5 I7 I9
               I11 I13 J8 K13] => '',
            %w[C7 D20 D16 F6] => 'city=revenue:0',
            %w[B18 E17 G3 H8 J12] => 'town=revenue:0;',
            %w[M15 C17] => 'town=revenue:0;town=revenue:0',
            %w[H6 G9 G11 L14] => 'town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade;',
            %w[D6 E7 E9 F8] => 'upgrade=cost:40,terrain:mountain;',
            %w[B10 B12 C9 D10 E11] => 'upgrade=cost:60,terrain:mountain;',
            %w[B16 C15] => 'upgrade=cost:70,terrain:mountain;',
            %w[D12 C13] => 'upgrade=cost:80,terrain:mountain;',
            %w[B4 E13 K15 L16] => 'upgrade=cost:40,terrain:water;',
            %w[G15 I15 N14] => 'upgrade=cost:60,terrain:water;',
            %w[E23 F20 G19 J6 K9 K11 L12 N12] => 'upgrade=cost:80,terrain:water;',
            %w[D4 C3] => 'upgrade=cost:40,terrain:water;town=revenue:0',
            ['C11'] => 'upgrade=cost:60,terrain:water;town=revenue:0',
            %w[D8 F14] => 'upgrade=cost:40,terrain:water;icon=image:18_co/upgrade,sticky:1,name:upgrade;town=revenue:0;',
            ['E21'] => 'icon=image:port,sticky:1;town=revenue:0',
            ['G17'] => 'label=JC;icon=image:port,sticky:1;city=revenue:0;upgrade=cost:60,terrain:water;',
            ['H16'] => 'label=S;icon=image:port,sticky:1;city=revenue:0;upgrade=cost:60,terrain:water;',
            %w[I3 J10] => 'icon=image:port,sticky:1;city=revenue:0;',
            ['J14'] => 'label=JC;icon=image:port,sticky:1;city=revenue:0;',
            ['J4'] => 'icon=image:port,sticky:1;town=revenue:0;upgrade=cost:80,terrain:water;',
            ['M13'] => 'icon=image:port,sticky:1;city=revenue:0;upgrade=cost:40,terrain:water;',
          },
          red: {
            %w[A7 A21] => 'offboard=revenue:yellow_30|brown_50;path=a:5,b:_0;path=a:0,b:_0;',
            ['B2'] => 'offboard=revenue:yellow_30|brown_50|gray_60;path=a:5,b:_0;path=a:4,b:_0;',
            ['N16'] => 'icon=image:port,sticky:1;'\
                       'offboard=revenue:yellow_20|brown_30|gray_50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;',
          },
          yellow: {
            ['F10'] => 'label=a;city=revenue:20;city=revenue:20;city=revenue:20;path=a:4,b:_0;path=a:0,b:_1;path=a:2,b:_2;',
          },
          gray: {
            ['B14'] => 'city=revenue:yellow_40|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;' \
                       'icon=image:1828/coal;icon=image:1828/coal',
            ['I1'] => 'path=a:4,b:5;',
            ['B24'] => 'icon=image:port,sticky:1;city=revenue:yellow_20|brown_40|gray_50;'\
                       'path=a:1,b:_0;path=a:0,b:_0;',
            ['J2'] => 'icon=image:port,sticky:1;city=revenue:yellow_20|brown_30|gray_50;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
            ['M17'] => 'path=a:2,b:0;',
          },
        }.freeze
      end
    end
  end
end
