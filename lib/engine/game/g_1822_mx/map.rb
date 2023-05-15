# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'

module Engine
  module Game
    module G1822MX
      module Map
        LOCATION_NAMES = {
          'A2' => 'San Diego',
          'B1' => 'Tijuana',
          'B3' => 'Mexicali',
          'C2' => 'Ensenada',
          'C8' => 'Tucson',
          'C14' => 'El Paso',
          'D3' => 'San Quintin',
          'D9' => 'Nogales',
          'D13' => 'Casas Grandes',
          'D15' => 'Ciudad Juarez',
          'E8' => 'Hermosillo',
          'F5' => 'Guerrero Negro',
          'F9' => 'Guaymas',
          'F13' => 'Cuauhtemoc',
          'F15' => 'Chihuahua',
          'F21' => 'Piedras Negras',
          'F23' => 'San Antonio',
          'G6' => 'Santa Rosalia',
          'G10' => 'Ciudad Obregon',
          'G16' => 'Jimenez',
          'G22' => 'Nuevo Laredo',
          'G24' => 'Houston',
          'H7' => 'Lorento',
          'H11' => 'Los Mochis',
          'I12' => 'Culiacan',
          'I18' => 'Torreon',
          'I22' => 'Monterrey',
          'J9' => 'La Paz',
          'J13' => 'Mazatlan',
          'J15' => 'Durango',
          'J23' => 'Ciudad Victoria',
          'K18' => 'Zacatecas',
          'K20' => 'San Luis Potosi',
          'K24' => 'Tampico',
          'L15' => 'Tepic',
          'L17' => 'Guadalajara',
          'L19' => 'Guanajuanto Leon',
          'L37' => 'Merida',
          'L39' => 'Cancun',
          'M14' => 'Puerto Vallarta',
          'M22' => 'Queretaro Toluca',
          'M24' => 'Pachuca',
          'M26' => 'Poza Rica Jalapa',
          'M36' => 'Campeche',
          'N17' => 'Manzanillo',
          'N23' => 'Mexico City',
          'N25' => 'Tlaxcala Puebla',
          'N27' => 'Veracruz',
          'N33' => 'Ciudad del Carmen',
          'N39' => 'Chetumal',
          'O20' => 'Lazaro Cardenas',
          'O22' => 'Chilpancingo',
          'O32' => 'Villahermosa',
          'P23' => 'Acapulco',
          'P27' => 'Oaxaca',
          'P31' => 'Tuxtla Gutierrez',
          'Q34' => 'Guatemala',
        }.freeze
        HEXES_HIDE_LOCATION_NAMES = { 'N23' => true }.freeze

        LAYOUT = :pointy

        HEXES = {
          white: {
            %w[B5 C4 C6 D7 D11 E4 E10 E14 E16 F19 G4 G20 H21 H23 H25 I8 I24 K14 L25 M16 M38 N15 N35 N37
               O18 O28 P29 P33 Q32] =>
              '',

            %w[J25 L23 M18 N19 O26 O30 O34 P25] =>
              'upgrade=cost:20,terrain:river',
            ['N21'] =>
              'upgrade=cost:20,terrain:river;stub=edge:4',
            %w[F11 F17 G12 G18 H17 H19 I14 I20] =>
              'upgrade=cost:40,terrain:hill',
            %w[E12 H15 I16 J19 J21 L21] =>
              'upgrade=cost:80,terrain:mountain',
            ['O24'] =>
              'upgrade=cost:80,terrain:mountain;stub=edge:2',
            %w[H13 J17 K16 M20] =>
              'upgrade=cost:40,terrain:hill;upgrade=cost:20,terrain:river',
            %w[G14 K22] =>
              'upgrade=cost:80,terrain:mountain;upgrade=cost:20,terrain:river',
            ['O36'] =>
              'border=edge:0,type:impassable',
            ['P35'] =>
              'border=edge:3,type:impassable',

            %w[C2 D3 D13 F5 F9 G10 H7 I12 M14 M36 N17 N39 O20 P31] =>
              'town=revenue:0',
            %w[J23 L15 N33] =>
              'town=revenue:0;upgrade=cost:20,terrain:river',
            ['O22'] =>
              'town=revenue:0;upgrade=cost:20,terrain:river;stub=edge:3',
            ['M24'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill;stub=edge:0',
            ['G16'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill;upgrade=cost:20,terrain:river',
            ['K18'] =>
              'town=revenue:0;upgrade=cost:80,terrain:mountain',

            %w[B3 D9 D15 E8 F13 G6 G22 J13 J15 K20 N27 O32 P27] =>
              'city=revenue:0',
            %w[B1 J9 L37 L39 P23] =>
              'city=revenue:0;future_label=label:T,color:green',
            %w[F15 H11 K24] =>
              'city=revenue:0;upgrade=cost:20,terrain:river',
            ['I18'] =>
              'city=revenue:0;upgrade=cost:40,terrain:hill',

            ['M26'] =>
              'town=revenue:0;town=revenue:0',
            ['M22'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:hill;upgrade=cost:20,terrain:river;stub=edge:5',

            ['N23'] =>
              'city=revenue:20,groups:MexicoCity;city=revenue:20,groups:MexicoCity;city=revenue:20,groups:MexicoCity;'\
              'city=revenue:20,groups:MexicoCity;city=revenue:20,groups:MexicoCity;city=revenue:20,groups:MexicoCity;'\
              'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;'\
              'label=MC',
          },
          yellow: {
            ['F21'] =>
              'city=revenue:30,slots:1;path=a:1,b:_0;path=a:5,b:_0;label=Y',
            ['I22'] =>
              'city=revenue:30,slots:1;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            ['L17'] =>
              'city=revenue:30,slots:1;path=a:2,b:_0;path=a:5,b:_0;upgrade=cost:40,terrain:hill;'\
              'upgrade=cost:20,terrain:river;label=Y',
            ['L19'] =>
              'city=revenue:30,slots:1;city=revenue:30,slots:1;'\
              'path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_1;path=a:4,b:_1;'\
              'upgrade=cost:80,terrain:mountain;label=Y',
          },
          green: {
            ['N25'] =>
              'city=revenue:30,slots:1;city=revenue:30,slots:1;city=revenue:30,slots:1;'\
              'path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:4,b:_1;path=a:3,b:_2;'\
              'label=Y',
            %w[C16 E22] =>
              'junction;path=a:0,b:_0,terminal:1',
          },
          gray: {
            ['A2'] =>
              'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['C8'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['C14'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['F23'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:1;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['G24'] =>
              'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['Q34'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
          blue: {
            ['H5'] =>
              'junction;path=a:3,b:_0,terminal:1',
            ['J7'] =>
              'junction;path=a:4,b:_0,terminal:1',
            ['M28'] =>
              'junction;path=a:0,b:_0,terminal:1',
            %w[M40 Q28] =>
              'junction;path=a:2,b:_0,terminal:1',
            ['F7'] =>
              'junction;path=a:3,b:_0,terminal:1;path=a:3,b:5,track:thin',
            ['G8'] =>
              'junction;path=a:1,b:_0,terminal:1;path=a:1,b:2,track:thin;path=a:1,b:5,track:thin',
            ['H9'] =>
              'junction;path=a:4,b:_0,terminal:1;path=a:2,b:4,track:thin;path=a:4,b:5,track:thin',
            ['I10'] =>
              'junction;path=a:0,b:_0,terminal:1;path=a:0,b:2,track:thin;path=a:0,b:5,track:thin',
            ['J11'] =>
              'junction;path=a:4,b:_0,terminal:1;path=a:2,b:4,track:thin',
          },
        }.freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 6,
          '4' => 11,
          '5' => 6,
          '6' => 8,
          '7' => 6,
          '8' => 24,
          '9' => 24,
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '58' => 6,
          '69' => 1,
          '14' => 4,
          '15' => 6,
          '80' => 4,
          '81' => 6,
          '82' => 7,
          '83' => 7,
          '141' => 3,
          '142' => 3,
          '143' => 2,
          '144' => 3,
          '207' => 3,
          '208' => 2,
          '619' => 5,
          '622' => 2,
          '63' => 3,
          '544' => 4,
          '545' => 4,
          '546' => 4,
          '611' => 7,
          '60' => 2,
          '455' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X20' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=MC',
            },
          '405' =>
            {
              'count' => 3,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X21' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=MC',
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
              'count' => 4,
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
          'X22' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=MC',
            },
          '169' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X10' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X11' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            },
          'X16' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
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
              'count' => 3,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X23' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;'\
                'city=revenue:100;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;'\
                'path=a:5,b:_5;label=MC',
            },
          'P1' =>
            {
              'count' => 1,
              'color' => 'blue',
              'code' =>
                'city=revenue:yellow_30|green_40,slots:0;path=a:0,b:_0,terminal:1',
            },
          'P2' =>
            {
              'count' => 1,
              'color' => 'blue',
              'code' =>
                'city=revenue:green_40|brown_50|gray_60,slots:0;path=a:0,b:_0,terminal:1',
            },

          'BC' =>
            {
              'count' => 1,
              'color' => 'white',
              'code' => 'icon=image:1822_mx/red_cube,large:1',
              'hidden' => true,
            },

        }.freeze
      end
    end
  end
end
