# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Map
        LAYOUT = :pointy
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 8,
          '8' => 15,
          '9' => 15,

          '14' => 5,
          '15' => 5,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,

          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,

          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 4,

          '63' => 4,

          '69' => 1,
          '171' => 1,
          '172' => 1,
          '887' => 1,
          '888' => 1,
          '596' => 1,
          '210' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:5,b:_1;label=XX',
          },
          '211' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=XX',
          },
          '212' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=XX',
          },
          '213' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;label=XX;city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1',
          },
          '214' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=XX',
          },
          '215' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1;label=XX',
          },
          '305' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=XX;'\
                      'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          '306' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=XX;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
          },
          '307' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=XX;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          '309' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=XX;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'URUXX' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:4;label=XX'\
                      ';path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          'URU01' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;label=MV'\
                      ';city=revenue:30;city=revenue:30'\
                      ';path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3'\
                      ';path=a:6,b:_0;path=a:6,b:_1;path=a:5,b:_2;path=a:5,b:_3',\
          },
          'URU02' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:5;label=MV'\
                      ';path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          'URU03' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:5;label=MV'\
                      ';path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          'L125' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;label=L'\
                      ';path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'L448' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;label=L'\
                      ';path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'L612' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;label=L'\
                      ';path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A5' => 'Brazil',
          'B10' => 'Brazil',
          'E15' => 'Brazil',
          'H16' => 'Brazil',
          'C1' => 'Argentina',
          'E1' => 'England',
          'G1' => 'England',
          'I1' => 'England',
          'J14' => 'England',
          'K5' => 'England',
          'K7' => 'England',
          'K13' => 'England',
          'B2' => 'Monte Caseros',
          'B4' => 'Bella Union',
          'B6' => 'Artigas',
          'C5' => 'Term.del Arapey / Baltasar Brum',
          'C7' => 'Rivera',
          'D2' => 'Salto',
          'D6' => 'Tacuarembó',
          'E3' => 'Paysandú',
          'E9' => 'Corrales',
          'E11' => 'Fraile Muerto',
          'E13' => 'Melo',
          'F2' => 'Fray Bentos',
          'F6' => 'Fray Paso de los Toros',
          'F14' => 'Rio Branco',
          'G3' => 'Mercedes',
          'G7' => 'Durazno / Florida',
          'G11' => 'Treinta y Tres',
          'H4' => 'Trinidad / San José',
          'H10' => 'Nico Pérez',
          'H14' => 'Chuy',
          'I3' => 'Colonia',
          'I7' => 'Canelones',
          'I9' => 'Minas',
          'I11' => 'Castillos',
          'J4' => 'Santa Lucia',
          'J10' => 'Empalme Olmos / Piriapolis',
          'J12' => 'Rocha',
        }.freeze

        HEXES = {
          white: {
            %w[B4 B6 C9 D6 E3 E13 G11 I9 J12] => 'city=revenue:0',
            %w[C3 D4 G13 H2 H6] => 'icon=image:18_uruguay/corn_icon',
            %w[E5 H12 J8] => 'icon=image:18_uruguay/sheep_icon',
            %w[D8 F12 I5] => 'icon=image:18_uruguay/cow_icon',
            %w[F14 H10 I7 I13 J4] => 'town=revenue:0',
            %w[C7 G9 H8 I11] => 'upgrade=cost:40,terrain:mountain',
            ['C5'] => 'town=revenue:0;town=revenue:0',
            ['D2'] => 'city=revenue:0;future_label=label:L,color:brown',
            ['D10'] => 'upgrade=cost:20,terrain:water;border=edge:5,type:water,cost:40',
            ['E7'] => 'icon=image:18_uruguay/sheep_icon;border=edge:5,type:water,cost:40',
            ['E9'] => 'town=revenue:0;border=edge:0,type:water,cost:40;border=edge:4,type:water,cost:40;'\
                      'border=edge:5,type:water,cost:40',
            ['E11'] => 'town=revenue:0;border=edge:1,type:water,cost:40;border=edge:2,type:water,cost:40',
            ['F2'] => 'city=revenue:0;border=edge:5,type:water,cost:40',
            ['F4'] => 'icon=image:18_uruguay/cow_icon;border=edge:5,type:water,cost:40;'\
                      'border=edge:0,type:water,cost:40',
            ['F6'] => 'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:4,type:water,cost:40;'\
                      'border=edge:5,type:water,cost:40',
            ['F8'] => 'upgrade=cost:20,terrain:river;border=edge:1,type:water,cost:40;border=edge:2,type:water,cost:40;'\
                      'border=edge:3,type:water,cost:40',
            ['F10'] => 'icon=image:18_uruguay/cow_icon;border=edge:2,type:water,cost:40',
            ['G3'] => 'city=revenue:0;border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40',
            ['G5'] => 'icon=image:18_uruguay/sheep_icon;border=edge:2,type:water,cost:40;'\
                      'border=edge:3,type:water,cost:40',
            ['H4'] => 'town=revenue:0;town=revenue:0',
            ['H14'] => 'city=revenue:0;future_label=label:L,color:brown',
            ['I3'] => 'city=revenue:0;future_label=label:L,color:brown',
            ['J10'] => 'town=revenue:0;town=revenue:0',
          },
          gray: {
            ['B2'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
            ['I15'] => 'path=a:1,b:2',
            ['K11'] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
          },
          red: {
            ['A3'] => 'offboard=revenue:yellow_30|green_40|brown_50,hide:1,groups:Brazil;path=a:5,b:_0;border=edge:4',
            ['A5'] => 'offboard=revenue:yellow_30|green_40|brown_50,groups:Brazil;path=a:5,b:_0;path=a:6,b:_0;border=edge:1;'\
                      'border=edge:4',
            ['A7'] => 'offboard=revenue:yellow_30|green_40|brown_50,hide:1,groups:Brazil;path=a:6,b:_0;border=edge:1;'\
                      'border=edge:5',
            ['B8'] => 'offboard=revenue:yellow_30|green_40|brown_50,hide:1,groups:Brazil;path=a:1,b:_0;path=a:5,b:_0;'\
                      'border=edge:2;border=edge:4',
            ['B10'] => 'offboard=revenue:yellow_30|green_40|brown_50,groups:Brazil;path=a:6,b:_0;border=edge:1;border=edge:5',
            ['C11'] => 'offboard=revenue:yellow_30|green_40|brown_50,hide:1,groups:Brazil;path=a:1,b:_0;path=a:1,b:_0;'\
                       'border=edge:2',
            ['E15'] => 'offboard=revenue:yellow_40|green_50|brown_60,groups:Brazil;path=a:1,b:_0',
            ['H16'] => 'offboard=revenue:yellow_20|green_40|brown_60,groups:Brazil;path=a:1,b:_0',

            ['C1'] => 'offboard=revenue:yellow_20|green_40|brown_60,groups:Argentina;path=a:4,b:_0;path=a:5,b:_0',

          },
          yellow: {
            ['J6'] => 'city=revenue:10,groups:MV;city=revenue:10,groups:MV;'\
                      'city=revenue:10,groups:MV;city=revenue:10,groups:MV;'\
                      'path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;'\
                      'path=a:6,b:_0;path=a:6,b:_1;path=a:5,b:_2;path=a:5,b:_3;'\
                      'label=MV',
            ['G7'] => 'city=revenue:0;city=revenue:0;label=XX;border=edge:2,type:water,cost:40',
          },
          blue: {
            ['E1'] => 'offboard=revenue:yellow_30|green_30|brown_40|gray_60,format:+%d,visit_cost:0,route:optional'\
                      ',groups:England,rows:2;path=a:4,b:_0;path=a:5,b:_0',
            ['G1'] => 'offboard=revenue:yellow_30|green_30|brown_40|gray_60,format:+%d,visit_cost:0,route:optional'\
                      ',groups:England,rows:2;path=a:3,b:_0;path=a:4,b:_0',
            ['I1'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60,format:+%d,visit_cost:0,route:optional'\
                      ',groups:England,rows:2;path=a:4,b:_0',
            ['J14'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60,format:+%d,visit_cost:0,route:optional'\
                       ',groups:England,rows:2;path=a:1,b:_0;path=a:2,b:_0',
            ['K5'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80,format:+%d,visit_cost:0,route:optional'\
                      ',groups:England,rows:2;path=a:3,b:_0',
            ['K7'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80,format:+%d,visit_cost:0,route:optional'\
                      ',groups:England,rows:2;path=a:2,b:_0',
            ['K13'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60,format:+%d,visit_cost:0,route:optional'\
                       ',groups:England,rows:2;path=a:2,b:_0',
            ['K15'] => 'city=revenue:0;path=a:4,b:_0,lanes:4',
            ['K17'] => 'offboard=revenue:yellow_30|green_40|brown_50,format:+%d,visit_cost:0,route:optional'\
                       ';path=a:1,b:_0,lanes:4',
          },
        }.freeze
      end
    end
  end
end
