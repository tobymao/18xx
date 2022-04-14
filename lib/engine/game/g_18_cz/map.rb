# frozen_string_literal: true

module Engine
  module Game
    module G18CZ
      module Map
        LAYOUT = :pointy

        TILES = {
          '1' => 1,
          '2' => 1,
          '7' => 5,
          '8' => 14,
          '9' => 13,
          '3' => 4,
          '58' => 4,
          '4' => 4,
          '5' => 4,
          '6' => 4,
          '57' => 4,
          '201' => 2,
          '202' => 2,
          '621' => 2,
          '55' => 1,
          '56' => 1,
          '69' => 1,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '14' => 4,
          '15' => 4,
          '619' => 4,
          '208' => 2,
          '207' => 2,
          '622' => 2,
          '611' => 7,
          '216' => 3,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '70' => 1,
          '8885' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          '8859' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=OO',
          },
          '8860' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=OO',
          },
          '8863' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:5;label=OO',
          },
          '8864' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          '8865' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:3,b:_1;path=a:_1,b:4;label=OO',
          },
          '8889' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;path=a:2,b:_0;' \
            'path=a:3,b:_1;path=a:4,b:_2;label=P',
          },
          '8890' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;city=revenue:30,groups:Praha;path=a:0,b:_0;' \
            'path=a:2,b:_1;path=a:4,b:_2;label=P',
          },
          '8891' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,groups:Praha;city=revenue:40,groups:Praha;city=revenue:40,groups:Praha;' \
            'city=revenue:40,groups:Praha;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;label=P',
          },
          '8892' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
            'path=a:5,b:_0;label=P',
          },
          '8893' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
            'path=a:5,b:_0;label=P',
          },
          '8894' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
            'icon=image:18_cz/50;label=Ug',
          },
          '8895' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
            'icon=image:18_cz/50;label=kk',
          },
          '8896' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
            'icon=image:18_cz/50;label=SX',
          },
          '8897' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
            'icon=image:18_cz/50;label=PR',
          },
          '8898' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;' \
            'icon=image:18_cz/50;label=BY',
          },
          '8866p' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;frame=color:#800080',
          },
          '14p' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#800080',
          },
          '887p' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' =>
            'town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;path=a:2,b:_0;frame=color:#800080',
          },
          '15p' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;frame=color:#800080',
          },
          '888p' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#800080',
          },
          '889p' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:#800080',
          },
          '611p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
            'frame=color:#800080',
          },
          '216p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;' \
            'frame=color:#800080',
          },
          '8894p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;' \
            'frame=color:#800080',
          },
          '8895p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;' \
            'frame=color:#800080',
          },
          '8896p' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=OO;' \
            'frame=color:#800080',
          },
          '8857p' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
            'path=a:5,b:_0;label=Y;frame=color:#800080',
          },
          '595p' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
            'path=a:5,b:_0;frame=color:#800080',
          },
        }.freeze

        LOCATION_NAMES = {
          'G16' => 'Jihlava',
          'D17' => 'Hradec Králové',
          'B11' => 'Děčín',
          'B13' => 'Liberec',
          'C24' => 'Opava',
          'E22' => 'Olomouc',
          'G24' => 'Hulín',
          'G12' => 'Tábor',
          'I12' => 'České Budějovice',
          'F7' => 'Plzeň',
          'E10' => 'Kladno',
          'B9' => 'Teplice & Ústí nad Labem',
          'D27' => 'Frýdlant & Frýdek',
          'C8' => 'Chomutov & Most',
          'E12' => 'Praha',
          'D3' => 'Cheb',
          'D5' => 'Karolvy Vary',
          'E16' => 'Pardubice',
          'C26' => 'Ostrava',
          'F23' => 'Přerov',
          'G20' => 'Brno',
          'I10' => 'Strakonice',
        }.freeze

        HEXES = {
          gray: { ['D1'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0' },
          white: {
            %w[A12
               B25
               C16
               D7
               D9
               D19
               D21
               D23
               D25
               E8
               E18
               E20
               E24
               E26
               F9
               F15
               F17
               F19
               F25
               G8
               H9
               H13
               H21] => '',
            %w[H23 I14] => 'border=edge:5,type:offboard',
            %w[J13 I22 G26] => 'border=edge:4,type:offboard',
            ['B23'] => 'border=edge:2,type:offboard',
            %w[F5 I20] => 'border=edge:1,type:offboard',
            ['G4'] => 'border=edge:2,type:offboard;border=edge:5,type:offboard',
            %w[G6 H19 H25] => 'border=edge:0,type:offboard',
            %w[A16 C22 I8] => 'upgrade=cost:40,terrain:mountain',
            ['B21'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:1,type:offboard;border=edge:3,type:offboard',
            ['C4'] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:offboard',
            ['B7'] =>
              'upgrade=cost:40,terrain:mountain;border=edge:3,type:offboard;border=edge:1,type:offboard',
            %w[A14 D29 E28 E6 H15 G14] => 'upgrade=cost:20,terrain:hill',
            ['F27'] => 'upgrade=cost:20,terrain:hill;border=edge:5,type:offboard',
            ['C6'] =>
              'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:2,type:offboard',
            %w[J11 G18] => 'town=revenue:0;upgrade=cost:20,terrain:hill',
            ['H17'] =>
              'town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:5,type:offboard',
            ['H7'] =>
              'town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:1,type:offboard',
            ['B17'] =>
              'town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:4,type:offboard',
            ['G16'] => 'city=revenue:0;upgrade=cost:20,terrain:hill',
            %w[D11 D15 G10 H11] => 'upgrade=cost:10,terrain:water',
            ['D13'] => 'upgrade=cost:10,terrain:water;stub=edge:0',
            ['C18'] => 'upgrade=cost:10,terrain:water;border=edge:3,type:offboard',
            %w[F11 C10 C12] => 'town=revenue:0;upgrade=cost:10,terrain:water',
            ['A10'] =>
              'town=revenue:0;upgrade=cost:10,terrain:water;border=edge:1,type:offboard',
            %w[D17 E16] => 'city=revenue:0;upgrade=cost:10,terrain:water',
            %w[B11 C24 E22 G24 G12 E10 D3 D5 F23 I10] =>
              'city=revenue:0',
            %w[B13 I12 F7 C26 G20] => 'city=revenue:0;label=Y',
            %w[C14 G22 C28] => 'town=revenue:0',
            ['F13'] => 'town=revenue:0;stub=edge:2',
            ['E4'] => 'town=revenue:0;border=edge:0,type:offboard',
            ['E2'] => 'town=revenue:0;border=edge:5,type:offboard',
            ['C20'] => 'town=revenue:0;border=edge:2,type:offboard',
            %w[E14 F21 B15] => 'town=revenue:0;town=revenue:0',
            ['E12'] => 'city=revenue:20,groups:Praha;city=revenue:20,groups:Praha;'\
                       'path=a:5,b:_0;path=a:3,b:_1;label=P;upgrade=cost:10,terrain:water',
            %w[A8 B5] =>
              'label=SX;border=edge:0,type:offboard;border=edge:5,type:offboard;border=edge:4,type:offboard',
            ['B19'] =>
              'label=PR;border=edge:0,type:offboard;border=edge:5,type:offboard;border=edge:4,type:offboard;' \
              'border=edge:1,type:offboard',
            ['A22'] => 'label=PR;border=edge:0,type:offboard;border=edge:5,type:offboard',
            ['H5'] =>
              'label=BY;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard',
            ['F3'] =>
              'label=BY;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard;' \
              'border=edge:5,type:offboard',
            ['I18'] =>
              'label=kk;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard',
            ['J15'] => 'label=kk;border=edge:1,type:offboard;border=edge:2,type:offboard',
            ['I24'] =>
              'label=Ug;border=edge:1,type:offboard;border=edge:2,type:offboard;border=edge:3,type:offboard',
            ['G28'] =>
              'label=Ug;border=edge:1,type:offboard;border=edge:2,type:offboard',
          },
          yellow: {
            %w[D27 C8] => 'city=revenue:0;city=revenue:0;label=OO',
            ['B9'] =>
              'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:10,terrain:water;border=edge:2,type:offboard',
          },
        }.freeze
      end
    end
  end
end
