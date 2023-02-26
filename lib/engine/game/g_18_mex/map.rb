# frozen_string_literal: true

module Engine
  module Game
    module G18MEX
      module Map
        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 5,
          '8' => 11,
          '9' => 11,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 3,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 2,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 4,
          '58' => 4,
          '63' => 7,
          '70' => 1,
          '141' => 2,
          '142' => 2,
          '143' => 2,
          '455' => 1,
          '470' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'town=revenue:20,loc:0;path=a:0,b:_0;path=a:3,b:_0;path=a:3,b:4;path=a:4,b:_0;label=CC',
          },
          '471' => 1,
          '472' => 1,
          '473' => 1,
          '474' => 2,
          '475' => 1,
          '476' => 1,
          '477' => 1,
          '478' => 1,
          '479MC' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2,loc:center;town=revenue:0,loc:2.5;path=a:3,b:_0;path=a:5,b:_0;label=MC;border=edge:5',
          },
          '479P' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;upgrade=cost:40,terrain:mountain;label=P;border=edge:2',
          },
          '480' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
            'label=G;future_label=color:gray',
          },
          '481' => 1,
          '482' => 1,
          '483' => 1,
          '484' => 1,
          '485MC' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:3,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:2,b:_1;'\
            'path=a:5,b:_0,lanes:2;path=a:_1,b:_0;label=MC',
          },
          '485P' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:10,loc:5;path=a:2,b:_0,a_lane:2.1;path=a:5,b:_0;path=a:2,b:4,a_lane:2.0;label=P',
          },
          '486MC' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:4,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:2,b:_1;'\
            'path=a:5,b:_0,lanes:2;path=a:_1,b:_0;label=MC;border=edge:5',
          },
          '486P' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:10,loc:5;path=a:2,b:_0,a_lane:2.1;path=a:5,b:_0;path=a:2,b:4,a_lane:2.0;label=P;border=edge:2',
          },
          '619' => 2,
        }.freeze

        LOCATION_NAMES = {
          'A6' => 'Ciudad Juárez / El Paso',
          'B1' => 'Baja California',
          'B3' => 'Nogales / Tucson',
          'D3' => 'Hermosillo',
          'E6' => 'Chihuahua',
          'F5' => 'Copper Canyon',
          'D11' => 'San Antonio',
          'G10' => 'Nuevo Laredo',
          'H3' => 'Santa Rosalia',
          'I4' => 'Los Mochis',
          'I8' => 'Torreón',
          'I10' => 'Monterrey',
          'I12' => 'Matamoros',
          'J5' => 'Culiacán',
          'J7' => 'Durango',
          'K8' => 'Zacatecas',
          'K6' => 'Mazatlán',
          'L9' => 'San Luis Potosí',
          'M10' => 'Querétaro',
          'M12' => 'Tampico',
          'O8' => 'Guadalajara',
          'O10' => 'Mexico City',
          'P7' => 'Puerto Vallarta',
          'P11' => 'Puebla',
          'P13' => 'Veracruz',
          'Q14' => 'Mérida',
          'S10' => 'Acapulco',
          'S12' => 'Oaxaca',
          'U14' => 'Guatemala',
        }.freeze

        HEXES = {
          red: {
            ['A6'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0',
            ['B1'] => 'offboard=revenue:yellow_30|brown_50;path=a:5,b:_0',
            ['Q14'] =>
                    'city=revenue:yellow_10|brown_50;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['U14'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0',
          },
          gray: {
            ['B3'] => 'city=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0',
            ['D11'] =>
            'city=revenue:yellow_30|brown_60,slots:2;path=a:0,b:_0;path=a:1,b:_0',
            ['I12'] =>
            'city=revenue:yellow_20|brown_40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['U12'] => 'path=a:3,b:4',
          },
          white: {
            %w[B5 C4 D7 E4 F7 F9 G8 H5 I6 N9 P9] =>
                      'upgrade=cost:120,terrain:mountain',
            ['F5'] => 'upgrade=cost:120,terrain:mountain;icon=image:18_al/coal',
            ['Q10'] => 'upgrade=cost:120,terrain:mountain;border=edge:4,type:impassable',
            ['R11'] => 'upgrade=cost:120,terrain:mountain;border=edge:3,type:impassable',
            %w[C2 L11 Q8 Q12] => 'upgrade=cost:60,terrain:mountain',
            ['N11'] =>
            'upgrade=cost:60,terrain:mountain;border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['O12'] => 'upgrade=cost:60,terrain:mountain;border=edge:5,type:impassable',
            %w[E2 C6 D5 E8 E10 F3 G6 H9 J9 J11] =>
            'upgrade=cost:20,terrain:desert',
            %w[D3 M10] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[D9 H11 N7 T11 T13] => 'upgrade=cost:20,terrain:water',
            %w[F11 G4 H7 K10 L7 M8 R9] => '',
            %w[G10] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[I4] => 'city=revenue:0;upgrade=cost:20,terrain:water;future_label=label:L,color:green',
            %w[O8] => 'city=revenue:0;upgrade=cost:20,terrain:water;future_label=label:G,color:brown',
            %w[G12 K12] => 'upgrade=cost:40,terrain:swamp',
            %w[I8 I10] => 'city=revenue:0',
            %w[J5 L9 P7] => 'town=revenue:0',
            ['J7'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            ['K8'] => 'town=revenue:0;upgrade=cost:20,terrain:desert',
            ['K6'] =>
            'city=revenue:20,loc:center;town=revenue:10,loc:1;path=a:_1,b:_0;upgrade=cost:20,terrain:water;label=M',
            ['M12'] =>
            'city=revenue:20,loc:center;town=revenue:10,loc:4;path=a:_0,b:_1;upgrade=cost:40,terrain:swamp;label=T',
            ['P13'] =>
            'city=revenue:0,loc:center;town=revenue:0,loc:5;upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable;label=V',
            ['S10'] => 'town=revenue:0;upgrade=cost:120,terrain:mountain',
            ['S12'] => 'city=revenue:20;path=a:4,b:_0;upgrade=cost:20,terrain:water',
          },
          yellow: {
            ['E6'] => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
            ['O10'] => 'city=revenue:20,loc:center;town=revenue:0,loc:2;path=a:3,b:_0;path=a:5,b:_0;'\
                       'border=edge:4,type:impassable;label=MC;border=edge:5',
            ['P11'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;upgrade=cost:60,terrain:mountain;'\
                       'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:3,type:impassable;label=P;'\
                       'border=edge:2',
            ['R13'] => 'path=a:1,b:4;upgrade=cost:60,terrain:mountain',
          },
        }.freeze

        LAYOUT = :flat

        AXES = { x: :number, y: :letter }.freeze
      end
    end
  end
end
