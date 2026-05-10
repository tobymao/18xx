# frozen_string_literal: true

module Engine
  module Game
    module G1870
      module Map
        TILES = {
          # yellow
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 6,
          '5' => 2,
          '6' => 2,
          '7' => 9,
          '8' => 22,
          '9' => 23,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 4,
          '69' => 1,

          # green
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 4,
          '24' => 4,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,

          # brown
          '39' => 1,
          '40' => 2,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 5,
          '70' => 2,
          '145' => 2,
          '146' => 2,
          '147' => 2,
          '170' => 4,

          # gray
          '171K' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K',
          },
          '172L' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Denver',
          'A22' => 'Chicago',
          'B9' => 'Topeka',
          'B11' => 'Kansas City',
          'B19' => 'Springfield, IL',
          'C18' => 'St. Louis',
          'D5' => 'Wichita',
          'E12' => 'Springfield, MO',
          'F5' => 'Oklahoma City',
          'H13' => 'Little Rock',
          'H17' => 'Memphis',
          'J3' => 'Fort Worth',
          'J5' => 'Dallas',
          'K16' => 'Jackson',
          'L11' => 'Alexandria',
          'M2' => 'Austin',
          'M6' => 'Houston',
          'M14' => 'Baton Rouge',
          'M20' => 'Mobile',
          'M22' => 'Southeast',
          'N1' => 'Southwest',
          'N7' => 'Galveston',
          'N17' => 'New Orleans',
        }.freeze

        HEXES = {
          white: {
            %w[A4 A6 A8 A12 A14 A18 A20 B3 B5 B15 B21 C2 C4 C6 C8 C10 C12 C20 D1 D3
               D7 D11 D19 E2 E4 E6 E10 F1 F3 F7 F17 F21 G4 G6 G8 G12 G14 G16 H1
               H9 H11 H15 H19 I2 I4 I6 I12 I18 I20 J1 J7 J13 J17 J19 J21 K2 K6 K8 K12 K18 L1
               L3 L5 L7 L9 L15 L17 L19 L21 M4 M12 M16 M18 N3 N5] => '',
            %w[B9 B19 D5 F5 H13 K16 M2 M6] => 'city=revenue:0',
            %w[J3 J5] => 'city=revenue:0;future_label=label:P,color:brown',
            %w[B7 D9 D21 E8 F9 G10 G20 H21 I14 J9 K4 K20 M8 M10] => 'town=revenue:0',
            ['M20'] => 'city=revenue:0;icon=image:port,sticky:1',
            %w[C14 C16 G2 H5] => 'upgrade=cost:40,terrain:water',
            %w[H7 I8 J11 K10] => 'upgrade=cost:60,terrain:water',
            ['B11'] => 'city=revenue:0;upgrade=cost:40,terrain:water;future_label=label:P,color:brown',
            ['L11'] => 'city=revenue:0;upgrade=cost:60,terrain:water',
            %w[A10 B13 H3] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[I10 E20] =>
                   'town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:water',
            ['B17'] => 'upgrade=cost:40,terrain:river;partition=a:0-,b:2+,type:water',
            ['E18'] => 'upgrade=cost:60,terrain:river;partition=a:3-,b:5+,type:water',
            ['F19'] => 'upgrade=cost:60,terrain:river;partition=a:1-,b:3-,type:water',
            %w[G18 I16] =>
                   'upgrade=cost:60,terrain:river;partition=a:1-,b:3+,type:water',
            ['J15'] => 'upgrade=cost:60,terrain:river;partition=a:0+,b:3+,type:water',
            ['L13'] => 'upgrade=cost:80,terrain:river;partition=a:0-,b:4-,type:water',
            ['N15'] => 'upgrade=cost:80,terrain:river;partition=a:2+,b:5+,type:water',
            ['O16'] => 'upgrade=cost:100,terrain:river;partition=a:3-,b:4+,type:water',
            ['O18'] =>
                   'upgrade=cost:100,terrain:river;partition=a:0-,b:2-,type:water;border=edge:3,type:impassable',
            ['C18'] =>
                   'city=revenue:0;upgrade=cost:40,terrain:river;partition=a:0+,b:2+,type:water,restrict:inner;'\
                   'future_label=label:P,color:brown',
            ['M14'] =>
                   'city=revenue:0;upgrade=cost:80,terrain:river;icon=image:port,sticky:1;'\
                   'partition=a:0-,b:2+,type:water,restrict:outer',
            ['H17'] =>
                   'city=revenue:0;upgrade=cost:60,terrain:river;icon=image:port,sticky:1;'\
                   'partition=a:1-,b:3+,type:water,restrict:outer',
            ['D17'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:river;partition=a:4-,b:5+,type:water,restrict:outer',
            ['K14'] =>
                   'town=revenue:0;upgrade=cost:80,terrain:river;partition=a:0+,b:4-,type:water,restrict:outer',
            ['A16'] =>
                   'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:river;partition=a:0-,b:3,type:water,restrict:inner',
            ['O2'] => 'upgrade=cost:60,terrain:lake',
            %w[O4 O6 N9 N11 N13] => 'upgrade=cost:80,terrain:lake',
            ['N19'] =>
                   'upgrade=cost:80,terrain:lake;border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['O14'] => 'upgrade=cost:100,terrain:lake',
            ['N7'] => 'city=revenue:0;upgrade=cost:80,terrain:lake;icon=image:port,sticky:1',
            ['N17'] =>
                   'city=revenue:0;upgrade=cost:80,terrain:lake;icon=image:port,sticky:1;border=edge:4,type:impassable;'\
                   'future_label=label:P,color:brown',
            ['N21'] => 'town=revenue:0;upgrade=cost:80,terrain:lake',
            %w[D13 D15 E14 E16 F11 F13 F15] =>
                   'upgrade=cost:60,terrain:mountain',
            ['E12'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
          },
          red: {
            ['A2'] =>
            'city=revenue:yellow_30|brown_40|blue_50,slots:0;'\
            'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A22'] =>
            'city=revenue:yellow_40|brown_50|blue_60,slots:0;path=a:0,terminal:1,b:_0;path=a:1,b:_0,terminal:1',
            ['N1'] =>
            'city=revenue:yellow_20|brown_40|blue_50;path=a:3,b:_0,terminal:1;'\
            'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['M22'] =>
            'city=revenue:yellow_20|brown_30|blue_50,slots:0;path=a:0,b:_0,terminal:1;'\
            'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
