# frozen_string_literal: true

module Engine
  module Game
    module G1862
      module Map
        TILES = {
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 4,
          '9' => 4,
          '12' => 2,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '57' => 2,
          '115' => 2,
          '205' => 1,
          '206' => 1,
          '625' => 1,
          '626' => 1,
          '741' =>
          {
            'count' => 5,
            'color' => 'yellow',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0',
          },
          '742' =>
          {
            'count' => 10,
            'color' => 'yellow',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:2,b:_0',
          },
          '743' =>
          {
            'count' => 7,
            'color' => 'yellow',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:3,b:_0',
          },
          '744' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' =>
            'halt=symbol:£,loc:0;halt=symbol:£,loc:3;path=a:0,b:_0;path=a:3,b:_1;path=a:_0,b:_1',
          },
          '745' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' =>
            'halt=symbol:£,loc:0;halt=symbol:£,loc:2;path=a:0,b:_0;path=a:2,b:_1;path=a:_0,b:_1',
          },
          '746' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:_0,b:3;label=B',
          },
          '747' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
          },
          '748' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:2',
          },
          '749' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3',
          },
          '750' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '751' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          '752' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          '753' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '754' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'halt=symbol:£,loc:0;town=revenue:10,loc:center;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
              'path=a:_0,b:_1',
          },
          '755' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'halt=symbol:£,loc:0;town=revenue:10,loc:center;path=a:0,b:_0;path=a:4,b:_1;path=a:3,b:_1;'\
              'path=a:_0,b:_1',
          },
          '756' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0',
          },
          '757' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
          },
          '758' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:4,b:_0;path=a:5,b:_0;label=R',
          },
          '759' =>
          { 'count' => 3, 'color' => 'green', 'code' => 'city=revenue:30;path=a:0,b:_0' },
          '760' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,loc:4;city=revenue:40,loc:0.5;path=a:1,b:_1;path=a:2,b:_0;label=V',
          },
          '761' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:20,loc:center;halt=symbol:£,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
              'path=a:3,b:_1;path=a:_0,b:_1;label=M',
          },
          '762' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=B',
          },
          '763' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,loc:2.5;city=revenue:30,loc:5.5;path=a:1,b:_0;path=a:2,b:_0;'\
              'path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_1;label=N',
          },
          '764' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:1',
          },
          '765' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:3',
          },
          '766' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:2',
          },
          '767' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          '768' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '769' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '770' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;label=B',
          },
          '771' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '772' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0',
          },
          '773' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2,loc:2.5;city=revenue:20,loc:5.5;path=a:1,b:_0;path=a:2,b:_0;'\
              'path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1;path=a:_0,b:_1;label=N',
          },
          '774' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,loc:4;city=revenue:50,loc:1;path=a:2,b:_0;path=a:1,b:_1,loc:0.5;label=V',
          },
          '775' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:20,slots:2,loc:center;town=revenue:10,loc:3;path=a:0,b:_0;path=a:1,b:_0;'\
              'path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1;label=M',
          },
          '776' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          '777' =>
          { 'count' => 2, 'color' => 'brown', 'code' => 'city=revenue:60;path=a:0,b:_0' },
          '778' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:5;path=a:2,b:4',
          },
          '779' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:4,b:5;path=a:1,b:3;path=a:0,b:2',
          },
          '780' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:1,b:2;path=a:4,b:5;path=a:0,b:3',
          },
          '781' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:1;path=a:2,b:3;path=a:4,b:5',
          },
          '782' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1',
          },
          '783' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;'\
              'path=a:3,b:_0;path=a:5,b:_0;path=a:_0,b:_1',
          },
          '784' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1',
          },
          '785' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;'\
              'path=a:3,b:_0;path=a:4,b:_0;path=a:_0,b:_1',
          },
          '786' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:4,b:_0;path=a:5,b:_0;label=R',
          },
          '787' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:20,loc:3;town=revenue:10,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;'\
              'path=a:_2,b:_1;path=a:_0,b:_1;label=C',
          },
          '788' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,loc:3;town=revenue:10,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;'\
              'path=a:1,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C',
          },
          '789' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,loc:3;town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;'\
              'path=a:1,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C',
          },
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Midlands',
          'A6' => 'Midlands',
          'A10' => 'The West',
          'E2' => 'Wells-Next-The-Sea',
          'B3' => 'Holbeach',
          'C4' => "King's Lynn",
          'D3' => 'Hunstanton',
          'E4' => 'Fakenham',
          'F3' => 'Cromer',
          'G4' => 'N Walsham',
          'B5' => 'Wisbeach',
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
          'A14' => 'London',
          'C14' => 'London',
          'D15' => 'London',
          'B15' => 'London',
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
            ] => 'city=revenue:0;label=N;border=edge:0',
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
            ] => 'path=a:5,b:1;border=edge:1;border=edge:5',
            %w[
            D1
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North0;path=a:4,b:_0;path=a:5,b:_0;'\
              'path=a:1,b:_0;border=edge:1;border=edge:4',
            %w[
            F1
            ] => 'path=a:1,b:2;border=edge:2;partition=a:2,b:5;path=a:0,b:5;border=edge:5',
            %w[
            C2
            ] => 'path=a:0,b:4;border=edge:4',
            %w[
            G2
            ] => 'offboard=revenue:yellow_80|green_90|brown_100,groups:North1;path=a:2,b:_0;border=edge:2',
            %w[
            I4
            ] => 'offboard=revenue:yellow_80|green_100|brown_120,groups:NorthEast;path=a:1,b:_0;path=a:0,b:_0;'\
              'border=edge:0',
            %w[
            I6
            ] => 'path=a:2,b:3;border=edge:3;path=a:1,b:0;border=edge:0',
            %w[
            I8
            ] => 'offboard=revenue:yellow_60|green_90|brown_120,groups:East;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:1,b:_0;border=edge:3;border=edge:1',
            %w[
            H9
            ] => 'path=a:3,b:4;border=edge:4',
            %w[
            H11
            ] => 'path=a:1,b:0;border=edge:0',
            %w[
            H13
            ] => 'offboard=revenue:yellow_70|green_100|brown_130,groups:Denmark;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:1,b:_0;border=edge:3;border=edge:1',
            %w[
            G14
            ] => 'path=a:3,b:4;border=edge:4;path=a:2,b:1;border=edge:1',
            %w[
            F15
            ] => 'offboard=revenue:yellow_70|green_100|brown_130,groups:Holland;path=a:3,b:_0;path=a:4,b:_0;'\
              'border=edge:4',
          },
          red: {
            %w[
            A2
            ] => 'path=a:5,b:0;border=edge:0',
            %w[
            A4
            ] => 'offboard=revenue:yellow_40|green_90|brown_140,hide:1,groups:Midlands;path=a:4,b:_0;path=a:5,b:_0;'\
              'path=a:3,b:_0;border=edge:0;border=edge:3',
            %w[
            A6
            ] => 'offboard=revenue:yellow_40|green_90|brown_140,groups:Midlands;path=a:4,b:_0;path=a:5,b:_0;'\
              'path=a:0,b:_0;border=edge:0;border=edge:3',
            %w[
            A8
            ] => 'path=a:5,b:0;border=edge:0;path=a:4,b:3;border=edge:3',
            %w[
            A10
            ] => 'offboard=revenue:yellow_70|green_100|brown_120,groups:West;path=a:4,b:_0;path=a:5,b:_0;'\
              'path=a:0,b:_0;path=a:3,b:_0;border=edge:0;border=edge:3',
            %w[
            A12
            ] => 'path=a:5,b:0;border=edge:0;path=a:4,b:3;border=edge:3',
            %w[
            A14
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:4,b:_0;path=a:3,b:_0;'\
              'border=edge:5;border=edge:3',
            %w[
            C14
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;border=edge:5;border=edge:1',
            %w[
            B15
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:3,b:_0;'\
              'border=edge:2;city=revenue:0,slots:2',
            %w[
            D15
            ] => 'offboard=revenue:yellow_100|green_150|brown_200,groups:London,hide:1;path=a:3,b:_0;path=a:4,b:_0;'\
              'border=edge:2;border=edge:4;city=revenue:0,slots:2',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
