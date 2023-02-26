# frozen_string_literal: true

module Engine
  module Game
    module G18AL
      module Map
        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 5,
          '8' => 11,
          '9' => 10,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 4,
          '58' => 3,
          '63' => 7,
          '70' => 1,
          '142' => 2,
          '143' => 2,
          '144' => 2,
          '445' => 1,
          '446' => 1,
          '441a' => 1,
          '442a' => 1,
          '443a' => 1,
          '444b' => 1,
          '444m' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Nashville',
          'B1' => 'Corinth',
          'B7' => 'Chattanooga',
          'C2' => 'Florence',
          'C4' => 'Decatur',
          'C6' => 'Stevenson',
          'D7' => 'Rome',
          'E6' => 'Gadsden',
          'F1' => 'Tupelo',
          'G4' => 'Birmingham',
          'G6' => 'Anniston',
          'G8' => 'Atlanta',
          'H3' => 'Tuscaloosa',
          'H5' => 'Oxmoor',
          'J7' => 'West Point',
          'K2' => 'York',
          'K4' => 'Selma',
          'L1' => 'Meridian',
          'L5' => 'Montgomery',
          'M8' => 'Phenix City',
          'O6' => 'Dothan',
          'P7' => 'Gulf of Mexico',
          'Q2' => 'Mobile',
        }.freeze

        HEXES = {
          white: {
            %w[A2
               B5
               D1
               E2
               E4
               F3
               F5
               H1
               H7
               I2
               I4
               I6
               I8
               J1
               J3
               J5
               K6
               K8
               L7
               M4
               M6
               N1
               N7
               P1
               P3] => '',
            ['B3'] => 'border=edge:0,type:impassable',
            ['D3'] => 'upgrade=cost:20,terrain:water;border=edge:3,type:impassable',
            %w[C2 C6] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            ['C4'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[L3 N3 O2] => 'upgrade=cost:20,terrain:water',
            %w[G2 M2 N5 O4 P5] => 'upgrade=cost:20,terrain:swamp',
            ['D5'] => 'upgrade=cost:60,terrain:mountain|water',
            ['F7'] => 'upgrade=cost:60,terrain:mountain',
            ['G4'] =>
                   'city=revenue:0;upgrade=cost:60,terrain:mountain;label=B;icon=image:18_al/coal,sticky:1',
            %w[J7 K2] => 'city=revenue:0',
            ['L5'] => 'city=revenue:0;future_label=label:M,color:green',
            %w[G6 H3] => 'city=revenue:0;icon=image:18_al/coal,sticky:1',
            ['O6'] => 'town=revenue:0',
          },
          red: {
            ['A4'] =>
                     'city=revenue:yellow_40|brown_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['B1'] => 'offboard=revenue:yellow_40|brown_30;path=a:5,b:_0',
            ['B7'] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0',
            ['G8'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:1,b:_0',
            ['P7'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            ['Q2'] => 'city=revenue:yellow_40|brown_50;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;'\
                      'path=a:4,b:_0,terminal:1',
          },
          gray: {
            ['D7'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
            ['F1'] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['H5'] =>
            'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;icon=image:18_al/coal,sticky:1',
            ['L1'] =>
            'city=revenue:yellow_30|brown_40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['M8'] => 'town=revenue:10;path=a:1,b:_0;path=a:_0,b:2',
          },
          yellow: {
            ['E6'] =>
                     'city=revenue:20;path=a:3,b:_0;path=a:4,b:_0;icon=image:18_al/coal,sticky:1',
            ['K4'] => 'city=revenue:20;path=a:1,b:_0;path=a:_0,b:5',
          },
        }.freeze

        LAYOUT = :flat

        AXES = { x: :number, y: :letter }.freeze
      end
    end
  end
end
