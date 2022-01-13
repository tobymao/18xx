# frozen_string_literal: true

module Engine
  module Game
    module G18NewEnglandNorth
      module Map
        LAYOUT = :pointy

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
          '63' => 2,
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
          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;path=a:_0,b:0;path=a:_0,b:1;'\
                      'path=a:2,b:_0;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5;label=H',
          },
        }.freeze

        LOCATION_NAMES = {
          A2: 'Montreal',
          A22: 'Bangor',
          B3: 'St. Albans',
          B9: 'Stratford',
          C18: 'Augusta',
          C2: 'Burlington',
          B21: 'Belfast',
          C8: 'St. Johnsbury',
          D7: 'Woodville',
          D17: 'Brunswick',
          D5: 'Montpelier',
          E12: 'Conway',
          E16: 'Portland',
          E18: 'Portland Harbor',
          F15: 'Saco',
          F3: 'Rutland',
          F9: 'Bristol',
          G10: 'Concord',
          G14: 'Dover',
          H11: 'Manchester',
          H13: 'Portsmouth',
          H3: 'Bennington',
          H7: 'Keene',
          H9: 'Peterboro',
          I12: 'Nashua',
          I6: 'Brattleboro',
          J1: 'Hudson',
          I14: 'Salem',
          J13: 'Boston',
          J5: 'Hartford',
        }.freeze

        PREPRINTED_UPGRADES = {}.freeze

        HEXES = {
          white: {
            %w[
              B1
              B17
              C4
              C10
              C14
              C20
              C22
              D3
              D13
              D15
              D19
              D21
              E4
              E8
              F5
              F13
              G2
              G4
              G8
              G12
              I2
              I4
              I8
              I10
              ] => '',
            %w[C12
               D9
               D11
               E10] => 'upgrade=cost:40,terrain:mountain',
            %w[B19
               C16
               D1
               E2
               E6
               E14
               F7
               F11
               G6
               H5] => 'upgrade=cost:20,terrain:water',
            %w[B21
               E12
               F15
               H7
               H9
               I12] => 'town=revenue:0',
            %w[ D17
                F9
                H13
                I6] => 'city=revenue:0',
          },
          yellow: {
            %w[C2] => 'city=revenue:30;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=B',
            %w[C18] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:3',
            %w[E16] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;path=a:_0,b:3;label=H',
            %w[F3] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:5;upgrade=cost:20,terrain:water',
            %w[G10] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:2;upgrade=cost:20,terrain:water',
            %w[G14] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:3',
            %w[D5] => 'city=revenue:30;path=a:_0,b:4;path=a:_0,b:0;upgrade=cost:20,terrain:water;label=Y',
            %w[H3] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:2;path=a:_0,b:4',
            %w[H11] => 'city=revenue:30;path=a:_0,b:5;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y',
          },
          gray: {
            %w[A20] => 'path=a:4,b:0',
            %w[B3] => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[B5] => 'path=a:1,b:5',
            %w[C6] => 'path=a:2,b:4',
            %w[C8] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0',
            %w[D7] => 'town=revenue:10;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            %w[F17 H15] => 'path=a:1,b:2',
            %w[A22] => 'city=revenue:40;path=a:_0,b:0;path=a:_0,b:1',
          },
          red: {
            %w[J1] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:3,b:_0',
            %w[J5] => 'offboard=revenue:yellow_10|green_30|brown_40|gray_50;path=a:3,b:_0',
            %w[A2] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0;path=a:5,b:_0',
            %w[E18] => 'offboard=revenue:green_30|brown_40|gray_60;path=a:1,b:_0',
            %w[I14] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0',
            %w[J13] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:2,b:_0',
          },
        }.freeze
      end
    end
  end
end
