# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'

module Engine
  module Game
    module G1822MRS
      class Game < G1822::Game
        include_meta(G1822MRS::Meta)

        BIDDING_BOX_START_MINOR = 'M24'
        BIDDING_BOX_START_MINOR_ADV = 'M14'

        CERT_LIMIT = { 2 => 27, 3 => 18, 4 => 14, 5 => 11, 6 => 9, 7 => 8 }.freeze

        EXCHANGE_TOKENS = {
          'LNWR' => 4,
          'GWR' => 3,
          'LBSCR' => 3,
          'SECR' => 3,
          'MR' => 3,
          'LYR' => 3,
          'SWR' => 3,
        }.freeze

        STARTING_CASH = { 2 => 750, 3 => 500, 4 => 375, 5 => 300, 6 => 250, 7 => 215 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P18
                                C1 C2 C3 C4 C6 C7 C9 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_COMPANIES_ADVANCED = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                         C1 C2 C3 C4 C6 C7 C9 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                         M16 16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_COMPANIES_TWOPLAYER = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                          C1 C2 C3 C4 C6 C7 C9 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                          M16 16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_CORPORATIONS = %w[7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 24
                                   LNWR GWR LBSCR SECR MR LYR SWR].freeze

        LOCATION_NAMES = {
          'C34' => 'Fishguard',
          'D35' => 'Swansea & Oystermouth',
          'D39' => 'Southwest England',
          'E28' => 'Mid Wales',
          'E32' => 'Merthyr Tydfil & Pontypool',
          'F23' => 'Holyhead',
          'F35' => 'Cardiff',
          'G20' => 'Blackpool',
          'G22' => 'Liverpool',
          'G24' => 'Chester',
          'G28' => 'Shrewsbury',
          'G32' => 'Hereford',
          'G34' => 'Newport',
          'G36' => 'Bristol',
          'G42' => 'Dorchester',
          'H17' => 'Glasgow',
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
          'J21' => 'Bradford',
          'J29' => 'Derby',
          'J31' => 'Coventry',
          'J41' => 'Southampton',
          'K16' => 'Edinburgh',
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
            %w[F41 G26 G38 G40 H27 H29 H31 H41 I28 I34 I36 J17 J27 J33
               J35 J37 K18 K22 K26 K32 K34 K40 L17 L23 L25 L27 L29 L31 L35 L41 M18 M20 M24 M32 M34 N19
               N25 N31 N35 N41 O32 O34 P27 P29 P31 P33 Q28 Q32 Q34] =>
              '',
            ['H43'] =>
              'border=edge:4,type:impassable',
            ['N27'] =>
              'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['E36'] =>
              'border=edge:0,type:impassable;border=edge:5,type:impassable',
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
            %w[F39 L21 M28] =>
              'upgrade=cost:20,terrain:swamp',
            ['O28'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['H35'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:2,type:water,cost:40',
            ['N39'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40;stub=edge:2',
            ['F37'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[I32 M22] =>
              'upgrade=cost:40,terrain:swamp',
            ['N29'] =>
              'upgrade=cost:40,terrain:swamp;border=edge:3,type:impassable;border=edge:4,type:impassable',
            %w[G30 H39 I24 I38 J39] =>
              'upgrade=cost:40,terrain:hill',
            %w[J23 J25] =>
              'upgrade=cost:60,terrain:hill',
            %w[I18 I20 J19] =>
              'upgrade=cost:80,terrain:mountain',
            %w[G20 G28 G32 G42 H25 I26 J31 K36 M16 M26 N33 O42] =>
              'town=revenue:0',
            ['P39'] =>
              'town=revenue:0;border=edge:2,type:impassable',
            ['O36'] =>
              'town=revenue:0;border=edge:0,type:water,cost:40',
            ['M36'] =>
              'town=revenue:0;stub=edge:0',
            ['H21'] =>
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
            %w[H19 J29 J41 K20 K24 K28 K30 K38 L33 M30 P35 P41] =>
              'city=revenue:0',
            ['I42'] =>
              'city=revenue:0;border=edge:1,type:impassable',
            ['D35'] =>
              'city=revenue:20,loc:center;town=revenue:10,loc:1;path=a:_0,b:_1;future_label=label:S,color:green',
            ['M38'] =>
              'city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;'\
              'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;'\
              'label=L',
            %w[K42 M42] =>
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
            ['C34'] =>
              'city=revenue:yellow_10|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            ['D39'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:3,loc:1.5;path=a:4,b:_0,lanes:2,terminal:1;'\
              'path=a:5,b:_0,lanes:2,terminal:1',
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
            ['E38'] =>
              'path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1;border=edge:3,type:impassable',
            ['F23'] =>
              'city=revenue:yellow_20|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            %w[F25 F27] =>
              'path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1',
            %w[E40 F29 F31] =>
              'path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1',
            ['F33'] =>
              'city=revenue:yellow_20|green_40|brown_30|gray_10,slots:2,loc:4;path=a:1,b:_0;'\
              'path=a:2,b:_0,terminal:1,ignore:1;path=a:5,b:_0',
            ['H17'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_70,slots:2;path=a:0,b:_0,terminal:1',
            ['K16'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1',
            ['Q44'] =>
              'offboard=revenue:yellow_0|green_60|brown_90|gray_120,visit_cost:0;path=a:2,b:_0',
          },
          blue: {
            %w[J43 Q36 Q42 R31] =>
              'junction;path=a:2,b:_0,terminal:1',
            ['F21'] =>
              'junction;path=a:5,b:_0,terminal:1',
          },
        }.freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '',
           '330', '360', '400', '450', '500e', '550e', '600e'],
          ['', '', '', '', '', '', '', '', '',
           '200', '220', '245', '270', '300', '330', '360', '400', '450', '500e', '550e'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500e],
          %w[60 70 80 90 100px 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450],
          %w[50 60 70 80 90px 100 110 120 135 150 165 180 200 220 245 270 300 330],
          %w[45y 50 60 70 80px 90 100 110 120 135 150 165 180 200 220 245],
          %w[40y 45y 50 60 70px 80 90 100 110 120 135 150 165 180],
          %w[35y 40y 45y 50 60px 70 80 90 100 110 120 135],
          %w[30y 35y 40y 45y 50p 60 70 80 90 100],
          %w[25y 30y 35y 40y 45y 50 60 70 80],
          %w[20y 25y 30y 35y 40y 45y 50y 60y],
          %w[15y 20y 25y 30y 35y 40y 45y],
          %w[10y 15y 20y 25y 30y 35y],
          %w[5y 10y 15y 20y 25y],
        ].freeze

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
          '207' => 1,
          '208' => 1,
          '619' => 5,
          '63' => 6,
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 3,
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
              'count' => 2,
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
              'count' => 2,
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

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 14,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 120,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 7,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 2,
            price: 500,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 3,
            price: 600,
            events: [
              {
                'type' => 'full_capitalisation',
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            num: 20,
            price: 750,
            variants: [
              {
                name: 'E',
                distance: 99,
                multiplier: 2,
                price: 1000,
              },
            ],
            events: [
              {
                'type' => 'phase_revenue',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 2,
            price: 0,
          },
          {
            name: 'LP',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: '5P',
            distance: 5,
            num: 1,
            price: 500,
          },
          {
            name: 'P+',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
        ].freeze

        UPGRADE_COST_L_TO_2_PHASE_2 = 70

        def bidbox_start_minor
          return self.class::BIDDING_BOX_START_MINOR_ADV if optional_advanced?

          self.class::BIDDING_BOX_START_MINOR
        end

        def discountable_trains_for(corporation)
          discount_info = []

          upgrade_cost = if @phase.name.to_i < 2
                           self.class::UPGRADE_COST_L_TO_2
                         else
                           self.class::UPGRADE_COST_L_TO_2_PHASE_2
                         end
          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', upgrade_cost]
          end
          discount_info
        end

        def starting_companies
          return self.class::STARTING_COMPANIES_ADVANCED if optional_advanced?
          return self.class::STARTING_COMPANIES_TWOPLAYER if @players.size == 2

          self.class::STARTING_COMPANIES
        end

        def optional_advanced?
          @optional_rules&.include?(:advanced)
        end
      end
    end
  end
end
