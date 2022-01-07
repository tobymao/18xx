# frozen_string_literal: true

module Engine
  module Game
    module G18AZ
      module Map
        LAYOUT = :flat

        TILES = {
          '5' => 3,
          '6' => 4,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 4,
          '15' => 5,
          '16' => 2,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '51' => 2,
          '57' => 4,
          '70' => 1,
          '290' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;label=Z;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '291' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;label=Z',
          },
          '292' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;label=Z',
          },
          '293' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;label=Z',
          },
          '294' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Z',
          },
          '295' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;label=Z',
          },
          '296' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Z',
          },
          '297' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;label=Z',
          },
          '298' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                      'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;'\
                      'path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=Chi',
          },
          '299' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;'\
                      'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;'\
                      'path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=Chi',
          },
          '300' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90;city=revenue:90;city=revenue:90;city=revenue:90;'\
                      'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;'\
                      'path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=Chi',
          },
          '611' => 4,
          '619' => 3,
        }.freeze

        LOCATION_NAMES = {
          'A6' => 'Palm Springs',
          'A12' => 'San Diego',
          'B1' => 'Las Vegas',
          'B13' => 'Yuma',
          'C6' => 'Kingman',
          'E8' => 'Prescott',
          'F3' => 'Grand Canyon',
          'F5' => 'Williams',
          'F11' => 'Phoenix',
          'G6' => 'Flagstaff',
          'H15' => 'Tucson',
          'H19' => 'Nogales',
          'I8' => 'Holbrook',
          'M6' => 'Albuquerque',
          'M18' => 'Las Cruces',
          'N5' => 'Santa Fe',
          'N19' => 'El Paso',
        }.freeze

        HEXES = {
          white: {
            %w[B3 B5 B7 B9 B11 C2 C4 C8 C10 C12 C14 D3 D5 D7 D9 D11 D13 D15 E4 E10 E12 E14 E16 F9 F13 F15 F17 G4 H5 H7 H9 H13 H17
               I4 I6 I10 I14 I16 J5 J7 J9 J15 J17 J19 K18 L7 L17] => '',

            %w[C6 E8 F5 F11 G6 H15 I8 M6] => 'city=revenue:0',
            %w[E6 F7 G8 G10 G14 G16 G18 H11 I12 I18 J11 J13 K8 K10 K12 K14 K16 L5 L9 L11 L13 L15 L19 M8 M10 M12 M14
               M16] => 'upgrade=cost:60,terrain:mountain',
          },
          gray: { ['F3'] => 'city=revenue:0;path=a:0,b:_0' },
          red: {
            ['B1'] => 'city=revenue:yellow_30|brown_60,slots:2;path=a:0,b:_0;path=a:5,b:_0',
            ['A6'] => 'offboard=revenue:yellow_30|brown_40;path=a:5,b:_0',
            ['A12'] => 'offboard=revenue:yellow_40|brown_50;path=a:5,b:_0',
            ['H19'] => 'offboard=revenue:yellow_30|brown_40;path=a:3,b:_0',
            ['N5'] => 'offboard=revenue:yellow_40|brown_50;path=a:1,b:_0',
            ['N19'] => 'offboard=revenue:yellow_40|brown_50;path=a:2,b:_0',

          },
          yellow: {
            %w[B13 G12 H3 K6 M18] => 'city=revenue:0',
          },
          blue: {},
        }.freeze
      end
    end
  end
end
