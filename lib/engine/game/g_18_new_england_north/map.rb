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
          '63' => 7,
          '70' => 2,
          '611' => 3,
          '216' => 2,
          '911' => 4,
        }.freeze

        LOCATION_NAMES = {
          A2: 'Montreal',
          A22: 'Bangor',
          B3: 'St. Albans',
          B9: 'Stratford',
          C18: 'Augusta',
          C2: 'Burlington',
          C22: 'Belfast',
          C8: 'St. Johnsbury',
          D17: 'Brunswick',
          D5: 'Montpelier',
          E12: 'Conway',
          E16: 'Portland',
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

        HEXES = {
          white: {
            %w[
              B1
              B17
              B19
              B21
              C4
              C10
              C14
              C16
              C20
              D1
              D3
              D7
              D13
              D15
              D19
              D21
              E2
              E4
              E6
              E8
              E10
              E14
              F5
              F7
              F11
              F13
              G2
              G4
              G6
              G8
              G12
              H5
              I2
              I4
              I8
              I10
              ] => '',
            %w[C12
               D9
               D11] => 'upgrade=cost:40,terrain:mountain',
            %w[B3
               C22
               E12
               F15
               H7
               H9
               I12] => 'town=revenue:0',
            %w[C8
               C18
               D5
               D17
               E16
               F3
               F9
               G10
               G14
               H3
               H13
               I6] => 'city=revenue:0',
          },
          yellow: {
            %w[C2] => 'city=revenue:30;path=a:_0,b:5;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y',
            %w[H11] => 'city=revenue:30;path=a:_0,b:5;path=a:_0,b:3;label=Y',
          },
          gray: {
            %w[A20] => 'path=a:4,b:0',
            %w[E18 H15] => 'path=a:1,b:2',
            %w[A22] => 'city=revenue:30;path=a:_0,b:0;path=a:_0,b:1',
          },
          red: {
            %w[J1 J5] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:3,b:_0',
            %w[A2] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:0,b:_0;path=a:5,b:_0',
            %w[I14] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:2,b:_0',
            %w[J13] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:2,b:_0',
          },
        }.freeze
      end
    end
  end
end
