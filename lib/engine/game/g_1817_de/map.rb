# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module Engine
  module Game
    module G1817DE
      module Map
        TILES = {
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '57' => 'unlimited',
          '59' => 3,
          '63' => 'unlimited',
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '592' => 'unlimited',
          '593' => 'unlimited',
          '597' => 'unlimited',
          '611' => 'unlimited',
          '619' => 'unlimited',
          'OO167' => {
            'count' => 3,
            'color' => 'gray',
            'code' => 'city=revenue:70,loc:0;city=revenue:70,loc:3;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;path=a:4,b:_0;path=a:5,b:_1;label=OO',
          },
        }.freeze

        LOCATION_NAMES = {
          'E1' => 'Copenhagen',
          'A15' => 'Brussels',
          'B20' => 'Paris',
          'C25' => 'Bern',
          'J22' => 'Vienna',
          'J16' => 'Prague',
          'B8' => 'Amsterdam',
          'E7' => 'Bremen',
          'F6' => 'Hamburg',
          'D10' => 'Osnabrück',
          'I9' => 'Berlin',
          'F10' => 'Hannover',
          'G11' => 'Harz Mountains',
          'G15' => 'Weimar',
          'B14' => 'Köln and Düsseldorf',
          'C13' => 'Essen and Dortmund',
          'I13' => 'Leipzig',
          'J14' => 'Dresden',
          'D16' => 'Frankfurt',
          'G19' => 'Nürnberg',
          'E21' => 'Stuttgart',
          'H22' => 'München',
          'K7' => 'Warsaw',
        }.freeze

        HEXES = {
          white: {
            %w[D14
               D22
               D24
               E13
               E15
               G11
               G13
               G17] => 'upgrade=cost:15,terrain:mountain',
            %w[B12
               B16
               B18
               C11
               C17
               C19
               C7
               C9
               C23
               D12
               D6
               D8
               E11
               E19
               E23
               E3
               F4
               E5
               E9
               F12
               F14
               F16
               F18
               F20
               F22
               F24
               F8
               G23
               G7
               G9
               H12
               H14
               H16
               H18
               H24
               H4
               I15
               I3
               I5
               I7
               I19
               I23
               J10
               J4
               J6
               J8
               K11
               K13
               K9] => '',
            %w[D10
               E21
               F10
               G15
               I13] => 'city=revenue:0',
            %w[G19] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[D16
               J14] => 'city=revenue:0;upgrade=cost:10,terrain:water',
            %w[C15 D18
               D20
               E17
               G21
               G5
               H20
               H6
               H8
               H10
               I21
               I11
               J12
               J20] => 'upgrade=cost:10,terrain:water',
          },
          red: {
            ['B20'] =>
         'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:3,b:_0',
            ['C25'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:3,b:_0',
            ['J22'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:1,b:_0',
            ['K7'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:1,b:_0;path=a:2,b:_0',
            ['J16'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:3,b:_0',
            ['B8'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:5,b:_0',
            ['E1'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:0,b:_0',
            ['A15'] =>
         'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['I9'] =>
        'city=revenue:30;path=a:0,b:_0;path=a:_0,b:2;label=B',
            ['H22'] =>
        'city=revenue:30;path=a:2,b:_0;path=a:_0,b:4;label=B',
            ['B14'] =>
        'city=revenue:0;city=revenue:0;label=OO',
            ['C13'] =>
        'city=revenue:0;city=revenue:0;label=OO',
            ['F6'] =>
        'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_1;label=OO',
            ['E7'] =>
        'city=revenue:20;path=a:4,b:_0',
          },
          gray: {
            ['A13'] =>
        'path=a:0,b:5',
          },
        }.freeze
        LAYOUT = :flat
      end
    end
  end
end
# rubocop:enable Layout/LineLength
