# frozen_string_literal: true

module Engine
  module Game
    module G18MT
      module Map
        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        LOCATION_NAMES = {
          'A1' => 'Troy',
          'A3' => 'Half Moon',
          'A7' => 'Cut Bank',
          'A11' => 'Havre',
          'A15' => 'Beaverton',
          'A19' => 'Whitetail',
          'A21' => 'Saint Paul, MN',
          'B0' => 'Sandpoint, ID',
          'B16' => 'Glasgow',
          'B22' => 'Devils Lake, ND',
          'C1' => 'Spokane, WA',
          'C3' => 'Paradise',
          'C7' => 'Hardy',
          'C9' => 'Great Falls',
          'C11' => 'Lewiston',
          'C19' => 'Glendive',
          'D4' => 'Missoula',
          'D6' => 'Helena & Deer Lodge',
          'D14' => 'Melstone',
          'D18' => 'Miles City',
          'E5' => 'Butte',
          'E7' => 'Whitehall',
          'E9' => 'Three Forks',
          'E11' => 'Harlowton',
          'E15' => 'Custer',
          'E17' => 'Forsyth',
          'E21' => 'Bismarck, ND',
          'F10' => 'Livingston',
          'F12' => 'Laurel',
          'F20' => 'Baker',
          'F22' => 'Ashland, WI',
          'G5' => 'Lima',
          'G13' => 'Greybull, WY',
          'G15' => 'Sheridan, WY',
          'H6' => 'Idaho Falls, ID',
        }.freeze

        HEXES = {
          white: {
            %w[A9
               A13
               A17
               B8
               B10
               B14
               B18
               B20
               C17
               D16
               D20
               E13
               E19
               F14
               F18] => '',
            %w[A7 A11 C9 E17 F12] =>
              'city=revenue:0',
            %w[C19] =>
              'city=revenue:0;label=G;',
            ['B16'] =>
              'city=revenue:0;upgrade=cost:40,terrain:water;',
            %w[D4 E9] =>
              'city=revenue:0;upgrade=cost:40,terrain:mountain;',
            ['D6'] =>
              'city=revenue:0;city=revenue:0;upgrade=cost:20,terrain:mountain;label=OO;',
            %w[A15 A19 C7 C11 D14 D18 E11 E15 F20] =>
              'town=revenue:0',
            %w[A1 C3 E5 E7] =>
              'town=revenue:0;upgrade=cost:40,terrain:mountain;',
            ['F10'] =>
              'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;',
            ['G5'] =>
              'town=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:2,type:mountain,cost:40;',
            ['A3'] =>
              'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:4,type:mountain,cost:40;',
            %w[C13 C15] =>
              'upgrade=cost:40,terrain:water;',
            %w[F16 G7] =>
              'upgrade=cost:20,terrain:mountain;',
            %w[B6 B12 C5 D8 D10 D12] =>
              'upgrade=cost:40,terrain:mountain;',
            ['B4'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:1,type:impassable;'\
              'border=edge:3,type:mountain,cost:40',
            ['F6'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40',
            ['A5'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;'\
              'border=edge:1,type:mountain,cost:40',
            ['F4'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;'\
              'border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;',
            ['B2'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:4,type:impassable',
            ['F8'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:4,type:mountain,cost:40',
            ['E3'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:40',
          },
          red: {
            ['G13'] =>
              'offboard=revenue:yellow_20|brown_40;path=a:2,b:_0,terminal:1;',
            ['C1'] =>
              'offboard=revenue:yellow_30|brown_60,groups:W;label=W;path=a:4,b:_0,terminal:1;',
            ['B0'] =>
              'offboard=revenue:yellow_40|brown_70,groups:W;label=W;path=a:3,b:_0,terminal:1;'\
              'path=a:4,b:_0,terminal:1;',
            ['A21'] =>
              'city=revenue:yellow_40|brown_60,groups:E;label=E;path=a:1,b:_0,terminal:1;',
            ['B22'] =>
              'offboard=revenue:yellow_30|brown_50,groups:E;label=E;path=a:1,b:_0,terminal:1;',
            ['E21'] =>
              'offboard=revenue:yellow_20|brown_40,groups:E;label=E;path=a:2,b:_0,terminal:1;'\
              'path=a:1,b:_0,terminal:1;',
            ['F22'] =>
              'city=revenue:yellow_30|brown_50,groups:E;label=E;path=a:1,b:_0,terminal:1;',
            ['H6'] =>
              'city=revenue:yellow_40|brown_70;path=a:2,b:_0;path=a:_0,b:3',
            ['G15'] =>
              'city=revenue:yellow_20|brown_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;',
          },
          gray: { [] => '' },
          yellow: {},
        }.freeze
      end
    end
  end
end
