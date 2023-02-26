# frozen_string_literal: true

module Engine
  module Game
    module G1867
      module Map
        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 2,
          '15' => 4,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 2,
          '22' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 2,
          '58' => 4,
          '63' => 3,
          '70' => 2,
          '87' => 2,
          '88' => 2,
          '120' => 1,
          '122' => 1,
          '124' => 1,
          '201' => 3,
          '202' => 3,
          '204' => 2,
          '207' => 5,
          '208' => 2,
          '611' => 3,
          '619' => 2,
          '621' => 2,
          '622' => 2,
          '623' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '637' => 1,
          '639' => 1,
          '801' => 2,
          '911' => 3,
          'X1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;path=a:_2,b:5;label=M',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:5;path=a:2,b:_2;'\
                      'path=a:_2,b:4;label=M',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:4;path=a:1,b:_1;path=a:_1,b:2;path=a:3,b:_2;'\
                      'path=a:_2,b:5;label=M',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:3;'\
                      'path=a:1,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:5;label=M',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;city=revenue:70;path=a:0,b:_1;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;city=revenue:70;path=a:0,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=M',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;city=revenue:70;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_1;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_0;label=M',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
        }.freeze

        LOCATION_NAMES = {
          'D2' => 'Timmins ($80 if includes T/M/Q)',
          'D8' => 'Sudbury',
          'F8' => 'North Bay',
          'E13' => 'Barrie',
          'E15' => 'Guelph',
          'E17' => 'Hamilton',
          'D16' => 'Berlin',
          'C17' => 'London',
          'G15' => 'Peterborough',
          'I15' => 'Kingston',
          'J12' => 'Ottawa',
          'M9' => 'Trois-Rivières',
          'O7' => 'Quebec',
          'N12' => 'Sherbrooke',
          'C15' => 'Goderich',
          'B18' => 'Sarnia',
          'H14' => 'Belleville',
          'H10' => 'Pembroke',
          'K13' => 'Cornwall',
          'L10' => 'St. Jerome',
          'M13' => 'Granby',
          'L12' => 'Montreal',
          'F16' => 'Toronto',
          'A7' => 'Sault Ste. Marie',
          'F18' => 'Buffalo',
          'M15' => 'New England',
          'O13' => 'Maine',
          'P8' => 'Maritime Provinces',
          'A19' => 'Detroit',
        }.freeze

        HEXES = {
          white: {
            %w[B6 B8 C5 C7 C19 D4 D6 D14 E3 E5 E7 E9 F2 F4 F6 F10 F12 F14 G3 G5
               G7 G9 G11 G13 H4 H6 H8 H12 I5 I7 I9 I11 I13 J6 J8 J10 J14 K5 K7 K9
               L6 L8 M5 M7 N6 O11] => '',
            ['D18'] => 'border=edge:5,type:impassable',
            ['C9'] => 'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['D10'] => 'border=edge:2,type:impassable;border=edge:1,type:impassable;'\
                       'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['E11'] => 'border=edge:2,type:impassable;border=edge:1,type:impassable',
            ['C11'] => 'border=edge:0,type:impassable;border=edge:3,type:impassable;'\
                       'border=edge:4,type:impassable',
            ['D12'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['C13'] => 'border=edge:3,type:impassable',
            ['K11'] => 'upgrade=cost:20,terrain:water',
            ['N8'] => 'border=edge:0,type:water,cost:80;border=edge:5,type:water,cost:80',
            %w[N10 M11] =>
                   'border=edge:2,type:water,cost:80;border=edge:3,type:water,cost:80',
            ['O9'] => 'border=edge:2,type:water,cost:80',
            ['M9'] =>
                   'city=revenue:0;border=edge:5,type:water,cost:80;border=edge:0,type:water,cost:80',
            %w[D8 F8 E13 E15 C17 I15 N12] => 'city=revenue:0',
            ['G15'] => 'city=revenue:0;stub=edge:1',
            %w[E17 D16 O7] => 'city=revenue:0;label=Y',
            ['J12'] => 'city=revenue:0;label=Y;future_label=label:O,color:gray;upgrade=cost:20,terrain:water',
            ['L10'] => 'town=revenue:0;border=edge:5,type:water,cost:80;stub=edge:0',
            ['H14'] => 'town=revenue:0;border=edge:0,type:impassable',
            %w[C15 B18 H10 M13] => 'town=revenue:0',
            ['K13'] => 'town=revenue:0;stub=edge:4',
          },
          gray: {
            ['D2'] => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;border=edge:1;border=edge:4',
            ['C3'] => 'path=a:0,b:4;border=edge:4',
            ['E1'] => 'path=a:1,b:5;border=edge:1',
            ['B16'] => 'path=a:0,b:5',
            ['L14'] => 'path=a:2,b:3',
          },
          yellow: {
            ['L12'] => 'city=revenue:40;city=revenue:40;city=revenue:40,loc:5;path=a:1,b:_0;'\
                       'path=a:3,b:_1;label=M;upgrade=cost:20,terrain:water',
            ['F16'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=T',
          },
          red: {
            ['A7'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:4,b:_0;path=a:5,b:_0',
            ['F18'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0',
            ['M15'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:3,b:_0',
            ['O13'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:3,b:_0',
            ['P8'] => 'offboard=revenue:yellow_30|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:1,b:_0',
            ['A17'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Detroit;'\
                       'path=a:5,b:_0;border=edge:0',
            ['A19'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Detroit;'\
                       'path=a:4,b:_0;border=edge:3',
          },
          blue: {
            ['E19'] => 'offboard=revenue:10;path=a:3,b:_0;border=edge:2,type:impassable',
            ['H16'] => 'offboard=revenue:10;path=a:2,b:_0;path=a:4,b:_0;border=edge:3,type:impassable',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
