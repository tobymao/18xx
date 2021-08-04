# frozen_string_literal: true

module Engine
  module Game
    module G1849Boot
      module Map
        TILES = {
          '3' => 4,
          '4' => 4,
          '7' => 4,
          '8' => 10,
          '9' => 8,
          '58' => 4,
          '73' => 4,
          '74' => 3,
          '77' => 4,
          '78' => 10,
          '79' => 7,
          '644' => 2,
          '645' => 2,
          '657' => 2,
          '658' => 2,
          '659' => 2,
          '679' => 2,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '624' => 1,
          '650' => 1,
          '660' => 1,
          '661' => 1,
          '662' => 1,
          '663' => 1,
          '664' => 1,
          '665' => 1,
          '666' => 1,
          '667' => 1,
          '668' => 1,
          '669' => 1,
          '670' => 1,
          '671' => 1,
          '677' => 3,
          '678' => 3,
          '680' => 1,
          '681' => 1,
          '682' => 1,
          '683' => 1,
          '684' => 1,
          '685' => 1,
          '686' => 1,
          '687' => 1,
          '688' => 1,
          '689' => 1,
          '690' => 1,
          '691' => 1,
          '692' => 1,
          '693' => 1,
          '694' => 1,
          '695' => 1,
          '699' => 2,
          '700' => 1,
          '701' => 1,
          '702' => 1,
          '703' => 1,
          '704' => 1,
          '705' => 1,
          '706' => 1,
          '707' => 1,
          '708' => 1,
          '709' => 1,
          '710' => 1,
          '711' => 1,
          '712' => 1,
          '713' => 1,
          '714' => 1,
          '715' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '646' => 1,
          '647' => 1,
          '648' => 1,
          '649' => 1,
          '672' => 1,
          '673' => 2,
          '674' => 2,
          '696' => 3,
          '697' => 2,
          '698' => 2,
          'X1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=A;city=revenue:60,slots:2;path=a:1,b:_0,track:dual;path=a:4,b:_0;'\
                      'path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'X2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=N;city=revenue:50,slots:1;path=a:4,b:_0,track:narrow;'\
                      'path=a:5,b:_0;path=a:1,b:_0,track:dual',
          },
          'X3' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'label=R;city=revenue:30,slots:2;path=a:3,b:_0,track:dual;path=a:4,b:_0;path=a:2,b:_0,track:dual',
          },
          'X4' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'label=T;city=revenue:30,slots:2;path=a:2,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:5,b:_0',
          },
          'X5' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'label=A;city=revenue:90,slots:2;path=a:1,b:_0,track:dual;path=a:4,b:_0;'\
            'path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'X6' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=N;city=revenue:90,slots:3;path=a:4,b:_0,track:dual;path=a:5,b:_0;'\
                      'path=a:1,b:_0,track:dual;path=a:3,b:_0',
          },
          'X7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=R;city=revenue:90,slots:2;path=a:3,b:_0,track:dual;'\
                      'path=a:4,b:_0;path=a:2,b:_0,track:dual',
          },
          'X8' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=T;city=revenue:60,slots:2;path=a:2,b:_0,track:dual;'\
                      'path=a:1,b:_0,track:dual;path=a:5,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A7' => 'Terni',
          'A9' => "L'Aquila",
          'B14' => 'Pescara',
          'C5' => 'Roma',
          'C7' => 'Avezzano',
          'D10' => 'Isernia',
          'D14' => 'Vasto',
          'E11' => 'Campobasso',
          'F10' => 'Benevento',
          'F14' => 'Lucera',
          'F8' => 'Caserta',
          'G15' => 'Foggia',
          'G17' => 'Vieste',
          'G7' => 'Napoli',
          'G9' => 'Avellino',
          'H8' => 'Salerno',
          'I13' => 'Potenza',
          'J10' => 'Rofrano',
          'J16' => 'Matera',
          'J18' => 'Bari',
          'K9' => 'Scalea',
          'K13' => 'Metaponto',
          'L12' => 'Sibari',
          'L18' => 'Taranto',
          'L20' => 'Brindisi',
          'M9' => 'Cosenza',
          'N20' => 'Lecce',
          'N2' => 'Messina',
          'O11' => 'Crotone',
          'O19' => 'Ugento',
          'O5' => 'Vibo Valentia',
          'O9' => 'Catanzaro',
          'P2' => 'Reggio Calabria',
          'P6' => 'Siderno',
        }.freeze
        HEXES = {
          white: {
            %w[A11 A13 B12 D6 D8 E7 E15 F16 H14 I17 J8 K19 K15 M19 M21 N18 L10 O7] => '',
            ['H16'] => 'border=edge:3,type:impassable',
            %w[E9 E13 G13 H10 I9 N8] => 'upgrade=cost:40,terrain:mountain',
            %w[C13 F12 G11 I15 J14 K17 M11 O3] => 'upgrade=cost:80,terrain:mountain',
            %w[B8 B10 C11 D12 J12 K11 N10 P4 H12 I11 C9] => 'upgrade=cost:160,terrain:mountain',
            %w[L20 O9 G15 L12] => 'city=revenue:0',
            %w[E11] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[F8 F10 O5 M9] => 'town=revenue:0',
            ['G17'] => 'town=revenue:0;border=edge:0,type:impassable',
            %w[D14 F14 J10 J16] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['K13'] => 'town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[D10 G9] => 'town=revenue:0;upgrade=cost:160,terrain:mountain',
          },
          blue: {
            ['B16'] => 'offboard=revenue:30,route:optional;path=a:1,b:_0,track:dual',
            ['J20'] => 'offboard=revenue:40,route:optional;path=a:1,b:_0,track:dual',
            %w[L16 G5] => 'offboard=revenue:40,route:optional;path=a:4,b:_0,track:dual',
          },
          gray: {
            ['A7'] => 'offboard=revenue:white_10|gray_40|black_60;path=a:4,b:_0,track:dual',
            ['N2'] => 'offboard=revenue:white_30|gray_50|black_80;path=a:0,b:_0,track:dual',
            ['C5'] => 'offboard=revenue:white_60|gray_90|black_120;path=a:5,b:_0,track:dual;path=a:4,b:_0,track:dual',
            ['O1'] => 'path=a:3,b:5,track:dual',
            ['N12'] => 'path=a:0,b:2,track:dual',
            ['C7'] => 'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
            ['O11'] => 'town=revenue:20;path=a:3,b:_0,track:dual;path=a:1,b:_0,track:dual',
            ['O19'] => 'town=revenue:20;path=a:3,b:_0,track:dual',
            ['P6'] => 'town=revenue:20;path=a:3,b:_0,track:dual;path=a:2,b:_0,track:dual;'\
                      'path=a:1,b:_0,track:dual',
            ['K9'] => 'town=revenue:20;path=a:3,b:_0,track:dual;path=a:2,b:_0,track:dual;'\
                      'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
            ['J18'] => 'city=slots:2,revenue:white_20|gray_30|black_40;path=a:4,b:_0,track:dual;'\
                       'path=a:2,b:_0;path=a:1,b:_0,track:narrow;path=a:5,b:_0',
            ['B14'] => 'city=revenue:white_20|gray_30|black_40,slots:2;path=a:0,b:_0,track:dual;'\
                       'path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:4,b:_0,track:dual',
            ['I13'] => 'city=slots:2,revenue:white_20|gray_30|black_40;path=a:4,b:_0,track:dual;'\
                       'path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:1,b:_0,track:dual;'\
                       'path=a:5,b:_0,track:dual;path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual',
            ['N20'] => 'city=slots:1,revenue:white_20|gray_30|black_40;path=a:0,b:_0,track:dual;'\
                       'path=a:3,b:_0,track:dual;path=a:2,b:_0,track:dual',
          },
          yellow: {
            ['A9'] => 'label=A;city=revenue:30;upgrade=cost:80,terrain:mountain;'\
                      'path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                      'path=a:4,b:_0',
            ['P2'] => 'label=R;city=revenue:10;path=a:3,b:_0,track:narrow;path=a:4,b:_0',
            ['L18'] => 'label=T;city=revenue:20;path=a:2,b:_0,track:dual',
            ['G7'] => 'label=N;city=revenue:20;path=a:4,b:_0,track:narrow;path=a:5,b:_0',
            ['H8'] => 'city=revenue:10;path=a:2,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
