# frozen_string_literal: true

module Engine
  module Game
    module G18Texas
      module Map
        # rubocop:disable Layout/LineLength
        TILES = {
          '5' => 4,
          '6' => 4,
          '7' => 5,
          '8' => 18,
          '9' => 18,
          '57' => 4,
          '202' => 3,
          '14' => 3,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
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
          '619' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '70' => 1,
          '216' => 3,
          '611' => 5,
          '627' => 1,
          '628' => 1,
          '629' => 1,
          '511' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;label=Y;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '512' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=Y;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LOCATION_NAMES = {
          'A12' => 'Oklahoma City',
          'A18' => 'Little Rock',
          'B11' => 'Denison',
          'C16' => 'Texarkana',
          'D1' => 'El Paso',
          'D9' => 'Fort Worth & Dallas',
          'D15' => 'Marshall',
          'D19' => 'Shreveport',
          'E4' => 'Cisco',
          'F9' => 'Waco',
          'F13' => 'Palestine',
          'F15' => 'Lufkin',
          'G10' => 'College Station',
          'H7' => 'Austin',
          'H19' => 'Lafayette',
          'I14' => 'Houston',
          'J1' => 'Piedras Negras',
          'J5' => 'San Antonio',
          'J15' => 'Galveston',
          'K10' => 'Victoria',
          'M2' => 'Laredo',
          'M8' => 'Corpus Christi',
          'N1' => 'Monterrey',
        }.freeze

        HEXES = {
          white: {
            %w[
            B9
            B13
            B15
            B17
            B19
            C8
            C10
            C12
            C14
            C18
            D7
            D11
            D13
            D17
            E6
            E8
            E10
            E12
            E14
            E16
            E18
            F7
            F11
            F17
            G6
            G8
            G12
            G14
            G16
            G18
            H9
            H11
            H13
            H15
            H17
            I6
            I8
            I10
            I12
            I16
            I18
            J7
            J9
            J11
            J13
            K2
            K4
            K6
            K8
            L1
            L3
            L5
            L7
            M4
            M6
            N3
            N5
            ] => '',
            %w[
            K12
            L9
            ] =>
            'upgrade=cost:40,terrain:water',
            %w[
            D5
            F5
            G4
            H5
            I4
            ] =>
            'upgrade=cost:40,terrain:desert',
            %w[
            D3
            E2
            F3
            G2
            H3
            I2
            J3
            ] =>
            'upgrade=cost:60,terrain:desert',

            ['E4'] => 'city=revenue:0;upgrade=cost:40,terrain:desert',
            %w[B11
               F13
               C16
               D15
               F9
               F15
               G10
               K10
               M2] => 'city=revenue:0',

            %w[
               H7
               J5
              ] => 'city=revenue:0;label=Y',
          },
          red: {
            ['A12'] => 'offboard=revenue:yellow_20|brown_40;path=a:0,b:_0;path=a:5,b:_0',
            ['A18'] => 'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:5,b:_0',
            ['D1'] => 'offboard=revenue:yellow_50|brown_80;path=a:5,b:_0',
            %w[D19 H19] => 'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['N1'] => 'offboard=revenue:yellow_60|brown_80;path=a:3,b:_0;path=a:4,b:_0',
          },
          gray: {
            ['J1'] => 'town=revenue:yellow_10|brown_40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J15'] => 'town=revenue:yellow_20|brown_50;path=a:1,b:_0;path=a:2,b:_0',
            ['M8'] => 'town=revenue:yellow_20|brown_40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['D9'] => 'city=revenue:30;city=revenue:30;label=Y;path=a:1,b:_0;path=a:_0,b:_1;path=a:_1,b:3',
            ['I14'] => 'city=revenue:30;label=Y;path=a:1,b:_0;path=a:5,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
