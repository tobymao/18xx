# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Map
        LAYOUT = :pointy

        TILES = {
          # yellow
          '5' => 5,
          '6' => 7,
          '7' => 5,
          '8' => 13,
          '9' => 13,
          '57' => 6,
          '235' => 3,
          '401' => 2,
          '447' => 2,
          '8850' => 4,
          '8851' => 7,
          '8852' => 7,
          '8854' => 1,
          '8855' => 1,
          '8856' => 1,
          '8857' => 1,
          '8858' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1',
            },
          'L148' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;label=B',
            },

          'L152' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:20;town=revenue:20;path=a:4,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1',
            },
          'L153' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0;path=a:4,b:_0;path=a:2,b:_1;path=a:3,b:_1',
            },
          'L154' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:20;town=revenue:20;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1',
            },

          # green
          '14' => 5,
          '15' => 5,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '405' => 3,
          '619' => 5,
          '8858a' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
            },
          '8862' => 1,
          '8863' => 1,
          '8864' => 1,
          '8865' => 1,
          '8866' => 3,
          '887' => 5,
          '888' => 3,
          'L141' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;'\
                        'path=a:1,b:_1;path=a:4,b:_1;label=OO',
            },
          'L149' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'path=a:4,b:_1;path=a:5,b:_1;path=a:0,b:_1;label=B',
            },

          # brown
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '63' => 6,
          '70' => 1,
          '497' => 2,
          '611' => 2,
          '8871' => 2,
          '8872' => 3,
          '8873' => 3,
          'L150' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },

          # gray
          '51' => 1,
          '123a' => 1,
          '455' => 2,
          '494' => 1,
          '895' => 2,
          '915' => 1,
          'L151' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
            },
        }.freeze

        LOCATION_NAMES = {
          'A7' => 'Satu Mare',
          'A11' => 'Sighetu Marmației',
          'A17' => 'Cernăuți',
          'B4' => 'Viena / Budapešta',
          'B10' => 'Baia Mare',
          'B16' => 'Rădăuți',
          'B18' => 'Botoșani / Suceava',
          'B22' => 'Moskova',
          'C5' => 'Oradea',
          'C7' => 'Margita / Simleu',
          'C9' => 'Zalău',
          'C11' => 'Dej',
          'C13' => 'Bistrița',
          'C17' => 'Piatra',
          'C21' => 'Iași',
          'D10' => 'Cluj-Napoca',
          'D12' => 'Târgu Mureș',
          'D20' => 'Bacău',
          'D22' => 'Vaslui',
          'D24' => 'Chișinău',
          'E1' => 'Sinnicolau Mare',
          'E3' => 'Arad',
          'E11' => 'Turda',
          'E13' => 'Mediaș',
          'E17' => 'Miercurea Ciuc / Târgu Ocna',
          'E19' => 'Onești',
          'E21' => 'Bârlad',
          'F4' => 'Timișoara',
          'F8' => 'Deva / Hunedoara',
          'F10' => 'Alba Iulia',
          'F12' => 'Sibiu',
          'F14' => 'Făgăraș',
          'F16' => 'Brașov / Sfântu Gheorghe',
          'F20' => 'Focșani',
          'G5' => 'Reșița',
          'G15' => 'Câmpulung',
          'G23' => 'Galați / Brăila',
          'G25' => 'Tulcea',
          'H2' => 'Belgrad',
          'H4' => 'Oravița / Moldova Veche',
          'H8' => 'Petroșani / Târgu Jiu',
          'H12' => 'Râmnicu Vâlcea',
          'H14' => 'Pitești',
          'H16' => 'Târgoviște / Ploiești',
          'H20' => 'Buzău',
          'H26' => 'Odesa',
          'I7' => 'Drobeta-Turnu Severin',
          'I17' => 'București',
          'I21' => 'Slobozia / Fetești',
          'I25' => 'Năvodari',
          'J10' => 'Craiova',
          'J12' => 'Slatina',
          'J20' => 'Călărași',
          'J24' => 'Constanța',
          'J26' => 'Marea Neagră',
          'K7' => 'Sofia',
          'K9' => 'Băilești',
          'K15' => 'Alexandria',
          'K17' => 'Giurgiu',
          'K19' => 'Istanbul',
          'K23' => 'Varna',
        }.freeze

        BORDERS = {
          'A17' => [0],
          'B16' => [3, 4, 5],
          'B18' => [1],
          'C15' => [4, 5],
          'C17' => [1, 2],
          'D14' => [4],
          'D16' => [0, 1, 2],
          'E15' => [3, 4],
          'E17' => [0, 1],
          'F10' => [5],
          'F12' => [0, 5],
          'F14' => [0, 5],
          'F16' => [0, 3, 4, 5],
          'F18' => [1],
          'G7' => [5],
          'G9' => [0, 4, 5],
          'G11' => [1, 2, 3],
          'G13' => [2, 3],
          'G15' => [2, 3],
          'G17' => [2],
          'H6' => [4, 5],
          'H8' => [1, 2, 3],
          'H10' => [2],
          'I5' => [4],
          'I7' => [1, 2],
        }.freeze

        KINGDOM_OF_ROMANIA_HEXES = {
          white: {
            %w[A19 B20 C19 E23 F22 G21 H18 H24 I9 I11 I13 I15 I19 J8 J14 J16 J18 K11 K13 H10] => '',
            %w[D18 D16 F18] => 'upgrade=cost:40,terrain:mountain',
            %w[G11 G13 G19] => 'upgrade=cost:20,terrain:mountain',
            ['G17'] => 'upgrade=cost:30,terrain:mountain',
            %w[H22 I23] => 'upgrade=cost:20,terrain:water',
            ['J22'] => 'upgrade=cost:10,terrain:water',
            %w[D22 E21 I25 J12 K15] => 'town=revenue:0',
            ['E19'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['G15'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
            %w[K9 K17] => 'town=revenue:0;icon=image:port',
            ['I21'] => 'town=revenue:0;town=revenue:0',
            ['E17'] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[C21 D20 H14 H20 J10 J24] => 'city=revenue:0',
            ['A17'] => 'city=revenue:0;label=T',
            ['C17'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            ['G25'] => 'city=revenue:0;label=T;icon=image:port',
            ['G23'] => 'city=revenue:0;city=revenue:0;upgrade=cost:10,terrain:water;icon=image:port',
            ['H16'] => 'city=revenue:0;city=revenue:0',
            ['I17'] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:4,b:_1;label=B',
            ['H12'] => 'town=revenue:0;city=revenue:0',
            ['F20'] => 'town=revenue:0;city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['J20'] => 'town=revenue:0;city=revenue:0;icon=image:port',
            ['B18'] => 'town=revenue:0;town=revenue:0;city=revenue:0;city=revenue:0',
          },
          red: {
            ['B22'] => 'city=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0,terminal:1;'\
                       'path=a:1,b:_0,terminal:1',
            ['D24'] => 'city=revenue:yellow_20|green_50|brown_30|gray_40;path=a:0,b:_0,terminal:1;'\
                       'path=a:1,b:_0,terminal:1',
            ['K7'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0,terminal:1;'\
                      'path=a:4,b:_0,terminal:1',
            ['K19'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_50;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['K23'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0,terminal:1;'\
                       'path=a:3,b:_0,terminal:1',
          },
          blue: {
            ['H26'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1',
            ['J26'] => 'city=revenue:yellow_20|green_30|brown_40|gray_40;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1',
          },
        }.freeze

        TRANSYLVANIA_HEXES = {
          white: {
            %w[A9 B6 B8 D4 D6 E5 F2 F6 G3 H6] => '',
            %w[B12 B14 E7 E9 C15 G7] => 'upgrade=cost:40,terrain:mountain',
            %w[D8 D14 G9] => 'upgrade=cost:30,terrain:mountain',
            ['E15'] => 'upgrade=cost:20,terrain:mountain',
            %w[E11 E13 C11] => 'town=revenue:0;upgrade=cost:10,terrain:mountain',
            ['A11'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[C13 F14] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            ['C7'] => 'town=revenue:0;town=revenue:0',
            ['F8'] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:mountain',
            ['H4'] => 'town=revenue:0;town=revenue:0;icon=image:port',
            %w[C5 D10 D12 E3 F4] => 'city=revenue:0',
            ['A7'] => 'city=revenue:0;label=T',
            ['F12'] => 'city=revenue:0;upgrade=cost:20,terrain:mountain',
            %w[B10 C9] => 'town=revenue:0;city=revenue:0',
            ['F10'] => 'town=revenue:0;city=revenue:0;upgrade=cost:20,terrain:mountain',
            ['G5'] => 'town=revenue:0;city=revenue:0;upgrade=cost:40,terrain:mountain',
          },
          gray: {
            ['E1'] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
          },
          red: {
            ['B4'] => 'city=revenue:yellow_20|green_30|brown_50|gray_70;path=a:4,b:_0,terminal:1;'\
                      'path=a:5,b:_0,terminal:1',
            ['H2'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0,terminal:1;'\
                      'path=a:4,b:_0,terminal:1',
          },
        }.freeze

        FULL_MAP_HEXES = {
          white: {
            ['I5'] => '',
            ['B16'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['I7'] => 'town=revenue:0;upgrade=cost:10,terrain:mountain',
            ['F16'] => 'city=revenue:0;city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['H8'] => 'town=revenue:0;town=revenue:0;city=revenue:0;city=revenue:0;upgrade=cost:20,terrain:mountain',
          },
        }.freeze
      end
    end
  end
end
