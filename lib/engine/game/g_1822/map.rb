# frozen_string_literal: true

module Engine
  module Game
    module G1822
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 6,
          '4' => 6,
          '5' => 6,
          '6' => 8,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '58' => 6,
          '69' => 1,
          '14' => 6,
          '15' => 6,
          '80' => 6,
          '81' => 6,
          '82' => 8,
          '83' => 8,
          '141' => 4,
          '142' => 4,
          '143' => 4,
          '144' => 4,
          '207' => 2,
          '208' => 1,
          '619' => 6,
          '622' => 1,
          '63' => 8,
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 4,
          '60' => 2,
          'X20' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=L',
            },
          '405' =>
            {
              'count' => 3,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X1' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
            },
          'X2' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=BM',
            },
          'X3' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S',
            },
          'X4' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;upgrade=cost:100;label=EC',
            },
          'X21' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=L',
            },
          '768' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '767' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '769' =>
            {
              'count' => 6,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=Y',
            },
          'X6' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
            },
          'X7' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          'X8' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S',
            },
          'X9' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:0,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0,lanes:2;upgrade=cost:100;label=EC',
            },
          'X10' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X22' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=L',
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
          'X12' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
            },
          'X13' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          'X14' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:1,b:_0;path=a:4,b:_0;label=S',
            },
          'X15' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:0,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0,lanes:2;label=EC',
            },
          'X16' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
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
          'X23' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;'\
                'city=revenue:100;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;'\
                'path=a:5,b:_5;label=L',
            },
        }.freeze

        LOCATION_NAMES = {
          'A42' => 'Cornwall',
          'B43' => 'Plymouth',
          'C34' => 'Fishguard',
          'C38' => 'Barnstaple',
          'D11' => 'Stranraer',
          'D35' => 'Swansea & Oystermouth',
          'D41' => 'Exeter',
          'E2' => 'Highlands',
          'E6' => 'Glasgow',
          'E28' => 'Mid Wales',
          'E32' => 'Merthyr Tydfil & Pontypool',
          'E40' => 'Taunton',
          'F3' => 'Stirling',
          'F5' => 'Castlecary',
          'F7' => 'Hamilton & Coatbridge',
          'F11' => 'Dumfries',
          'F23' => 'Holyhead',
          'F35' => 'Cardiff',
          'G4' => 'Falkirk',
          'G12' => 'Carlisle',
          'G16' => 'Barrow',
          'G20' => 'Blackpool',
          'G22' => 'Liverpool',
          'G24' => 'Chester',
          'G28' => 'Shrewsbury',
          'G32' => 'Hereford',
          'G34' => 'Newport',
          'G36' => 'Bristol',
          'G42' => 'Dorchester',
          'H1' => 'Aberdeen',
          'H3' => 'Dunfermline',
          'H5' => 'Edinburgh',
          'H13' => 'Penrith',
          'H17' => 'Lancaster',
          'H19' => 'Preston',
          'H21' => 'Wigan & Bolton',
          'H23' => 'Warrington',
          'H25' => 'Crewe',
          'H33' => 'Gloucester',
          'H37' => 'Bath & Radstock',
          'I22' => 'Manchester',
          'I26' => 'Stoke-on-Trent',
          'I30' => 'Birmingham',
          'I40' => 'Salisbury',
          'I42' => 'Bournemouth',
          'J15' => 'Darlington',
          'J21' => 'Bradford',
          'J29' => 'Derby',
          'J31' => 'Coventry',
          'J41' => 'Southampton',
          'K10' => 'Newcastle',
          'K12' => 'Durham',
          'K14' => 'Middlesbrough',
          'K20' => 'Leeds',
          'K24' => 'Sheffield',
          'K28' => 'Nottingham',
          'K30' => 'Leicester',
          'K36' => 'Oxford',
          'K38' => 'Reading',
          'K42' => 'Portsmouth',
          'L19' => 'York',
          'L33' => 'Northampton',
          'M16' => 'Scarborough',
          'M26' => 'Lincoln',
          'M30' => 'Peterborough',
          'M36' => 'Hertford',
          'M38' => 'London',
          'M42' => 'Brighton',
          'N21' => 'Hull',
          'N23' => 'Grimsby',
          'N33' => 'Cambridge',
          'O30' => "King's Lynn",
          'O36' => 'Colchester',
          'O40' => 'Maidstone',
          'O42' => 'Folkstone',
          'P35' => 'Ipswich',
          'P39' => 'Canterbury',
          'P41' => 'Dover',
          'P43' => 'English Channel',
          'Q30' => 'Norwich',
          'Q44' => 'France',
        }.freeze

        HEXES = {
          white: {
            %w[B39 C10 D9 E8 E12 F41 G2 G6 G26 G38 G40 H11 H27 H29 H31 H41 I6 I28 I34 I36 J9 J11 J13 J17 J27 J33
               J35 J37 K8 K16 K18 K22 K26 K32 K34 K40 L15 L17 L23 L25 L27 L29 L31 L35 L41 M18 M20 M24 M32 M34 N19
               N25 N31 N35 N41 O32 O34 P27 P29 P31 P33 Q28 Q32 Q34] =>
              '',
            ['H43'] =>
              'border=edge:4,type:impassable',
            ['D37'] =>
              'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['N27'] =>
              'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['E36'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:5,type:impassable',
            ['G10'] =>
              'border=edge:0,type:water,cost:40',
            ['O38'] =>
              'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40;border=edge:5,type:impassable',
            ['N37'] =>
              'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:40;stub=edge:1',
            ['L37'] =>
              'stub=edge:5',
            ['L39'] =>
              'stub=edge:4',
            ['M40'] =>
              'stub=edge:3',
            %w[C42 F39 L21 M28] =>
              'upgrade=cost:20,terrain:swamp',
            ['O28'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['E38'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:3,type:impassable',
            ['H35'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:2,type:water,cost:40',
            ['N39'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40;stub=edge:2',
            ['F37'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[D43 I32 M22] =>
              'upgrade=cost:40,terrain:swamp',
            ['N29'] =>
              'upgrade=cost:40,terrain:swamp;border=edge:3,type:impassable;border=edge:4,type:impassable',
            %w[B41 D39 G14 G30 H39 I12 I24 I38 J39] =>
              'upgrade=cost:40,terrain:hill',
            %w[C40 E10 F9 G8 H7 H9 H15 I8 I10 J7 J23 J25] =>
              'upgrade=cost:60,terrain:hill',
            %w[I14 I16 I18 I20 J19] =>
              'upgrade=cost:80,terrain:mountain',
            %w[C38 D11 E40 F3 F5 G20 G28 G32 G42 H13 H25 I26 J31 K12 K36 M16 M26 N33 O42] =>
              'town=revenue:0',
            %w[H17 P39] =>
              'town=revenue:0;border=edge:2,type:impassable',
            ['H3'] =>
              'town=revenue:0;border=edge:1,type:impassable;border=edge:0,type:water,cost:40',
            ['F11'] =>
              'town=revenue:0;border=edge:5,type:impassable',
            ['O36'] =>
              'town=revenue:0;border=edge:0,type:water,cost:40',
            ['M36'] =>
              'town=revenue:0;stub=edge:0',
            %w[F7 H21] =>
              'town=revenue:0;town=revenue:0',
            ['H37'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:swamp',
            ['O30'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp',
            ['G34'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40;'\
              'border=edge:5,type:water,cost:40',
            ['G24'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp',
            ['I40'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill',
            ['J21'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill',
            %w[D41 H19 J15 J29 J41 K10 K14 K20 K24 K28 K30 K38 L33 M30 P35 P41] =>
              'city=revenue:0',
            ['I42'] =>
              'city=revenue:0;border=edge:1,type:impassable',
            ['G4'] =>
              'city=revenue:0;border=edge:4,type:impassable',
            ['G16'] =>
              'city=revenue:0;border=edge:5,type:impassable',
            ['G12'] =>
              'city=revenue:0;border=edge:2,type:impassable;border=edge:3,type:water,cost:40',
            ['D35'] =>
              'city=revenue:20,loc:center;town=revenue:10,loc:1;path=a:_0,b:_1;border=edge:0,type:impassable;'\
              'future_label=label:S,color:green',
            ['M38'] =>
              'city=revenue:20,groups:London;city=revenue:20,groups:London;city=revenue:20,groups:London;'\
              'city=revenue:20,groups:London;city=revenue:20,groups:London;city=revenue:20,groups:London;'\
              'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;'\
              'label=L',
            %w[B43 K42 M42] =>
              'city=revenue:0;future_label=label:T,color:green',
            %w[L19 Q30] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp',
            %w[H23 H33] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp',
            ['O40'] =>
              'city=revenue:0;upgrade=cost:40,terrain:hill',
            ['N21'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40',
            ['N23'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40',
          },
          yellow: {
            ['F35'] =>
              'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;border=edge:0,type:impassable;'\
              'border=edge:5,type:impassable;label=C',
            ['G22'] =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            ['G36'] =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:2,type:impassable;'\
              'border=edge:3,type:water,cost:40;upgrade=cost:20,terrain:swamp;label=Y',
            ['H5'] =>
              'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;border=edge:3,type:water,cost:40;'\
              'label=Y',
            ['I22'] =>
              'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;upgrade=cost:60,terrain:hill;'\
              'label=BM',
            ['I30'] =>
              'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;upgrade=cost:40,terrain:swamp;'\
              'label=BM',
            ['P43'] =>
              'city=revenue:0;upgrade=cost:100;label=EC',
          },
          gray: {
            ['A42'] =>
              'city=revenue:yellow_40|green_30|brown_30|gray_40,slots:2,loc:1.5;path=a:4,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['C34'] =>
              'city=revenue:yellow_10|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            ['E2'] =>
              'city=revenue:yellow_10|green_10|brown_20|gray_20,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['E4'] =>
              'path=a:0,b:3',
            ['E6'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_70,slots:3,loc:1;path=a:0,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0',
            ['E26'] =>
              'path=a:0,b:4,lanes:2',
            ['E28'] =>
              'city=revenue:yellow_10|green_20|brown_20|gray_30,slots:3,loc:1.5;path=a:0,b:_0,lanes:2,terminal:1;'\
              'path=a:3,b:_0,lanes:2,terminal:1;path=a:4,b:_0,lanes:2,terminal:1;path=a:5,b:_0,lanes:2,terminal:1',
            ['E30'] =>
              'path=a:3,b:5,lanes:2',
            ['E32'] =>
              'path=a:0,b:5',
            ['E34'] =>
              'city=revenue:yellow_30|green_40|brown_30|gray_10,slots:2,loc:0;path=a:3,b:_0;'\
              'path=a:4,b:_0,terminal:1,ignore:1;path=a:5,b:_0',
            ['F23'] =>
              'city=revenue:yellow_20|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            %w[F25 F27] =>
              'path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1',
            %w[F29 F31] =>
              'path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1',
            ['F33'] =>
              'city=revenue:yellow_20|green_40|brown_30|gray_10,slots:2,loc:4;path=a:1,b:_0;'\
              'path=a:2,b:_0,terminal:1,ignore:1;path=a:5,b:_0',
            ['H1'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:1,b:_0,terminal:1',
            ['Q44'] =>
              'offboard=revenue:yellow_0|green_60|brown_90|gray_120,visit_cost:0;path=a:2,b:_0',
          },
          blue: {
            %w[L11 J43 Q36 Q42 R31] =>
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
