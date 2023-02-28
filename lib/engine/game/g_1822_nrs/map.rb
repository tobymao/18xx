# frozen_string_literal: true

module Engine
  module Game
    module G1822NRS
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 5,
          '4' => 5,
          '5' => 5,
          '6' => 6,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 5,
          '69' => 1,
          '14' => 5,
          '15' => 5,
          '80' => 5,
          '81' => 5,
          '82' => 6,
          '83' => 6,
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '207' => 2,
          '208' => 1,
          '619' => 5,
          '63' => 6,
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 3,
          '60' => 2,
          'X2' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=BM',
            },
          '768' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '767' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '769' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=Y',
            },
          'X7' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          '169' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X11' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            },
          'X13' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          'X17' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X18' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X19' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0',
            },
        }.freeze

        LOCATION_NAMES = {
          'D11' => 'Stranraer',
          'E2' => 'Highlands',
          'E6' => 'Glasgow',
          'E26' => 'Mid Wales',
          'F3' => 'Stirling',
          'F5' => 'Castlecary',
          'F7' => 'Hamilton & Coatbridge',
          'F11' => 'Dumfries',
          'F23' => 'Holyhead',
          'G4' => 'Falkirk',
          'G12' => 'Carlisle',
          'G16' => 'Barrow',
          'G20' => 'Blackpool',
          'G22' => 'Liverpool',
          'G24' => 'Chester',
          'G28' => 'Shrewbury',
          'H1' => 'Aberdeen',
          'H3' => 'Dunfermline',
          'H5' => 'Edinburgh',
          'H13' => 'Penrith',
          'H17' => 'Lancaster',
          'H19' => 'Preston',
          'H21' => 'Wigan & Bolton',
          'H23' => 'Warrington',
          'H25' => 'Crewe',
          'I22' => 'Manchester',
          'I26' => 'Stoke-on-Trent',
          'I30' => 'Birmingham',
          'J15' => 'Darlington',
          'J21' => 'Bradford',
          'J29' => 'Derby',
          'K10' => 'Newcastle',
          'K12' => 'Durham',
          'K14' => 'Middlesbrough',
          'K20' => 'Leeds',
          'K24' => 'Sheffield',
          'K28' => 'Nottingham',
          'L19' => 'York',
          'L33' => 'Northampton',
          'M16' => 'Scarborough',
          'M26' => 'Lincoln',
          'M30' => 'London',
          'N21' => 'Hull',
          'N23' => 'Grimsby',
          'N29' => 'London',
        }.freeze

        HEXES = {
          white: {
            %w[C10 D9 E8 E12 G2 G6 G26 H11 H27 H29 I6 I28 J9 J11 J13 J17 J27
               K8 K16 K18 K22 K26 K30 L15 L17 L23 L25 L27 L29 M18 M20 M24 N19
               N25 N27] =>
              '',
            ['G10'] =>
              'border=edge:0,type:water,cost:40',
            %w[L21 M28] =>
              'upgrade=cost:20,terrain:swamp',
            %w[M22] =>
              'upgrade=cost:40,terrain:swamp',
            %w[G14 I12 I24] =>
              'upgrade=cost:40,terrain:hill',
            %w[E10 F9 G8 H7 H9 H15 I8 I10 J7 J23 J25] =>
              'upgrade=cost:60,terrain:hill',
            %w[I14 I16 I18 I20 J19] =>
              'upgrade=cost:80,terrain:mountain',
            %w[D11 F3 F5 G20 G28 H13 H25 I26 K12 M16 M26] =>
              'town=revenue:0',
            ['H17'] =>
              'town=revenue:0;border=edge:2,type:impassable',
            ['H3'] =>
              'town=revenue:0;border=edge:1,type:impassable;border=edge:0,type:water,cost:40',
            ['F11'] =>
              'town=revenue:0;border=edge:5,type:impassable',
            %w[F7 H21] =>
              'town=revenue:0;town=revenue:0',
            ['G24'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp',
            ['J21'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill',
            %w[H19 J15 J29 K10 K14 K20 K24 K28] =>
              'city=revenue:0',
            ['G4'] =>
              'city=revenue:0;border=edge:4,type:impassable',
            ['G16'] =>
              'city=revenue:0;border=edge:5,type:impassable',
            ['G12'] =>
              'city=revenue:0;border=edge:2,type:impassable;border=edge:3,type:water,cost:40',
            ['L19'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp',
            ['H23'] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp',
            ['N21'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40',
            ['N23'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40',
          },
          yellow: {
            ['G22'] =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            ['H5'] =>
              'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;border=edge:3,type:water,cost:40;'\
              'label=Y',
            ['I22'] =>
              'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;upgrade=cost:60,terrain:hill;'\
              'label=BM',
          },
          gray: {
            ['E2'] =>
              'city=revenue:yellow_10|green_10|brown_20|gray_20,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['E4'] =>
              'path=a:0,b:3',
            ['E6'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_70,slots:3,loc:1;path=a:0,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0',
            ['E26'] =>
              'city=revenue:yellow_10|green_20|brown_20|gray_30,slots:3,loc:1.5;'\
              'path=a:4,b:_0,lanes:2,terminal:1;path=a:5,b:_0,lanes:2,terminal:1',
            ['F23'] =>
              'city=revenue:yellow_20|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            ['F25'] =>
              'path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1',
            ['F27'] =>
              'path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1',
            ['H1'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:1,b:_0,terminal:1',
            ['I30'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_80,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['M30'] =>
              'city=revenue:yellow_40|green_60|brown_80|gray_100,slots:1,groups:London;path=a:2,b:_0',
            ['N29'] =>
              'city=revenue:yellow_40|green_60|brown_80|gray_100,slots:1,loc:1.5,groups:London;path=a:2,b:_0;'\
              'city=revenue:yellow_40|green_60|brown_80|gray_100,slots:1,loc:4,groups:London;path=a:3,b:_1',
          },
          blue: {
            %w[L11 R31] =>
              'junction;path=a:2,b:_0,terminal:1',
            ['F17'] =>
              'junction;path=a:4,b:_0,terminal:1',
            %w[F15 F21] =>
              'junction;path=a:5,b:_0,terminal:1',
          },
        }.freeze
      end
    end
  end
end
