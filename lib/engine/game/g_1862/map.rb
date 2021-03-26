# frozen_string_literal: true

module Engine
  module Game
    module G1862
      module Map
        TILES = {
          '5' => 10,
          '6' => 10,
          '14' => 11,
          '15' => 10,
          '16' => 2,
          '17' => 5,
          '18' => 5,
          '19' => 4,
          '20' => 6,
          '21' => 2,
          '22' => 2,
          '53y' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=Y',
          },
          '57' => 12,
          '61y' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:4,b:_0;label=Y',
          },
          '201' => 2,
          '202' => 4,
          '611' => 8,
          '619' => 10,
          '621' => 2,
          '778' =>
          {
            'count' => 4,
            'color' => 'brown',
            'code' => 'path=a:0,b:4;path=a:1,b:3;path=a:2,b:5',
          },
          '779' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'path=a:0,b:4;path=a:1,b:5;path=a:2,b:3',
          },
          '780' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:2;path=a:4,b:5',
          },
          '790' => 4,
          '791' => 4,
          '792' => 2,
          '793' => 3,
          '794' => 3,
          '795' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0;label=I',
          },
          '796' => 3,
          '797' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=H',
          },
          '798' => 3,
          '891y' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Y',
          },
          '8850' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:5,b:_0',
          },
          '8851' =>
          {
            'count' => 8,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:4,b:_0',
          },
          '8852' =>
          {
            'count' => 12,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A6' => 'Midlands',
          'A10' => 'The West',
          'E2' => 'Wells-Next-The-Sea',
          'B3' => 'Holbeach',
          'C4' => "King's Lynn",
          'D3' => 'Hunstanton',
          'E4' => 'Fakenham',
          'F3' => 'Cromer',
          'G4' => 'N Walsham',
          'B5' => 'Wisbech',
          'C6' => 'Downham Market',
          'D5' => 'Swaffham',
          'E6' => 'Watton',
          'F5' => 'Norwich',
          'G6' => 'Acle',
          'H5' => 'Great Yarmouth',
          'B7' => 'March',
          'C8' => 'Ely',
          'D7' => 'Brandon',
          'E8' => 'Thetford',
          'F7' => 'Diss',
          'G8' => 'Beccles',
          'H7' => 'Lowestoft',
          'B9' => 'Cambridge',
          'C10' => 'Newmarket',
          'D9' => 'Bury St. Edmunds',
          'E10' => 'Stowmarket',
          'F9' => 'Framingham',
          'G10' => 'Woodbridge',
          'B11' => 'Royston',
          'C12' => 'Great Dunmow',
          'D11' => 'Sudbury',
          'E12' => 'Colchester',
          'F11' => 'Ipswitch',
          'G12' => 'Felixstowe',
          'B13' => "Bishop's Stortford",
          'C14' => 'London',
          'D13' => 'Witham',
          'E14' => 'Tiptree',
          'F13' => 'Harwich',
        }.freeze

        HEXES = {
          white: {
            # towns
            %w[
              B3
              D3
              G4
              E6
              G6
              D7
              F9
              E10
              G10
              B11
              C12
            ] => 'town=revenue:0',
            %w[
              E14
            ] => 'town=revenue:0;border=edge:4,type:impassable',
            # cities
            %w[
            E2
            F3
            C4
            E4
            B5
            D5
            C6
            B7
            F7
            H7
            E8
            G8
            C10
            D11
            B13
            D13
            ] => 'city=revenue:0',
            %w[
            F5
            B9
            E12
            ] => 'city=revenue:0;label=N',
            %w[
            H5
            C8
            D9
            ] => 'city=revenue:0;label=Y',
            %w[
            F11
            ] => 'city=revenue:0;label=N;border=edge:0,type:impassable',
            %w[
            G12
            ] => 'city=revenue:0;border=edge:1,type:impassable',
            %w[
            F13
            ] => 'city=revenue:0;label=Y;border=edge:1,type:impassable;border=edge:3,type:impassable;'\
              'border=edge:4,type:impassable',
          },
          blue: {
            %w[
            E0
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North0;'\
              'border=edge:1;border=edge:5',
            %w[
            D1
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North0,hide:1;path=a:5,b:_0;'\
              'border=edge:1,type:divider;border=edge:4',
            %w[
            F1
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North0,hide:1;path=a:1,b:_0;'\
              'offboard=revenue:yellow_80|green_90|brown_100,groups:North1,hide:1;path=a:0,b:_1;'\
              'partition=a:1,b:4,type:divider;border=edge:2;border=edge:5',
            %w[
            C2
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North;path=a:0,b:_0;'\
              'border=edge:4,type:divider',
            %w[
            G2
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North1;border=edge:2',
            %w[
            I4
            ] => 'offboard=revenue:yellow_80|green_100|brown_120,groups:NorthEast;path=a:1,b:_0;'\
              'border=edge:0',
            %w[
            I6
            ] => 'offboard=revenue:yellow_80|green_100|brown_120,groups:NorthEast,hide:1;path=a:2,b:_0;'\
              'offboard=revenue:yellow_60|green_90|brown_120,groups:East,hide:1;path=a:1,b:_1;'\
              'partition=a:2,b:5,type:divider;border=edge:3;border=edge:0',
            %w[
            I8
            ] => 'offboard=revenue:yellow_60|green_90|brown_120,groups:East;path=a:2,b:_0;'\
              'border=edge:3;border=edge:1',
            %w[
            H9
            ] => 'offboard=revenue:yellow_60|green_90|brown_120,groups:East,hide:1;path=a:3,b:_0;'\
              'border=edge:4;border=edge:0,type:divider',
            %w[
            H11
            ] => 'offboard=revenue:yellow_70|green_100|brown_130,groups:Denmark,hide:1;path=a:1,b:_0;'\
              'border=edge:0;border=edge:3,type:divider',
            %w[
            H13
            ] => 'offboard=revenue:yellow_70|green_100|brown_130,groups:Denmark;path=a:2,b:_0;'\
              'border=edge:3;border=edge:1',
            %w[
            G14
            ] => 'offboard=revenue:yellow_70|green_100|brown_130,groups:Denmark,hide:1;path=a:3,b:_0;'\
              'offboard=revenue:yellow_60|green_90|brown_120,groups:Holland,hide:1;path=a:2,b:_1;'\
              'border=edge:4;border=edge:1;partition=a:3,b:0,type:divider',
            %w[
            F15
            ] => 'offboard=revenue:yellow_70|green_100|brown_130,groups:Holland;path=a:3,b:_0;'\
              'border=edge:4',
          },
          red: {
            %w[
            A2
            ] => 'offboard=revenue:yellow_40|green_90|brown_140,hide:1,groups:Midlands;path=a:5,b:_0;'\
              'border=edge:0',
            %w[
            A4
            ] => 'offboard=revenue:yellow_40|green_90|brown_140,hide:1,groups:Midlands;path=a:4,b:_0;path=a:5,b:_0;'\
              'border=edge:0;border=edge:3',
            %w[
            A6
            ] => 'offboard=revenue:yellow_40|green_90|brown_140,groups:Midlands;path=a:4,b:_0;path=a:5,b:_0;'\
              'border=edge:0;border=edge:3',
            %w[
            A8
            ] => 'offboard=revenue:yellow_40|green_90|brown_140,groups:Midlands,hide:1;path=a:4,b:_0;'\
              'offboard=revenue:yellow_70|green_100|brown_120,groups:West,hide:1;path=a:5,b:_1;'\
              'border=edge:0;border=edge:3;partition=a:2,b:5,type:divider',
            %w[
            A10
            ] => 'offboard=revenue:yellow_70|green_100|brown_120,groups:West;path=a:4,b:_0;path=a:5,b:_0;'\
              'border=edge:0;border=edge:3',
            %w[
            A12
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:5,b:_0;'\
              'offboard=revenue:yellow_70|green_100|brown_120,groups:West,hide:1;path=a:4,b:_1;'\
              'border=edge:0;border=edge:3;partition=a:2,b:5,type:divider',
            %w[
            A14
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:4,b:_0;'\
              'border=edge:5;border=edge:3',
            %w[
            C14
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;border=edge:5;border=edge:1',
            %w[
            B15
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:3,b:_0;'\
              'border=edge:2;city=revenue:0,slots:2;border=edge:4',
            %w[
            D15
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:3,b:_0;path=a:4,b:_0;'\
              'border=edge:2;city=revenue:0,slots:2',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
