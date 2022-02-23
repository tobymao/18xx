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
          '3' => 'unlimited',
          '4' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '58' => 'unlimited',
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
          'G32' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'path=a:0,b:3;path=a:1,b:2;path=a:4,b:5,track:dual;icon=image:18_gb/plus_40;label=FT',
          },
          'G33' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'path=a:2,b:4;path=a:2,b:5,track:dual;path=a:5,b:0;icon=image:18_gb/plus_30;label=S',
          },
        }.freeze
        GRAY_TILES = {
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
        }.freeze

        LOCATION_NAMES = {
          'a19' => 'Pembroke',
          'a25' => 'Plymouth',
          'A20' => 'Swansea',
          'A22' => 'Bridgend',
          'B21' => 'Cardiff',
          'C14' => 'Holyhead',
          'C16' => 'Aberystwyth',
          'C20' => 'Merthyr Tydfil',
          'C24' => 'Taunton',
          'D21' => 'Worcester',
          'D23' => 'Bristol',
          'D25' => 'Salisbury',
          'D27' => 'Southampton',
          'E6' => 'Stranraer',
          'E14' => 'Liverpool',
          'E18' => 'Shrewsbury',
          'E26' => 'Basingstoke',
          'F5' => 'Ayr',
          'F17' => 'Crewe',
          'F21' => 'Birmingham',
          'F23' => 'Oxford',
          'F25' => 'Reading',
          'G0' => 'Fort William',
          'G4' => 'Glasgow',
          'G6' => 'Motherwell',
          'G8' => 'Dumfries',
          'G12' => 'Lancaster',
          'G14' => 'Preston',
          'G16' => 'Manchester',
          'G18' => 'Stoke',
          'G22' => 'Coventry',
          'G26' => 'London',
          'H3' => 'Stirling',
          'H5' => 'Coatbridge',
          'H9' => 'Carlisle',
          'H15' => 'Leeds',
          'H17' => 'Sheffield',
          'H19' => 'Derby',
          'H21' => 'Leicester',
          'I0' => 'Inverness',
          'I2' => 'Perth',
          'I6' => 'Edinburgh',
          'I12' => 'Darlington',
          'I14' => 'York',
          'I16' => 'Doncaster',
          'I20' => 'Lincoln',
          'I22' => 'Peterborough',
          'I26' => 'Colchester',
          'J3' => 'Dundee',
          'J7' => 'Berwick',
          'J11' => 'Newcastle',
          'J13' => 'Middlesbrough',
          'J25' => 'Ipswich',
          'J27' => 'Harwich',
          'K0' => 'Aberdeen',
          'K16' => 'Hull',
          'K18' => 'Grimsby',
          'K22' => 'Norwich',
          'L1' => 'Arbroath',
        }.freeze

        HEXES = {
          white: {
            %w[A18 A24 B25 C26 F7 F15 F19 F27 G20 H23 H25 H27 I18 I24 J1 J19 J23 K2] => '',
            ['B17'] => 'border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['B19'] => 'border=edge:3,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['C18'] => 'border=edge:2,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['D17'] => 'border=edge:1,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['D19'] => 'border=edge:1,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[E16 E24 G24] => 'border=edge:1,type:mountain,cost:50',
            %w[E20 E22] => 'border=edge:2,type:mountain,cost:50',
            ['J15'] => 'border=edge:3,type:mountain,cost:50',
            %w[G2 G10 H7] => 'border=edge:5,type:mountain,cost:50',
            ['I8'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                      'border=edge:2,type:mountain,cost:50',
            ['I10'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['J9'] => 'border=edge:1,type:mountain,cost:50',
            ['H13'] => 'border=edge:1,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50',
            ['H11'] => 'border=edge:0,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:4,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[A20 F5 H19 I2 I14 J3 J25] => 'city=revenue:0',
            %w[D25 G18 H9] => 'city=revenue:0;border=edge:4,type:mountain,cost:50',
            ['J13'] => 'city=revenue:0;border=edge:0,type:mountain,cost:50',
            %w[F21 G4 G16 H15] => 'city=revenue:0;city=revenue:0;label=XX',
            %w[B21 D23 H21 I6 J11] => 'city=revenue:0;city=revenue:0;label=OO',
            ['H17'] => 'city=revenue:0;city=revenue:0;border=edge:1,type:mountain,cost:50;label=OO',
            ['G14'] => 'city=revenue:0;city=revenue:0;border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'label=OO',
            %w[C24 E18 E26 F17 F23 G6 G22 H5 I16 I20 I22 I26 J7] => 'town=revenue:0',
            ['C20'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'border=edge:5,type:mountain,cost:50',
            ['D21'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['F25'] => 'town=revenue:0;border=edge:4,type:mountain,cost:50',
            ['G12'] => 'town=revenue:0;border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['I12'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:3,type:mountain,cost:50',
            ['H3'] => 'border=edge:2,type:mountain,cost:50;town=revenue:0',
          },
          red: {
            ['a19'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:5,b:_0;icon=image:18_gb/west',
            ['a25'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;icon=image:18_gb/south;icon=image:18_gb/west',
            ['C14'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:5,b:_0;icon=image:18_gb/west',
            ['C16'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:1,b:_0;path=a:5,b:_0;icon=image:18_gb/west',
            ['D27'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                       'icon=image:18_gb/south',
            ['E6'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_gb/west',
            ['E14'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;path=a:5,b:_0',
            ['G0'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;icon=image:18_gb/north',
            ['G26'] => 'offboard=revenue:yellow_30|green_40|blue_50|brown_60|gray_70;path=a:1,b:_0;path=a:2,b:_0;' \
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_gb/south;icon=image:18_gb/east',
            ['I0'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:0,b:_0;icon=image:18_gb/north',
            ['J17'] => 'offboard=revenue:yellow_20|blue_40|gray_50,hide:1;path=a:3,b:_0;'\
                       'offboard=revenue:yellow_20|blue_20|gray_20,hide:1;path=a:0,b:_1;'\
                       'border=edge:5;border=edge:4;partition=a:2,b:5,type:divider',
            ['J27'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:2,b:_0;path=a:3,b:_0;icon=image:18_gb/south;' \
                       'icon=image:18_gb/east',
            ['K0'] => 'offboard=revenue:yellow_30|blue_40|gray_50;path=a:0,b:_0;path=a:5,b:_0;icon=image:18_gb/north;' \
                      'icon=image:18_gb/east',
            ['K16'] => 'offboard=revenue:yellow_20|blue_40|gray_50;border=edge:1',
            ['K18'] => 'offboard=revenue:yellow_20|blue_20|gray_20;border=edge:2',
            ['K22'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;path=a:1,b:_0;icon=image:18_gb/east',
          },
          gray: {
            ['A22'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['B23'] => '',
            ['D15'] => 'path=a:2,b:5',
            ['F3'] => 'path=a:4,b:5;path=a:5,b:0',
            ['F13'] => 'path=a:1,b:5;path=a:4,b:5',
            ['G8'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;path=a:3,b:5',
            ['J5'] => 'path=a:0,b:1;path=a:1,b:2',
            ['J21'] => 'path=a:1,b:3',
            ['K4'] => 'path=a:2,b:3',
            %w[K10 K12] => 'path=a:1,b:2',
            ['K24'] => 'path=a:1,b:2;path=a:1,b:3',
            ['L1'] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
          },
          blue: {
            ['C22'] => 'path=a:2,b:4;path=a:5,b:0;upgrade=cost:50,terrain:river;label=S',
            ['I4'] => 'path=a:1,b:2;upgrade=cost:50,terrain:river;label=FT',
          },
        }.freeze

        HEXES_2P_NW = {
          white: {
            %w[F7 F15 F19 F27 G20 H23 H25 H27 I18 I24 J1 J19 J23 K2] => '',
            ['D17'] => 'border=edge:4,type:mountain,cost:50',
            %w[E16 E24 G24] => 'border=edge:1,type:mountain,cost:50',
            %w[E20 E22] => 'border=edge:2,type:mountain,cost:50',
            ['J15'] => 'border=edge:3,type:mountain,cost:50',
            %w[D19 G2 G10 H7] => 'border=edge:5,type:mountain,cost:50',
            ['I8'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                      'border=edge:2,type:mountain,cost:50',
            ['I10'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['J9'] => 'border=edge:1,type:mountain,cost:50',
            ['H13'] => 'border=edge:1,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50',
            ['H11'] => 'border=edge:0,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:4,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[F5 H19 I2 I14 J3 J25] => 'city=revenue:0',
            %w[G18 H9] => 'city=revenue:0;border=edge:4,type:mountain,cost:50',
            ['J13'] => 'city=revenue:0;border=edge:0,type:mountain,cost:50',
            %w[F21 G4 G16 H15] => 'city=revenue:0;city=revenue:0;label=XX',
            %w[H21 I6 J11] => 'city=revenue:0;city=revenue:0;label=OO',
            ['H17'] => 'city=revenue:0;city=revenue:0;border=edge:1,type:mountain,cost:50;label=OO',
            ['G14'] => 'city=revenue:0;city=revenue:0;border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'label=OO',
            %w[E18 E26 F17 F23 G6 G22 H5 I16 I20 I22 I26 J7] => 'town=revenue:0',
            ['D21'] => 'town=revenue:0;border=edge:5,type:mountain,cost:50',
            ['F25'] => 'town=revenue:0;border=edge:4,type:mountain,cost:50',
            ['G12'] => 'town=revenue:0;border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['I12'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:3,type:mountain,cost:50',
            ['H3'] => 'border=edge:2,type:mountain,cost:50;town=revenue:0',
          },
          red: {
            ['D23'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['D25'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:4,b:_0;path=a:5,b:_0;' \
                       'border=edge:4,type:mountain,cost:50',
            ['D27'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:4,b:_0;icon=image:18_gb/south',
            ['E6'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_gb/west',
            ['E14'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;path=a:5,b:_0',
            ['G0'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;icon=image:18_gb/north',
            ['G26'] => 'offboard=revenue:yellow_30|green_40|blue_50|brown_60|gray_70;path=a:1,b:_0;path=a:2,b:_0;' \
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_gb/south;icon=image:18_gb/east',
            ['I0'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:0,b:_0;icon=image:18_gb/north',
            ['J17'] => 'offboard=revenue:yellow_20|blue_40|gray_50,hide:1;path=a:3,b:_0;'\
                       'offboard=revenue:yellow_20|blue_20|gray_20,hide:1;path=a:0,b:_1;'\
                       'border=edge:5;border=edge:4;partition=a:2,b:5,type:divider',
            ['J27'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:2,b:_0;path=a:3,b:_0;icon=image:18_gb/south;' \
                       'icon=image:18_gb/east',
            ['K0'] => 'offboard=revenue:yellow_30|blue_40|gray_50;path=a:0,b:_0;path=a:5,b:_0;icon=image:18_gb/north;' \
                      'icon=image:18_gb/east',
            ['K16'] => 'offboard=revenue:yellow_20|blue_40|gray_50;border=edge:1',
            ['K18'] => 'offboard=revenue:yellow_20|blue_20|gray_20;border=edge:2',
            ['K22'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;path=a:1,b:_0;icon=image:18_gb/east',
          },
          gray: {
            ['F3'] => 'path=a:4,b:5;path=a:5,b:0',
            ['F13'] => 'path=a:1,b:5;path=a:4,b:5',
            ['G8'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;path=a:3,b:5',
            ['J5'] => 'path=a:0,b:1;path=a:1,b:2',
            ['J21'] => 'path=a:1,b:3',
            ['K4'] => 'path=a:2,b:3',
            %w[K10 K12] => 'path=a:1,b:2',
            ['K24'] => 'path=a:1,b:2;path=a:1,b:3',
            ['L1'] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
          },
          blue: {
            ['I4'] => 'path=a:1,b:2;upgrade=cost:50,terrain:river;label=FT',
          },
        }.freeze

        HEXES_2P_EW = {
          white: {
            %w[A18 A24 B25 C26 F15 F19 F27 G20 H23 H25 H27 I18 I24 J19 J23] => '',
            ['B17'] => 'border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['B19'] => 'border=edge:3,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['C18'] => 'border=edge:2,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['D17'] => 'border=edge:1,type:mountain,cost:50;border=edge:4,type:mountain,cost:50',
            ['D19'] => 'border=edge:1,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[E16 E24 G24] => 'border=edge:1,type:mountain,cost:50',
            %w[E20 E22] => 'border=edge:2,type:mountain,cost:50',
            ['J15'] => 'border=edge:3,type:mountain,cost:50',
            ['G10'] => 'border=edge:5,type:mountain,cost:50',
            ['H13'] => 'border=edge:1,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:3,type:mountain,cost:50',
            ['H11'] => 'border=edge:0,type:mountain,cost:50;border=edge:2,type:mountain,cost:50;' \
                       'border=edge:4,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            %w[A20 H19 I14 J25] => 'city=revenue:0',
            %w[D25 G18] => 'city=revenue:0;border=edge:4,type:mountain,cost:50',
            ['J13'] => 'city=revenue:0;border=edge:0,type:mountain,cost:50',
            %w[F21 G16 H15] => 'city=revenue:0;city=revenue:0;label=XX',
            %w[B21 D23 H21] => 'city=revenue:0;city=revenue:0;label=OO',
            ['H17'] => 'city=revenue:0;city=revenue:0;border=edge:1,type:mountain,cost:50;label=OO',
            ['G14'] => 'city=revenue:0;city=revenue:0;border=edge:3,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'label=OO',
            %w[C24 E18 E26 F17 F23 G22 I16 I20 I22 I26] => 'town=revenue:0',
            ['C20'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:4,type:mountain,cost:50;' \
                       'border=edge:5,type:mountain,cost:50',
            ['D21'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['F25'] => 'town=revenue:0;border=edge:4,type:mountain,cost:50',
            ['G12'] => 'town=revenue:0;border=edge:0,type:mountain,cost:50;border=edge:5,type:mountain,cost:50',
            ['I12'] => 'town=revenue:0;border=edge:2,type:mountain,cost:50;border=edge:3,type:mountain,cost:50',
          },
          red: {
            ['a19'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:5,b:_0;icon=image:18_gb/west',
            ['a25'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;icon=image:18_gb/south;icon=image:18_gb/west',
            ['C14'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:5,b:_0;icon=image:18_gb/west',
            ['C16'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:1,b:_0;path=a:5,b:_0;icon=image:18_gb/west',
            ['D27'] => 'offboard=revenue:yellow_10|blue_30|gray_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                       'icon=image:18_gb/south',
            ['E14'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:4,b:_0;path=a:5,b:_0',
            ['G26'] => 'offboard=revenue:yellow_30|green_40|blue_50|brown_60|gray_70;path=a:1,b:_0;path=a:2,b:_0;' \
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_gb/south;icon=image:18_gb/east',
            ['H9'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;path=a:1,b:_0;icon=image:18_gb/north',
            ['J11'] => 'offboard=revenue:yellow_20|blue_40|gray_50;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;' \
                       'icon=image:18_gb/north',
            ['J17'] => 'offboard=revenue:yellow_20|blue_40|gray_50,hide:1;path=a:3,b:_0;'\
                       'offboard=revenue:yellow_20|blue_20|gray_20,hide:1;path=a:0,b:_1;'\
                       'border=edge:5;border=edge:4;partition=a:2,b:5,type:divider',
            ['J27'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:2,b:_0;path=a:3,b:_0;icon=image:18_gb/south;' \
                       'icon=image:18_gb/east',
            ['K16'] => 'offboard=revenue:yellow_20|blue_40|gray_50;border=edge:1',
            ['K18'] => 'offboard=revenue:yellow_20|blue_20|gray_20;border=edge:2',
            ['K22'] => 'offboard=revenue:yellow_10|blue_20|gray_30;path=a:0,b:_0;path=a:1,b:_0;icon=image:18_gb/east',
          },
          gray: {
            ['A22'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['B23'] => '',
            ['D15'] => 'path=a:2,b:5',
            ['F13'] => 'path=a:1,b:5;path=a:4,b:5',
            ['I10'] => 'border=edge:0,type:mountain,cost:50;border=edge:1,type:mountain,cost:50;' \
                       'junction;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['J21'] => 'path=a:1,b:3',
            ['K12'] => 'path=a:1,b:2',
            ['K24'] => 'path=a:1,b:2;path=a:1,b:3',
          },
          blue: {
            ['C22'] => 'path=a:2,b:4;path=a:5,b:0;upgrade=cost:50,terrain:river;label=S',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
