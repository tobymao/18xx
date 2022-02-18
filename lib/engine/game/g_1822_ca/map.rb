# frozen_string_literal: true

module Engine
  module Game
    module G1822CA
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
          'A7' => 'Prince Rupert',
          'A9' => 'Kitimat',
          'C9' => 'Fraser Lake',
          'C15' => 'Vancouver',
          'C17' => 'Seattle',
          'D10' => 'Prince George',
          'D12' => 'Williams Lake',
          'D14' => 'Kamloops',
          'D16' => 'Chilliwack',
          'E11' => 'Yellowhead Pass',
          'F8' => 'Peace River',
          'F10' => 'Slave Lake',
          'F16' => 'Crowsnest Pass',
          'G11' => 'Edmonton',
          'G13' => 'Red Deer & Olds',
          'G15' => 'Calgary',
          'G17' => 'Lethbridge',
          'H8' => 'Fort McMurray',
          'H16' => 'Medicine Hat',
          'I11' => 'Lloydminster',
          'I15' => 'Kindersley & Swift Current',
          'I17' => 'Eastend',
          'J12' => 'Saskatoon',
          'J16' => 'Moose Jaw',
          'K9' => 'La Ronge',
          'K11' => 'Prince Albert',
          'K13' => 'Yorktown',
          'K15' => 'Regina',
          'K17' => 'Estevan',
          'L8' => 'Lynn Lake',
          'L10' => 'Flin Flon',
          'L16' => 'Carlyle',
          'M9' => 'Thompson',
          'M17' => 'Brandon',
          'N6' => 'Churchill',
          'N16' => 'Winnipeg',
          'O9' => 'Gillam',
          'O15' => 'Kenora',
          'P14' => 'Sioux Lookout',
          'P18' => 'Duluth',
          'Q7' => 'Fort Severn',
          'R16' => 'Thunder Bay',
          'S15' => 'Wawa',
          'U11' => 'Hearst',
          'V18' => 'Sault Ste Marie',
          'W9' => 'Cochrane',
          'X12' => 'Timmins',
          'Y15' => 'Sudbury',
          'Y17' => 'Espanola',
          'Y29' => 'Detroit',
          'Z10' => 'Rouyn-Noranda',
          'Z26' => 'Sarnia',
          'Z28' => 'Windsor',
          'AA9' => 'Val d\'Or',
          'AA15' => 'North Bay',
          'AA25' => 'London',
          'AB22' => 'Mississauga & Burlington',
          'AB24' => 'Hamilton',
          'AC21' => 'Toronto',
          'AC23' => 'Buffalo',
          'AD18' => 'Belleville',
          'AD20' => 'Peterborough',
          'AE15' => 'Bytown (Ottawa)',
          'AE17' => 'Kingston',
          'AF12' => 'Montreal',
          'AF16' => 'Prescott',
          'AG3' => 'Chicoutimi',
          'AG9' => 'Trois-Rivières',
          'AG13' => 'Saint Jean & La Prairie',
          'AG17' => 'New York',
          'AH8' => 'Québec',
          'AH10' => 'Victoriaville & Drummondville',
          'AH12' => 'Sherbrooke',
          'AI15' => 'Boston',
          'AK3' => 'Edmunston',
          'AK5' => 'Grand Falls',
          'AL2' => 'Chatham',
          'AL12' => 'Portland',
          'AM5' => 'Fredericton',
          'AM9' => 'Bangor',
          'AN6' => 'Saint John',
          'AO3' => 'Moncton',
          'AO9' => 'Yarmouth',
          'AP4' => 'Halifax',
          'AP6' => 'Lunenburg',
        }.freeze

        HEXES = {
          white: {
            %w[B6 B8 C11 D6 E7 E15 F6 F12 G7 G9 H6 H10 H12 H14 I7 I9 I13 J6 J8 J10 J14 L6 L12 M7 M11 N8 N10 N18
               O11 O17 P10 P12 P16 Q11 Q13 Q15 Q17 R12 R14 S13 U9 U13 U15 U17 V8 V10 V12 V14 V16 W7 W11 W13 W15
               W17 W19 X8 X10 X14 X16 X18 Y7 Y9 Y11 Y13 Z8 Z12 Z16 Z18 Z22 Z24 AA7 AA11 AA17 AA19 AA21 AA23 AA27 AB8
               AB10 AB12 AB18 AB20 AC7 AC9 AC11 AC17 AC19 AD8 AD10 AD12 AE7 AE9 AE11 AE19 AF6 AF8 AG5 AG7 AH14 AI11
               AI13 AJ2 AJ4 AJ6 AJ8 AJ10 AJ12 AK7 AK9 AK11 AL4 AL6 AL8 AL10 AM3 AM7 AN2 AP2 AP8] =>
              '',
            %w[B10 B14 C7] =>
              'upgrade=cost:40,terrain:hill',
            %w[B12 C13 D8] =>
              'upgrade=cost:60,terrain:mountain',
            %w[E9] =>
              'upgrade=cost:80,terrain:mountain',
            %w[E13 F14] =>
              'upgrade=cost:120,terrain:mountain',
            ['E11'] =>
              'upgrade=cost:120,terrain:mountain;label=YP',
            ['F16'] =>
              'upgrade=cost:120,terrain:mountain;label=CP',
            ['K7'] =>
              'border=edge:5,type:impassable',
            %w[L14 Z14] =>
              'border=edge:4,type:impassable',
            ['M13'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:4,type:impassable',
            ['M15'] =>
              'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['N12'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['N14'] =>
              'border=edge:1,type:impassable;border=edge:3,type:impassable;border=edge:4,type:impassable',
            %w[O7 P8 Q9 R8 R10 S9 S11] =>
              'upgrade=cost:20,terrain:swamp',
            ['O13'] =>
              'border=edge:1,type:impassable',
            ['AA13'] =>
              'border=edge:0,type:water,cost:20;border=edge:1,type:impassable',
            ['AB14'] =>
              'border=edge:0,type:impassable;border=edge:1,type:water,cost:20;border=edge:5,type:impassable',
            ['AB16'] =>
              'border=edge:3,type:impassable',
            ['AC13'] =>
              'border=edge:0,type:impassable',
            ['AC15'] =>
              'border=edge:2,type:impassable;border=edge:3,type:impassable;border=edge:4,type:water,cost:20',
            ['AD14'] =>
              'border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['AD16'] =>
              'border=edge:3,type:water,cost:20',
            ['AE13'] =>
              'border=edge:0,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['AF10'] =>
              'border=edge:5,type:water,cost:20',
            ['AF14'] =>
              'border=edge:2,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['AG11'] =>
              'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20',
            ['AG15'] =>
              'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            %w[AH2 AH4 AH6] =>
              'border=edge:4,type:impassable;border=edge:5,type:impassable',
            %w[AI3 AI5] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['AI7'] =>
              'border=edge:1,type:water,cost:40;border=edge:2,type:impassable',
            ['AI9'] =>
              'border=edge:2,type:water,cost:40',
            ['AN4'] =>
              'border=edge:5,type:impassable',
            ['AO5'] =>
              'border=edge:1,type:impassable;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['AO7'] =>
              'border=edge:2,type:impassable',

            %w[C9 D12 D16 F8 F10 H8 K9 L10 M9 O9 O15
               P14 Q7 S15 U11 W9 Y17 Z10 Z26 AA9 AD18 AE17 AG3 AK5 AL2 AM5 AP6] =>
              'town=revenue:0',
            ['A9'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill',
            %w[G13 I15] =>
              'town=revenue:0;town=revenue:0;icon=image:1822_ca/elevator,sticky:1',
            %w[H16 I11 I17 J16 K13 K17 L16 M17] =>
              'town=revenue:0;icon=image:1822_ca/elevator,sticky:1',
            ['L8'] =>
              'town=revenue:0;border=edge:2,type:impassable',
            ['AB22'] =>
              'town=revenue:0;town=revenue:0;border=edge:5,type:impassable',
            ['AF16'] =>
              'town=revenue:0;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['AG9'] =>
              'town=revenue:0;border=edge:0,type:water,cost:20;border=edge:5,type:water,cost:40',
            ['AH10'] =>
              'town=revenue:0;town=revenue:0;border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40',

            %w[D10 D14 G11 G17 J12 K11 X12 AD20 AH12 AK3 AM9 AO9] =>
              'city=revenue:0',
            %w[G15 K15 V18 Y15 AA25] =>
              'city=revenue:0;label=Y',
            %w[A7 R16] =>
              'city=revenue:0;label=Y;icon=image:1822_ca/port,sticky:1',
            ['N6'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;icon=image:1822_ca/port,sticky:1',
            ['N16'] =>
              'city=revenue:20,slots:2;city=revenue:20;city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;'\
              'path=a:3,b:_1;path=a:4,b:_2;path=a:5,b:_3;upgrade=cost:20;label=W',
            ['Z28'] =>
              'city=revenue:0;label=A',
            ['AA15'] =>
              'city=revenue:0;border=edge:3,type:water,cost:20;border=edge:4,type:water,cost:20',
            ['AB24'] =>
              'city=revenue:0;label=B',
            ['AC21'] =>
              'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:3,b:_1;upgrade=cost:20;label=T;'\
              'border=edge:0,type:impassable',
            ['AE15'] =>
              'city=revenue:10;city=revenue:10;path=a:1,b:_0;path=a:5,b:_1;'\
              'upgrade=cost:20;label=O;border=edge:2,type:water,cost:20;'\
              'border=edge:3,type:water,cost:20',
            ['AF12'] =>
              'city=revenue:20,slots:2;city=revenue:20;path=a:0,b:_0;upgrade=cost:20;'\
              'label=M;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['AG13'] =>
              'city=revenue:20,loc:center;town=revenue:10,loc:4;path=a:_0,b:_1;'\
              'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            ['AH8'] =>
              'city=revenue:10;city=revenue:0,loc:3.5;city=revenue:0,loc:5;label=Q;path=a:1,b:_0;'\
              'border=edge:0,type:water,cost:40;border=edge:4,type:water,cost:40;'\
              'border=edge:5,type:water,cost:40',
            ['AN6'] =>
              'city=revenue:0;border=edge:4,type:impassable;border=edge:5,type:impassable;label=L',
            ['AO3'] =>
              'city=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable;label=L',
          },
          gray: {
            ['C15'] =>
              'city=revenue:yellow_20|green_30|brown_50|gray_60,slots:4;path=a:0,b:_0;'\
              'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:1822_ca/port,sticky:1',
            ['C17'] =>
              'city=revenue:yellow_20|green_30|brown_50|gray_60,slots:2;'\
              'path=a:3,b:_0;path=a:4,b:_0',
            ['P18'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_40,slots:3;'\
              'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[T10 T12 T14] =>
              'junction;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['Y29'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
              'path=a:3,b:_0;path=a:4,b:_0,lanes:2',
            ['AC23'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
              'path=a:1,b:_0,lanes:2;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['AG17'] =>
              'city=revenue:yellow_30|green_40|brown_60|gray_50,slots:2;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;border=edge:2,type:water,cost:20',
            %w[AI15 AL12] =>
              'city=revenue:yellow_30|green_40|brown_60|gray_50,slots:2;'\
              'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['AO1'] =>
              'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['AP4'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
              'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;border=edge:2,type:impassable',
          },
          blue: {
            %w[A5 AK1] =>
              'junction;path=a:0,b:_0,terminal:1',
            ['M5'] =>
              'junction;path=a:5,b:_0,terminal:1',
            %w[S17 AB26 AN10 AP10] =>
              'junction;path=a:2,b:_0,terminal:1',
            %w[R18 V20 AM11 AO11] =>
              'junction;path=a:3,b:_0,terminal:1',
            %w[F18 U19] =>
              'junction;path=a:4,b:_0,terminal:1',
            ['AN8'] =>
              'junction;path=a:1,b:_0,terminal:1;junction;path=a:3,b:_0,terminal:1',
            %w[Q19 R20 S21 T22 U23 V24 W25 X26] =>
              'path=a:2,b:5',
            ['Y27'] =>
              'path=a:0,b:2',
          },
        }.freeze
      end
    end
  end
end
