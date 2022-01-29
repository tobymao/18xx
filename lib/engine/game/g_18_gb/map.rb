# frozen_string_literal: true

module Engine
  module Game
    module G18GB
      module Map
        TILES = {
          'G02' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:30;city=revenue:0,loc:3.5;path=a:0,b:_0;path=a:_0,b:2;label=XX',
          },
          'G03' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:30;city=revenue:0,loc:1.5;path=a:0,b:_0;path=a:_0,b:3;label=XX',
          },
          'G18' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:0,loc:1.5;path=a:0,b:_0;path=a:_0,b:3;label=OO',
          },
          'G19' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:0,loc:3.5;path=a:0,b:_0;path=a:_0,b:2;label=OO',
          },
          'G39' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
          },
          'G40' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:2,b:_0',
          },
          'G41' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:_0,b:3',
          },
          '3' => 3,
          '4' => 7,
          '7' => 5,
          '8' => 15,
          '9' => 12,
          '58' => 8,
          'G04' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=XX',
          },
          'G05' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:4;label=XX',
          },
          'G06' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;label=XX',
          },
          'G08' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:3.5;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:4;label=XX',
          },
          'G09' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:2.5;path=a:0,b:_0;path=a:_0,b:4;path=a:2,b:_1;path=a:_1,b:3;label=XX',
          },
          'G10' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=XX',
          },
          'G11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:1.5;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:2;label=XX',
          },
          'G21' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:4;label=OO',
          },
          'G22' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;label=OO',
          },
          'G24' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30,loc:3.5;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:4;label=OO',
          },
          'G25' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30,loc:2.5;path=a:0,b:_0;path=a:_0,b:4;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          'G26' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          'G27' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30,loc:1.5;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:2;label=OO',
          },
          'G28' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=OO',
          },
          'G36' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'G37' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'G38' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '23' => 5,
          '24' => 5,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '87' => 5,
          '88' => 4,
          '204' => 4,
          'G13' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,loc:2;city=revenue:60,loc:5;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_1;' \
                      'path=a:5,b:_1;path=a:6,b:_1;label=XX',
          },
          'G14' =>
          {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:60,loc:2;city=revenue:60,loc:5;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:3,b:_1;' \
                      'path=a:5,b:_1;path=a:0,b:_1;label=XX',
          },
          'G15' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'city=revenue:60,loc:2;city=revenue:60,loc:5;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:1,b:_1;' \
                      'path=a:3,b:_1;path=a:5,b:_1;label=XX',
          },
          'G30' =>
          {
            'count' => 7,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=OO',
          },
          'G34' =>
          {
            'count' => 6,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '911' => 4,
          'G31' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=OO',
          },
          'G35' =>
          {
            'count' => 3,
            'color' => 'gray',
            'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0',
          },
          '912' => 2,
          'G32' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'path=a:0,b:1;path=a:2,b:5;path=a:3,b:4,track:dual;label=FT',
          },
          'G33' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'path=a:2,b:4;path=a:2,b:5,track:dual;path=a:5,b:0;label=S',
          },
        }.freeze

        LOCATION_NAMES = {
          'A20' => 'Pembroke',
          'A26' => 'Plymouth',
          'B21' => 'Swansea',
          'B23' => 'Bridgend',
          'C22' => 'Cardiff',
          'D15' => 'Holyhead',
          'D17' => 'Aberystwyth',
          'D21' => 'Merthyr Tydfil',
          'D25' => 'Taunton',
          'E22' => 'Worcester',
          'E24' => 'Bristol',
          'E26' => 'Salisbury',
          'E28' => 'Southampton',
          'F7' => 'Stranraer',
          'F15' => 'Liverpool',
          'F19' => 'Shrewsbury',
          'F27' => 'Basingstoke',
          'G6' => 'Ayr',
          'G18' => 'Crewe',
          'G22' => 'Birmingham',
          'G24' => 'Oxford',
          'G26' => 'Reading',
          'H1' => 'Fort William',
          'H5' => 'Glasgow',
          'H7' => 'Motherwell',
          'H9' => 'Dumfries',
          'H13' => 'Lancaster',
          'H15' => 'Preston',
          'H17' => 'Manchester',
          'H19' => 'Stoke',
          'H23' => 'Coventry',
          'H27' => 'London',
          'I4' => 'Stirling',
          'I6' => 'Coatbridge',
          'I10' => 'Carlisle',
          'I16' => 'Leeds',
          'I18' => 'Sheffield',
          'I20' => 'Derby',
          'I22' => 'Leicester',
          'J1' => 'Inverness',
          'J3' => 'Perth',
          'J7' => 'Edinburgh',
          'J13' => 'Darlington',
          'J15' => 'York',
          'J17' => 'Doncaster',
          'J21' => 'Lincoln',
          'J23' => 'Peterborough',
          'J27' => 'Colchester',
          'K4' => 'Dundee',
          'K8' => 'Berwick',
          'K12' => 'Newcastle',
          'K14' => 'Middlesbrough',
          'K18' => 'Hull',
          'K26' => 'Ipswich',
          'K28' => 'Harwich',
          'L1' => 'Aberdeen',
          'L19' => 'Grimsby',
          'L23' => 'Norwich',
          'M2' => 'Arbroath',
        }.freeze

        HEXES = {
          white: {
            %w[B19 B25 C26 D27 G8 G16 G20 G28 H21 I24 I26 I28 J19 J25 K2 K20 K24 L3] => '',
            ['C18'] => 'border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['C20'] => 'border=edge:3,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['D19'] => 'border=edge:2,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['E18'] => 'border=edge:1,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['E20'] => 'border=edge:1,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[F17 F25 H25] => 'border=edge:1,type:mountain,cost:50',
            %w[F21 F23] => 'border=edge:2,type:mountain,cost:50',
            ['K16'] => 'border=edge:3,type:mountain,cost:50',
            %w[H3 H11 I8] => 'border=edge:5,type:mountain,cost:50',
            ['J9'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                      'border=edge:2,type:mountain,cost:50',
            ['J11'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['K10'] => 'border=edge:1,type:mountain,cost:50',
            ['I14'] => 'border=edge:1,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50',
            ['I12'] => 'border=edge:0,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:4,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[B21 G6 I20 J3 J15 K4 K26] => 'city=revenue:0',
            %w[E26 H19 I10] => 'city=revenue:0;border=edge:4,type:mountain,cost:50',
            ['K14'] => 'city=revenue:0;border=edge:0,type:mountain,cost:50',
            %w[G22 H5 H17 I16] => 'city=revenue:0;city=revenue:0;label=XX',
            %w[C22 E24 I22 J7 K12] => 'city=revenue:0;city=revenue:0;label=OO',
            ['I18'] => 'city=revenue:0;city=revenue:0;border=edge:1,type:mountain,cost:50;label=OO',
            ['H15'] => 'city=revenue:0;city=revenue:0;border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'label=OO',
            %w[D25 F19 F27 G18 G24 H7 H23 I6 J17 J21 J23 J27 K8] => 'town=revenue:0',
            ['D21'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'border=edge:5,type:mountain,cost:50',
            ['E22'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['G26'] => 'town=revenue:0;border=edge:4,type:mountain,cost:50',
            ['H13'] => 'town=revenue:0;border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['J13'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:3,type:mountain,cost:50',
            ['I4'] => 'border=edge:2,type:mountain,cost:50;town=revenue:0',
          },
          red: {
            ['A20'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:5,b:_0;label=W',
            ['A26'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;label=SW',
            ['D15'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:5,b:_0;label=W',
            ['D17'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:1,b:_0;path=a:5,b:_0;label=W',
            ['E28'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
            ['F7'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:4,b:_0;path=a:5,b:_0;label=W',
            ['F15'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;path=a:5,b:_0',
            ['H1'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;label=N',
            ['H27'] => 'offboard=revenue:yellow_30|green_40|blue_50|brown_60|gray_70;path=a:1,b:_0;path=a:2,b:_0;' \
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SE',
            ['J1'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:0,b:_0;label=N',
            ['K18'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:3,b:_0;path=a:5,b:0',
            ['K28'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:2,b:_0;path=a:3,b:_0;label=SE',
            ['L1'] => 'offboard=revenue:yellow_30|blue_40|gray_50;path=a:0,b:_0;path=a:5,b:_0;label=N',
            ['L19'] => 'offboard=revenue:yellow_20|blue_20|gray_20;path=a:2,b:_0',
            ['L23'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;path=a:1,b:_0;label=E',
          },
          gray: {
            ['B23'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['E16'] => 'path=a:2,b:5',
            ['G4'] => 'path=a:4,b:5;path=a:5,b:0',
            ['G14'] => 'path=a:1,b:5;path=a:4,b:5',
            ['H9'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;path=a:3,b:5',
            ['K6'] => 'path=a:0,b:1;path=a:1,b:2',
            ['K22'] => 'path=a:1,b:3',
            ['L5'] => 'path=a:2,b:3',
            %w[L11 L13] => 'path=a:1,b:2',
            ['L25'] => 'path=a:1,b:2;path=a:1,b:3',
            ['M2'] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
          },
          green: {
            ['D23'] => 'path=a:2,b:4;path=a:5,b:0;upgrade=cost:50,terrain:river;label=S',
            ['J5'] => 'path=a:1,b:2;upgrade=cost:50,terrain:river;label=FT',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
