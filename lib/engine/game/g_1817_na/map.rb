# frozen_string_literal: true

module Engine
  module Game
    module G1817NA
      module Map
        LAYOUT = :pointy

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
          'A7' => 'Dawson City',
          'B2' => 'Anchorage',
          'B6' => 'The Klondike',
          'B18' => 'Arctic',
          'C3' => 'Asia',
          'C9' => 'Hazelton',
          'D12' => 'Edmonton',
          'D16' => 'Winnipeg',
          'D22' => 'Quebec',
          'D26' => 'Europe',
          'E9' => 'Seattle',
          'F14' => 'Denver',
          'F20' => 'Toronto',
          'F22' => 'New York',
          'H8' => 'Hawaii',
          'H10' => 'Los Angeles',
          'H18' => 'New Orleans',
          'I13' => 'Guadalajara',
          'I15' => 'Mexico City',
          'I21' => 'Miami',
          'J18' => 'Belize',
          'K21' => 'South America',
        }.freeze

        HEXES = {
          white: {
            %w[A3
               B4
               B8
               B10
               D10
               E11
               E13
               F12
               G13
               G19
               H12
               J14] => 'upgrade=cost:15,terrain:mountain',
            %w[A5
               A9
               B12
               C7
               C11
               C13
               C15
               C17
               C23
               D18
               D20
               D24
               E21
               E23
               F10
               G9
               G11
               G15
               G21
               H14
               H16
               H20
               J16
               K17
               K19] => '',
            ['E19'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['E17'] => 'border=edge:4,type:impassable',
            ['F18'] => 'border=edge:3,type:impassable',
            ['A7'] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[B2 C9 D22 E9 F14 F20 H10 I13] => 'city=revenue:0',
            ['J18'] => 'city=revenue:0;border=edge:3,type:impassable',
            %w[D8 E25 J20] => 'upgrade=cost:20,terrain:lake',
            ['I19'] => 'upgrade=cost:20,terrain:lake;border=edge:0,type:impassable',
            %w[D14 E15 F16 G17] => 'upgrade=cost:10,terrain:water',
            %w[H18 D16] => 'city=revenue:0;upgrade=cost:10,terrain:water',
          },
          gray: {
            ['B6'] =>
                     'town=revenue:yellow_50|green_20|brown_40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            %w[B14 C19] => 'path=a:1,b:4',
            %w[B16 C21] => 'path=a:1,b:5',
            ['I21'] =>
            'city=revenue:yellow_20|green_30|brown_50|gray_60;path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_0;path=a:_0,b:1',
          },
          red: {
            ['B18'] =>
                     'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0',
            ['C3'] =>
            'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0',
            ['D26'] =>
            'offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:1,b:_0;path=a:0,b:_0',
            ['H8'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0',
            ['K21'] =>
            'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0',
          },
          yellow: {
            ['D12'] => 'city=revenue:30;path=a:2,b:_0;path=a:_0,b:4;label=B',
            ['F22'] =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_1;path=a:0,b:_0;label=NY;upgrade=cost:20,terrain:lake',
            ['I15'] =>
            'city=revenue:30;path=a:1,b:_0;path=a:_0,b:5;label=B;upgrade=cost:20,terrain:lake',
          },
          blue: {
            %w[I17 C1 F8] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0',
            ['I9'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0;border=edge:4',
            ['J12'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0;border=edge:2',
            ['I11'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:2,b:_0;offboard=revenue:yellow_0,visit_cost:99;'\
                       'path=a:4,b:_0;border=edge:1;border=edge:5',
            ['A1'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:5,b:_0',
          },
        }.freeze
      end
    end
  end
end
