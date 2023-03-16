# frozen_string_literal: true

module Engine
  module Game
    module G18TN
      module Map
        TILES = {
          '3' => 2,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 4,
          '8' => 13,
          '9' => 12,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 2,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '28' => 2,
          '29' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '57' => 4,
          '58' => 4,
          '63' => 4,
          '70' => 1,
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,
          '145' => 2,
          '146' => 2,
          '147' => 2,
          '170' => 2,
          '619' => 2,
          'TN1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C;future_label=label:P,color:brown',
          },
          'TN2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;path=a:0,b:_0;label=N;future_label=label:P,color:brown',
          },
          'TN3' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=P',
          },
        }.freeze

        LOCATION_NAMES = {
          'A16' => 'Cincinnati',
          'C4' => 'St. Louis',
          'E22' => 'Bristol Coalfields',
          'H1' => 'Little Rock',
          'J5' => 'Gulf Coast',
          'J17' => 'Atlanta',
          'B13' => 'Louisville',
          'B17' => 'Lexington',
          'C16' => 'Danville',
          'D7' => 'Paducah',
          'D11' => 'Bowling Green',
          'E10' => 'Clarksville',
          'F5' => 'Dyersburg',
          'F11' => 'Nashville',
          'F13' => 'Lebanon',
          'F17' => 'Knoxville',
          'G6' => 'Jackson',
          'G12' => 'Murfreesboro',
          'H3' => 'Memphis',
          'H7' => 'Corinth',
          'H15' => 'Chattanooga',
          'I10' => 'Huntsville',
          'J11' => 'Birmingham',
        }.freeze

        HEXES = {
          red: {
            ['A16'] => 'offboard=revenue:yellow_50|brown_80;path=a:5,b:_0;path=a:0,b:_0',
            ['C4'] => 'offboard=revenue:yellow_40|brown_60;path=a:4,b:_0;path=a:5,b:_0',
            ['E22'] => 'offboard=revenue:yellow_60|brown_40;path=a:1,b:_0;path=a:0,b:_0',
            ['H1'] =>
                   'offboard=revenue:yellow_20|brown_40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J5'] => 'offboard=revenue:yellow_30|brown_50;path=a:2,b:_0;path=a:3,b:_0',
            ['J17'] => 'offboard=revenue:yellow_40|brown_60;path=a:1,b:_0;path=a:2,b:_0',
          },
          gray: {
            ['B13'] => 'city=revenue:30,loc:2;path=a:0,b:_0;path=a:4,b:_0;path=a:0,b:4',
            ['J11'] =>
            'town=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          white: {
            %w[B17 G12] => 'city=revenue:0',
            %w[C16 E10 F5 F13] => 'town=revenue:0',
            %w[D7 F17 H7] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['F11'] => 'city=revenue:0;upgrade=cost:40,terrain:water;future_label=label:N,color:green',
            %w[B15
               C14
               C18
               D15
               D19
               F15
               G14
               H11
               H13
               I14
               I16
               J13] => 'upgrade=cost:60,terrain:mountain',
            ['E16'] => 'upgrade=cost:60,terrain:mountain;icon=image:18_tn/owr',
            %w[F21 G18 G20] => 'upgrade=cost:120,terrain:mountain',
            ['F19'] => 'upgrade=cost:120,terrain:mountain;icon=image:18_tn/etwcr',
            ['H17'] => 'upgrade=cost:120,terrain:mountain;icon=image:18_tn/tcc',
            ['H3'] => 'city=revenue:0;upgrade=cost:60,terrain:water;icon=image:18_tn/mcr;future_label=label:P,color:brown',
            ['I10'] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[C8 E8 F9 G8 H9 I12 G16] =>
            'upgrade=cost:40,terrain:water',
            %w[D5 E4 F3 G2] => 'upgrade=cost:60,terrain:water',
            %w[C6
               D9
               D13
               D17
               E6
               E12
               E14
               E18
               E20
               F7
               G4
               G10
               H5
               I2
               I4
               I6
               I8
               J15] => '',
          },
          yellow: {
            ['C12'] => 'path=a:0,b:3',
            ['D11'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3',
            ['G6'] => 'city=revenue:20;path=a:3,b:_0;path=a:5,b:_0',
            ['H15'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;label=C',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
