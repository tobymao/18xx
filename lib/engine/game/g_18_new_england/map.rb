# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18NewEngland
      module Map
        TILES = {
          '3' => 5,
          '4' => 5,
          '6' => 8,
          '7' => 5,
          '8' => 18,
          '9' => 15,
          '58' => 5,
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '87' => 4,
          '88' => 4,
          '204' => 4,
          '207' => 1,
          '619' => 4,
          '622' => 1,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 7,
          '70' => 2,
          '611' => 3,
          '216' => 2,
          '911' => 4,
          'X1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;path=a:1,b:_0;path=a:_0,b:3;'\
                      'path=a:4,b:_1;path=a:_1,b:5;label=B',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;label=H',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_1;path=a:3,b:_1;path=a:_2,b:4;path=a:_2,b:5;label=NH',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;label=B',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;label=H',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;label=NH',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:2;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;label=B',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;label=H',
          },
          'X9' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;label=NH',
          },
        }.freeze

        LOCATION_NAMES = {
          A12: 'Campbell Hall',
          A2: 'Syracuse',
          B3: 'Albany',
          B5: 'Hudson',
          B9: 'Rhinecliff',
          B11: 'Poughkeepsie',
          B17: 'White Plains',
          B19: 'New York',
          C4: 'New Lebanon',
          D13: 'Danbury',
          D15: 'Stamford',
          E2: 'Burlington',
          E4: 'Pittsfield',
          E12: 'Waterbury',
          E14: 'Bridgeport',
          F11: 'Middletown',
          F13: 'New Haven',
          G4: 'Greenfield',
          G6: 'Northampton',
          G8: 'Springfield',
          G10: 'Hartford',
          G14: 'Saybrook',
          H13: 'New London',
          I6: 'Worcester',
          I14: 'Westerly',
          J1: 'New Hampshire',
          J3: 'Fitchburg',
          J5: 'Leominster',
          K4: 'Lowell and Wilmington',
          K8: 'Woonsocket',
          K10: 'Providence',
          L1: 'Portland',
          L5: 'Boston',
          L7: 'Quincy',
          M4: 'Salem',
          N11: 'Cape Cod',
        }.freeze

        PREPRINTED_UPGRADES = {
          'L7' => %w[6],
          'K4' => %w[14 15 619],
          'G8' => %w[14 15 619],
        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[A16 A6 B13 C10 C12 C14 C16 C2 C6 C8 D3 F3 F7 F9 H11 H3 H9 I10 I12 I4 I8 J11 J13 J7 K2 L11 L9 M10 M8 N9 K6] => '',
            %w[D11 D5 D7 D9 E10 E6 E8 F5 H5 H7] => 'upgrade=cost:40,terrain:mountain',
            %w[A10 A14 A18 A8 B15 B7 G12 G2 J9 L3] => 'upgrade=cost:20,terrain:water',
            %w[B17 B9 C4 E14 F11 G14 G6 I14 J5 K8] => 'town=revenue:0',
            %w[B5 D15 E12 E4 H13] => 'city=revenue:0',
            %w[A12 D13 G4] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[L7] => 'town=revenue:20,loc:1;city=revenue:20,loc:center;path=a:_1,b:_0',
            %w[M4] => 'town=revenue:10,loc:1;path=a:1,b:_0',
          },
          yellow: {
            %w[K10] => 'city=revenue:30;path=a:_0,b:2;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y',
            %w[B3] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=Y',
            %w[B11] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:3',
            %w[F13] => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:_0,b:1;path=a:_1,b:3;path=a:_2,b:5;label=NH',
            %w[G10] => 'city=revenue:30;path=a:_0,b:1;path=a:_0,b:2;label=H',
            %w[G8] => 'city=revenue:20;city=revenue:20;path=a:_0,b:1;path=a:_1,b:3;upgrade=cost:20,terrain:water',
            %w[I6] => 'city=revenue:20;path=a:_0,b:4;path=a:_0,b:5',
            %w[J3] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;upgrade=cost:20,terrain:water',
            %w[K4] => 'city=revenue:20,loc:center;town=revenue:10,loc:5;path=a:_0,b:_1;path=a:5,b:_1;upgrade=cost:20,terrain:water',
            %w[L5] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=B',
          },
          gray: {
            %w[a13] => 'path=a:4,b:5',
            %w[A4] => 'path=a:4,b:5',
            %w[D17] => 'path=a:2,b:3',
            %w[F15] => 'path=a:2,b:3;path=a:3,b:4',
            %w[N11] => 'town=revenue:40;path=a:2,b:_0;path=a:3,b:_0',
          },
          red: {
            %w[A2] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:5,b:_0',
            %w[B19] => 'city=revenue:yellow_40|green_50|brown_70|gray_100;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            %w[E2] => 'city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            %w[J1] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:5,b:_0',
            %w[L1] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat
      end
    end
  end
end
