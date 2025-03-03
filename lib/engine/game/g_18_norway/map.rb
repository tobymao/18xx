# frozen_string_literal: true

module Engine
  module Game
    module G18Norway
      module Map
        LAYOUT = :flat
        LOCATION_NAMES = {
          'C26' => 'Bergen',
          'C32' => 'Stavanger',
          'D35' => 'Kristiansand',
          'D37' => 'Rotterdam',
          'D19' => 'Ålesund',
          'E18' => 'Molde',
          'E22' => 'Jostedal',
          'G24' => 'Jotunhimen',
          'H17' => 'Trondheim',
          'H23' => 'Lillehammer',
          'H29' => 'Oslo',
          'I24' => 'Hamar',
          'I34' => 'Göteborg',
          'I32' => 'Halden',
          'J19' => 'Östersund',
          'J23' => 'Rørosbanen',
          'J29' => 'Stockholm',
          'L1' => 'Bodø',
          'L5' => 'Mo i Rana',
          'K8' => 'Mosjøen',
          'I26' => 'Mjøsa',
          'J13' => 'Steinkjer',
          'G20' => 'Dombås/Otta',
          'F19' => 'Åndalsnes',
          'C22' => 'Florø',
          'E24' => 'Flåm',
          'J21' => 'Koppang',
          'C30' => 'Haugesund',
          'D29' => 'Sauda',
          'C34' => 'Egersund',
          'E34' => 'Arendal',
          'G32' => 'Larvik',
          'G30' => 'Drammen',
          'H31' => 'Sarpsborg',
          'E26' => 'Myrdal',
        }.freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 3,
          '5' => 4,
          '6' => 4,
          '7' => 3,
          '8' => 12,
          '9' => 6,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 3,
          '69' => 1,

          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '87' => 1,
          '88' => 1,
          '204' => 1,
          '441' => 2,
          '442' => 2,
          '443' => 1,
          '444' => 2,
          'O1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=O;city=revenue:60;city=revenue:60;city=revenue:60;path=a:0,b:_0;'\
                      'path=a:3,b:_0;path=a:2,b:_1;path=a:5,b:_1;path=a:1,b:_2;path=a:4,b:_2',
          },
          'S1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=S;city=revenue:30;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                      'path=a:0,b:_0;path=a:4,b:_0;',
          },
          'K1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=K;city=revenue:30;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:4,b:_0',
          },
          'B1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=B;city=revenue:40;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                      'path=a:3,b:_0;path=a:4,b:_0;',
          },
          'M1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=M;city=revenue:30;path=a:4,b:_0;path=a:5,b:_0;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'T1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=T;city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:3,b:_0,track:narrow',
          },
          'Å1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=Å;town=revenue:30;path=a:5,b:_0;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'LM1' => {
            'count' => 1,
            'color' => 'blue',
            'code' => 'label=LM;'\
                      'path=a:0,b:2,track:thin;path=a:0,b:3,track:thin;path=a:0,b:4,track:thin;' \
                      'path=a:3,b:1,track:thin;path=a:3,b:5,track:thin;', \
          },
          'O2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=O;city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0',
          },
          'S2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=S;city=revenue:50;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                      'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'K2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=K;city=revenue:50;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'B2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=B;city=revenue:60;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                      'path=a:3,b:_0;path=a:4,b:_0;',
          },
          'M2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=M;city=revenue:40;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'T2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=T;city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0,track:narrow',
          },
          'NO1' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'NO2' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'LM2' => {
            'count' => 1,
            'color' => 'blue',
            'code' => 'label=LM;junction;path=a:0,b:_0,terminal:1,track:thin;'\
                      'path=a:0,b:_0,track:thin;path=a:1,b:_0,track:thin;path=a:2,b:_0,track:thin;' \
                      'path=a:3,b:_0,track:thin;path=a:4,b:_0,track:thin;path=a:5,b:_0,track:thin;', \
          },
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '70' => 1,
          '448' => 2,
          '449' => 1,
          '450' => 1,
          '444B' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0', \
          },
          'O3' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'label=O;city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,'\
                      'b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'T3' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'label=T;city=revenue:90,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,'\
                      'b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0,track:narrow',
          },

        }.freeze

        HEXES = {
          white: {
            %w[L3 L7 K10 J11 I14 G16 F17 G18 I18 I20 I30] => '',
            %w[D33 E32 F33 J23 J25 J27] => '',
            %w[C34 D29 E34 I32] => 'town=revenue:0',
            %w[F19] => 'city=revenue:0',
            %w[E28 G28 H19 H27 I28] => 'upgrade=cost:30,terrain:hill',
            %w[E30 F29 I22] => 'upgrade=cost:40,terrain:mountain',
            ['F31'] => 'upgrade=cost:20,terrain:water',
            ['C30'] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable;upgrade=cost:20,terrain:water',
            ['C22'] => 'town=revenue:0;border=edge:0,type:impassable',
            ['D21'] => 'border=edge:5,type:divider',
            ['D31'] => 'border=edge:2,type:impassable',
            ['E20'] => 'border=edge:0,type:divider',
            ['E24'] => 'town=revenue:0;border=edge:3,type:divider;border=edge:5,type:divider;border=edge:2,type:impassable',
            ['F21'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:divider;border=edge:5,type:divider',
            ['F23'] => 'upgrade=cost:30,terrain:hill;border=edge:0,type:divider;border=edge:2,type:divider;'\
                       'border=edge:4,type:divider;border=edge:5,type:divider',
            ['G20'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:divider',
            ['H21'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:divider',
            ['H23'] => 'city=revenue:0;border=edge:1,type:divider;border=edge:2,type:divider',
            ['H25'] => 'border=edge:2,type:divider;border=edge:4,type:impassable',
            ['I24'] => 'town=revenue:0;border=edge:1,type:impassable;upgrade=cost:20,terrain:water',
            ['C24'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['C28'] => 'upgrade=cost:20,terrain:water;border=edge:3,type:impassable',
            ['D23'] => 'border=edge:4,type:divider;border=edge:0,type:impassable;border=edge:1,type:impassable;'\
                       'border=edge:5,type:impassable',
            ['D25'] => 'border=edge:0,type:impassable;border=edge:3,type:impassable',
            ['D27'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['E26'] => 'city=revenue:0;upgrade=cost:30,terrain:hill;border=edge:4,type:divider;border=edge:1,type:impassable',
            ['F27'] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:divider',
            ['G26'] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:divider;border=edge:3,type:divider',
            ['G30'] => 'city=revenue:0;border=edge:5,type:impassable',
            ['G32'] => 'town=revenue:0;border=edge:4,type:impassable',
            ['H31'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
          },
          gray: {
            ['L5'] => 'town=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            ['K8'] => 'town=revenue:20;path=a:0,b:_0;path=a:4,b:_0',
            ['J13'] => 'town=revenue:20;path=a:1,b:_0;path=a:3,b:_0',
            ['I16'] => 'path=a:1,b:3',
            ['E22'] => 'border=edge:0,type:divider;border=edge:1,type:divider;border=edge:2,type:divider;'\
                       'border=edge:3,type:divider;border=edge:4,type:divider;border=edge:5,type:divider',
            ['F25'] => 'border=edge:0,type:divider;border=edge:1,type:divider;border=edge:2,type:divider;'\
                       'border=edge:3,type:divider;border=edge:5,type:divider',
            ['G22'] => 'border=edge:1,type:divider;border=edge:2,type:divider;border=edge:3,type:divider;'\
                       'border=edge:4,type:divider;border=edge:5,type:divider',
            ['G24'] => 'border=edge:0,type:divider;border=edge:2,type:divider;border=edge:4,type:divider;'\
                       'border=edge:5,type:divider',
            ['J21'] => 'town=revenue:20;path=a:0,b:_0;path=a:2,b:_0',
          },
          red: {
            ['D37'] => 'offboard=revenue:yellow_30|green_50|brown_60;path=a:3,b:_0,track:narrow',
            ['I34'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80;path=a:3,b:_0',
            ['J19'] => 'offboard=revenue:yellow_20|green_40|brown_60;path=a:1,b:_0',
            ['J29'] => 'offboard=revenue:yellow_20|green_40|brown_60;path=a:1,b:_0;path=a:2,b:_0',
            ['L1'] => 'offboard=revenue:green_0|brown_180;path=a:0,b:_0',
          },
          yellow: {
            ['C26'] => 'label=B;city=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;'\
                       'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['C32'] => 'label=S;city=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;'\
                       'border=edge:3,type:impassable',
            ['D19'] => 'label=Å;town=revenue:10;path=a:5,b:_0;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                       'border=edge:4,type:impassable',
            ['D35'] => 'label=K;city=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:4,b:_0;'\
                       'path=a:5,b:_0,track:thin',
            ['E18'] => 'label=M;city=revenue:20;path=a:5,b:_0;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                       'border=edge:1,type:impassable',
            ['H17'] => 'label=T;city=revenue:20;path=a:0,b:_0;path=a:3,b:_0,track:narrow',
            ['H29'] => 'label=O;city=revenue:30;city=revenue:30;city=revenue:30;path=a:2,b:_1;path=a:4,b:_2',
          },
          blue: {
            %w[K2 K4 K6 J7 J9 I10 I12 C18] => '',
            %w[A20 A22 A24 A28 A30 A34 B19] => '',
            %w[A2 A4 A6 A8 A10 A12 A14 A16 A18 A36] => '',
            %w[B1 B3 B5 B7 B9 B11 B13 B15 B17 B37] => '',
            %w[C2 C4 C6 C8 C10 C12 C14 C16] => '',
            %w[D1 D3 D5 D7 D9 D11 D13] => '',
            %w[E2 E4 E6 E8 E10 E12 E14] => '',
            %w[F1 F3 F5 F7 F9 F11 F13 F35 F37] => '',
            %w[G2 G4 G6 G8 G10 G12 G34 G36] => '',
            %w[H1 H3 H5 H7 H9 H11 H33 H35] => '',
            %w[I2 I4 I6 I8] => '',
            %w[J1 J3 J5] => '',
            ['B21'] => 'path=a:0,b:4,track:narrow',
            ['B23'] => 'path=a:0,b:3,track:narrow',
            ['B25'] => 'path=a:3,b:5,track:narrow;path=a:1,b:5,track:thin',
            ['A26'] => 'city=revenue:0;path=a:_0,b:4,track:thin',
            ['B27'] => 'path=a:0,b:4,track:narrow',
            ['B29'] => 'path=a:0,b:3,track:narrow',
            ['B31'] => 'path=a:3,b:5,track:narrow;path=a:1,b:5,track:thin',
            ['A32'] => 'city=revenue:0;path=a:_0,b:4,track:thin',
            ['B33'] => 'path=a:0,b:4,track:narrow',
            ['B35'] => 'path=a:3,b:5,track:narrow',
            ['D15'] => 'city=revenue:0;path=a:_0,b:5,track:thin',
            ['D17'] => 'path=a:0,b:5,track:narrow',
            ['E16'] => 'path=a:0,b:4,track:narrow;path=a:2,b:0,track:thin',
            ['F15'] => 'path=a:1,b:4,track:narrow',
            ['G14'] => 'path=a:1,b:5,track:narrow',
            ['H13'] => 'city=revenue:0;path=a:_0,b:0,track:thin',
            ['H15'] => 'path=a:0,b:2,track:narrow;path=a:3,b:0,track:thin',
            ['C20'] => 'path=a:1,b:4,track:narrow',
            ['C36'] => 'path=a:2,b:4,track:narrow',
            ['E36'] => 'city=revenue:0;path=a:_0,b:2,track:thin',
            ['I26'] => 'label=LM;'\
                       'path=a:0,b:2,track:thin;path=a:0,b:3,track:thin;path=a:0,b:4,track:thin',
          },
        }.freeze
      end
    end
  end
end
