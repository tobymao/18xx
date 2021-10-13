# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 8,
          '8' => 16,
          '9' => 12,
          '55' => 1,
          '56' => 1,
          '57' => 2,
          '58' => 4,
          '69' => 2,
          '201' => 2,
          '202' => 2,
          '12' => 2,
          '13' => 2,
          '14' => 2,
          '15' => 2,
          '16' => 2,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '23' => 3,
          '24' => 3,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '87' => 2,
          '88' => 2,
          '203' => 2,
          '204' => 2,
          '205' => 1,
          '206' => 1,
          '207' => 2,
          '208' => 2,
          '209' => 1,
          '210' => 1,
          '211' => 1,
          '212' => 1,
          '213' => 1,
          '214' => 1,
          '215' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 3,
          '70' => 1,
          '216' => 4,
          '217' => 2,
          '218' => 2,
          '219' => 2,
          '220' => 1,
          '221' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A11' => 'Kiel',
          'C11' => 'Hamburg',
          'C13' => 'Schwerin',
          'D6' => 'Oldenburg',
          'D8' => 'Bremen',
          'F10' => 'Hannover',
          'F12' => 'Braunschweig',
          'F14' => 'Magdeburg',
          'G3' => 'Duisburg Essen',
          'G5' => 'Dortmund',
          'H2' => 'Düsseldorf',
          'H16' => 'Leipzig',
          'H20' => 'Dresden',
          'J6' => 'Mainz Wiesbaden',
          'J8' => 'Frankfurt',
          'L6' => 'Ludwigshafen Mannheim',
          'L14' => 'Fürth Nürnberg',
          'M9' => 'Stuttgart',
          'N12' => 'Augsburg',
          'O5' => 'Freiburg',
          'O15' => 'München',
          'I3' => 'Köln',
          'M13' => 'Ostbayern',
          'M15' => 'Ostbayern',
        }.freeze

        HEXES = {
          white: {
            %w[B18
               C15
               C17
               C19
               D10
               D12
               D16
               D18
               D20
               E5
               E7
               E9
               E11
               E13
               E17
               F8
               F16
               F18
               F20
               G7
               G9
               G17
               G19
               H14
               H18
               I5
               I11
               J2
               J10
               J12
               K5
               K13
               L4
               L10
               L12
               L16
               M11
               N14
               N16
               N18
               O9
               O11
               O13
               O17] => '',
            ['A11'] => 'city=revenue:0,loc:5.5',
            ['D8'] => 'city=revenue:0,loc:center;upgrade=cost:50',
            ['F10'] => 'city=revenue:0,loc:1.5',
            ['F14'] => 'city=revenue:0,loc:center',
            ['G5'] => 'city=revenue:0,loc:0',
            ['H2'] => 'city=revenue:0,loc:3.5;label=Y',
            ['H16'] => 'city=revenue:0,loc:2.5',
            ['H20'] => 'city=revenue:0,loc:0.5;upgrade=cost:50;label=Y',
            ['I3'] => 'city=revenue:0;label=Y;upgrade=cost:50',
            ['M9'] => 'city=revenue:0,loc:0.5',
            ['N12'] => 'city=revenue:0,loc:5',
            ['O5'] => 'city=revenue:0',
            ['O15'] => 'city=revenue:0,loc:1;label=Y',
            ['B12'] => 'town=revenue:0,loc:5.5',
            ['B14'] => 'town=revenue:0',
            ['B16'] => 'town=revenue:0,loc:3',
            ['F4'] => 'town=revenue:0,loc:4',
            ['F6'] => 'town=revenue:0,loc:2',
            ['G11'] => 'town=revenue:0,loc:0.5',
            ['G15'] => 'town=revenue:0,loc:5',
            ['H4'] => 'town=revenue:0,loc:1;town=revenue:0,loc:2.5',
            ['H10'] => 'town=revenue:0,loc:2.5',
            ['I13'] => 'upgrade=cost:70,terrain:mountain;town=revenue:0,loc:2.5',
            ['I15'] => 'town=revenue:0,loc:3.5',
            ['I17'] => 'town=revenue:0,loc:0.5;town=revenue:0,loc:3.5',
            ['K3'] => 'town=revenue:0,loc:1.5',
            ['K11'] => 'town=revenue:0,loc:1',
            ['L2'] => 'town=revenue:0,loc:4.5',
            ['L8'] => 'town=revenue:0,loc:1;town=revenue:0,loc:5',
            ['M7'] => 'town=revenue:0,loc:0;town=revenue:0,loc:1.5',
            ['N10'] => 'town=revenue:0,loc:5;town=revenue:0,loc:center',
            ['M15'] => 'upgrade=cost:50,terrain:water;town=revenue:0,loc:3',
            %w[D14 E15 K7 K9 M13 M17] => 'upgrade=cost:50,terrain:water',
            %w[G13 H6 H8 H12 I7 I9 J14 K15 N8 O7] =>
                   'upgrade=cost:70,terrain:mountain',
            ['C9'] => 'border=edge:3,type:water',
            ['B10'] => 'border=edge:0,type:water',
          },
          red: {
            ['C21'] => 'offboard=revenue:yellow_20|green_20|brown_40;path=a:1,b:_0',
            ['H22'] =>
            'offboard=revenue:yellow_20|green_30|brown_40,groups:OS;path=a:1,b:_0;border=edge:0',
            ['I21'] =>
            'offboard=revenue:yellow_20|green_30|brown_40,hide:1,groups:OS;border=edge:3',
            ['M5'] =>
            'offboard=revenue:yellow_0|green_50|brown_0,groups:Alsace;path=a:3,b:_0;border=edge:0',
            ['N4'] =>
            'offboard=revenue:yellow_0|green_50|brown_0,hide:1,groups:Alsace;path=a:4,b:_0;border=edge:3',
          },
          yellow: {
            ['E19'] =>
                     'city=revenue:30,loc:1;city=revenue:30,loc:3;path=a:1,b:_0;path=a:2,b:_1',
            ['G3'] =>
            'city=revenue:0,loc:0;city=revenue:0,loc:4.5;label=XX;upgrade=cost:50',
            ['J6'] => 'city=revenue:0;city=revenue:0;label=XX;upgrade=cost:50',
            ['L6'] => 'city=revenue:0,loc:5.5;city=revenue:0,loc:4;label=XX',
          },
          green: {
            ['C11'] =>
            'city=revenue:40;path=a:0,b:_0;city=revenue:40;path=a:2,b:_1;'\
            'city=revenue=40;path=a:4,b:_2;path=a:3,b:_2;label=HH',
            ['J8'] =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;upgrade=cost:50;label=Y',
            ['L14'] =>
            'city=revenue:30,loc:2.5;path=a:3,b:_0;path=a:2,b:_0;'\
            'city=revenue:30,loc:5.5;path=a:5,b:_1;path=a:0,b:_1;label=XX',
          },
          brown: {
            %w[A9 G1] => 'path=a:4,b:5',
            ['A17'] => 'town=revenue:10,loc:5;path=a:5,b:_0',
            ['B8'] => 'path=a:5,b:0',
            ['C5'] =>
            'town=revenue:10;path=a:4,b:_0;town=revenue:10;path=a:5,b:_1;path=a:0,b:_1',
            ['C7'] => 'town=revenue:10;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:1',
            ['C13'] =>
            'city=revenue:10,loc:3;path=a:3,b:_0;path=a:1,b:_0;path=a:1,b:5;path=a:5,b:_0',
            ['D4'] => 'path=a:3,b:5',
            ['D6'] =>
            'city=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['E21'] => 'town=revenue:10;path=a:1,b:_0;path=a:0,b:_0;path=a:2,b:_0',
            ['F12'] => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:4,b:_0',
            ['G21'] => 'path=a:2,b:0',
            ['I1'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I19'] => 'path=a:1,b:2;path=a:2,b:3;path=a:1,b:3',
            ['J4'] => 'town=revenue:10;path=a:2,b:_0;path=a:5,b:_0;path=a:3,b:4',
            ['J16'] => 'path=a:0,b:1;path=a:0,b:3;path=a:1,b:3',
            ['M19'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            ['N6'] => 'path=a:0,b:1;path=a:1,b:3;path=a:0,b:3',
            %w[P6 P14] => 'path=a:2,b:3',
            ['P10'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
