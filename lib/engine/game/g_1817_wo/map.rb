# frozen_string_literal: true

module Engine
  module Game
    module G1817WO
      module Map
        LAYOUT = :flat

        TILES = {
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '54' => 'unlimited',
          '57' => 'unlimited',
          '62' => 'unlimited',
          '63' => 'unlimited',
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
          'X00' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'X30' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
          },
        }.freeze

        LOCATION_NAMES = {
          'C2' => 'Prince of Wales Fort',
          'D7' => 'Amazonia',
          'G4' => 'Mare Nostrum',
          'G8' => 'Beginnings',
          'I2' => 'Brrrrrrrrrr!',
          'I6' => 'New Pittsburgh',
          'K4' => 'Dynasties',
          'K8' => 'Terra Australis',
          'A2' => 'Gold Rush',
          'A6' => "Kingdom of Hawai'i",
          'D9' => 'Antarctica',
          'F1' => 'Vikings',
          'H9' => 'Libertalia',
          'J9' => 'You are lost',
          'L1' => 'Gold Rush',
          'L9' => 'Nieuw Zeeland',
          'C4' => 'NYC',
        }.freeze

        HEXES = {
          white: {
            %w[B3
               B5
               C6
               D3
               D5
               E6
               E8
               F3
               F5
               G2
               G6
               H1
               H5
               H7
               J5
               J7
               L3
               L7] => '',
            %w[B7 C8 E2 E4 F9 I8 K6 L5] =>
                   'upgrade=cost:15,terrain:lake',
            %w[H3 I4 J3] => 'upgrade=cost:10,terrain:water',
            %w[B1 F7 K2] => 'upgrade=cost:20',
            ['C2'] => 'city=revenue:0;upgrade=cost:15,terrain:lake',
            %w[G8 I2 I6 K8] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;upgrade=cost:20',
            %w[G4 K4] => 'city=revenue:0;upgrade=cost:10,terrain:water',
          },
          gray: {
            ['J1'] => 'path=a:0,b:1;path=a:1,b:5;path=a:0,b:5',
            ['A6'] =>
            'city=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:_0,b:5',
            ['F1'] =>
            'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:1,b:_0;path=a:5,b:_0',
            ['H9'] =>
            'town=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:_0,b:4',
            ['L9'] => 'city=revenue:0',
          },
          yellow: {
            ['C4'] =>
                        'city=revenue:40;city=revenue:40;path=a:2,b:_0;path=a:5,b:_1;label=NY;upgrade=cost:20',
          },
          red: {
            ['A2'] =>
                     'offboard=revenue:yellow_30|green_50|brown_20|gray_60;path=a:4,b:_0',
            ['D9'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:4,b:_0',
            ['J9'] =>
            'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:3,b:_0;path=a:4,b:_0',
            ['L1'] =>
            'offboard=revenue:yellow_30|green_50|brown_20|gray_60;path=a:1,b:_0',
          },
        }.freeze
      end
    end
  end
end
