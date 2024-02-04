# frozen_string_literal: true

module Engine
  module Game
    module G18Norway
      module Map
        LAYOUT = :flat
        LOCATION_NAMES = {
          'B26' => 'Bergen',
          'B32' => 'Stavanger',
          'C35' => 'Kristiansand',
          'C37' => 'Europe',
          'C19' => 'Ålesund',
          'D18' => 'Molde',
          'D22' => 'Jostedal',
          'F24' => 'Jotunhimen',
          'G17' => 'Trondheim',
          'G23' => 'Lillehammer',
          'G29' => 'Oslo',
          'H24' => 'Hamar',
          'H34' => 'Göteborg',
          'H32' => 'Halden',
          'I19' => 'Östersund',
          'I23' => 'Rørosbanen',
          'I29' => 'Stockholm',
          'K1' => 'Bodø',
          'K5' => 'Mo i Rana',
          'J8' => 'Mosjøen',
          'H26' => 'Mjøsa',
          'I13' => 'Steinkjer',
          'F20' => 'Dombås/Otta',
          'E19' => 'Åndalsnes',
          'B22' => 'Florø',
          'D24' => 'Flåm',
          'I21' => 'Koppang',
          'B30' => 'Haugesund',
          'C29' => 'Sauda',
          'B34' => 'Egersund',
          'D34' => 'Arendal',
          'F32' => 'Larvik',
          'F30' => 'Drammen',
          'G31' => 'Sarpsborg',
          'K3' => 'Saltfjellet',
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
            'code' => 'label=LM;junction;path=a:0,b:_0,terminal:1;junction;path=a:1,b:_1,terminal:2;'\
                      'junction;path=a:2,b:_2,terminal:3;junction;path=a:3,b:_3,terminal:4;'\
                      'junction;path=a:4,b:_4,terminal:5;junction;path=a:5,b:_5,terminal:6;'\
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
            'code' => 'label=K;city=revenue:30;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;'\
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
            'code' => 'label=LM;junction;path=a:0,b:_0,terminal:1;junction;path=a:1,b:_1,terminal:2;'\
                      'junction;path=a:2,b:_2,terminal:3;junction;path=a:3,b:_3,terminal:4;'\
                      'junction;path=a:4,b:_4,terminal:5;junction;path=a:5,b:_5,terminal:6;'\
                      'path=a:0,b:_0,track:thin;path=a:1,b:_0,track:thin;path=a:2,b:_0,track:thin;' \
                      'path=a:3,b:_0,track:thin;path=a:4,b:_0,track:thin;path=a:5,b:_0,track:thin;', \
          },
          '39' => 1,
          '40' => 1,
          '41' => 1,
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
            %w[K3 K7 J10 I11 H14 F16 E17 F18 H18 H30] => '',
            %w[C33 D32 E31 E33 F28 I23 I25 I27] => '',
            %w[B34 C29 D34 H32] => 'town=revenue:0',
            %w[E19] => 'city=revenue:0',
            %w[D28 G19 G27 H20 H28] => 'upgrade=cost:30,terrain:hill',
            %w[D30 E29 H22] => 'upgrade=cost:40,terrain:mountain',
            ['B30'] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['B22'] => 'town=revenue:0;border=edge:0,type:impassable',
            ['C21'] => 'border=edge:5,type:divider',
            ['C31'] => 'border=edge:2,type:impassable',
            ['D20'] => 'border=edge:0,type:divider',
            ['D24'] => 'town=revenue:0;border=edge:3,type:divider;border=edge:5,type:divider;border=edge:2,type:impassable',
            ['E21'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:divider;border=edge:5,type:divider',
            ['E23'] => 'upgrade=cost:30,terrain:hill;border=edge:0,type:divider;border=edge:2,type:divider;'\
                       'border=edge:4,type:divider;border=edge:5,type:divider',
            ['F20'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:divider',
            ['G21'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:divider',
            ['G23'] => 'city=revenue:0;border=edge:1,type:divider;border=edge:2,type:divider',
            ['G25'] => 'border=edge:2,type:divider;border=edge:4,type:impassable',
            ['H24'] => 'town=revenue:0;border=edge:1,type:impassable',
            ['B24'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['B28'] => 'border=edge:3,type:impassable',
            ['C23'] => 'border=edge:4,type:divider;border=edge:0,type:impassable;border=edge:1,type:impassable;'\
                       'border=edge:5,type:impassable',
            ['C25'] => 'border=edge:0,type:impassable;border=edge:3,type:impassable',
            ['C27'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['D26'] => 'city=revenue:0;upgrade=cost:30,terrain:hill;border=edge:4,type:divider;border=edge:1,type:impassable',
            ['E27'] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:divider',
            ['F26'] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:divider;border=edge:3,type:divider',
            ['F30'] => 'city=revenue:0;border=edge:5,type:impassable',
            ['F32'] => 'town=revenue:0;border=edge:4,type:impassable',
            ['G31'] => 'city=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
          },
          gray: {
            ['K5'] => 'town=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            ['J8'] => 'town=revenue:20;path=a:0,b:_0;path=a:4,b:_0',
            ['I13'] => 'town=revenue:20;path=a:1,b:_0;path=a:3,b:_0',
            ['H16'] => 'path=a:1,b:3',
            ['D22'] => 'border=edge:0,type:divider;border=edge:1,type:divider;border=edge:2,type:divider;'\
                       'border=edge:3,type:divider;border=edge:4,type:divider;border=edge:5,type:divider',
            ['E25'] => 'border=edge:0,type:divider;border=edge:1,type:divider;border=edge:2,type:divider;'\
                       'border=edge:3,type:divider;border=edge:5,type:divider',
            ['F22'] => 'border=edge:1,type:divider;border=edge:2,type:divider;border=edge:3,type:divider;'\
                       'border=edge:4,type:divider;border=edge:5,type:divider',
            ['F24'] => 'border=edge:0,type:divider;border=edge:2,type:divider;border=edge:4,type:divider;'\
                       'border=edge:5,type:divider',
            ['I21'] => 'town=revenue:20;path=a:0,b:_0;path=a:2,b:_0',
          },
          red: {
            ['C37'] => 'offboard=revenue:yellow_30|green_50|brown_60;path=a:3,b:_0,track:narrow',
            ['H34'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80;path=a:3,b:_0',
            ['I19'] => 'offboard=revenue:yellow_20|green_40|brown_60;path=a:1,b:_0',
            ['I29'] => 'offboard=revenue:yellow_20|green_40|brown_60;path=a:1,b:_0;path=a:2,b:_0',
            ['K1'] => 'offboard=revenue:green_0|brown_100;path=a:0,b:_0',
          },
          yellow: {
            ['B26'] => 'label=B;city=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;'\
                       'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['B32'] => 'label=S;city=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;'\
                       'border=edge:3,type:impassable',
            ['C19'] => 'label=Å;town=revenue:10;path=a:5,b:_0;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                       'border=edge:4,type:impassable',
            ['C35'] => 'label=K;city=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:4,b:_0',
            ['D18'] => 'label=M;city=revenue:20;path=a:5,b:_0;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                       'border=edge:1,type:impassable',
            ['G17'] => 'label=T;city=revenue:20;path=a:0,b:_0;path=a:3,b:_0,track:narrow',
            ['G29'] => 'label=O;city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2',
          },
          blue: {
            %w[C1 E1 G1 I1] => '',
            %w[A1 A3 A5 A7 A9 A11 A13 A15 A17 A19] => '',
            %w[D36 E35 F34 F36 G33 G35 H36] => '',
            %w[B2 D2 F2 H2 J2] => '',
            %w[C3 E3 G3 I3] => '',
            %w[B4 D4 F4 H4 J4] => '',
            %w[C5 E5 G5 I5] => '',
            %w[B6 D6 F6 H6 J6] => '',
            %w[C7 E7 G7 I7] => '',
            %w[B8 D8 F8 H8] => '',
            %w[C9 E9 G9 I9] => '',
            %w[B10 D10 F10 H10] => '',
            %w[C11 E11 G11] => '',
            %w[B12 D12 F12 H12] => '',
            %w[C13 E13 G13] => '',
            %w[B14 D14] => '',
            %w[C15] => '',
            %w[B16 B18] => '',
            ['A21'] => 'path=a:0,b:4,track:narrow',
            ['A23'] => 'path=a:0,b:3,track:narrow',
            ['A25'] => 'path=a:3,b:5,track:narrow',
            ['A27'] => 'path=a:0,b:4,track:narrow',
            ['A29'] => 'path=a:0,b:3,track:narrow',
            ['A31'] => 'path=a:3,b:5,track:narrow',
            ['A33'] => 'path=a:0,b:4,track:narrow',
            ['A35'] => 'path=a:3,b:5,track:narrow',
            ['C17'] => 'path=a:0,b:5,track:narrow',
            ['D16'] => 'path=a:0,b:4,track:narrow',
            ['E15'] => 'path=a:1,b:4,track:narrow',
            ['F14'] => 'path=a:1,b:5,track:narrow',
            ['G15'] => 'path=a:0,b:2,track:narrow',
            ['B20'] => 'path=a:1,b:4,track:narrow',
            ['B36'] => 'path=a:2,b:4,track:narrow',
            ['H26'] => 'label=LM;junction;path=a:0,b:_0,terminal:1;junction;path=a:2,b:_1,terminal:2;'\
                       'junction;path=a:3,b:_2,terminal:3;junction;path=a:4,b:_3,terminal:4;'\
                       'path=a:0,b:2,track:thin;path=a:0,b:3,track:thin;path=a:0,b:4,track:thin',
          },
        }.freeze
      end
    end
  end
end
