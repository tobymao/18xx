# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Map
        LAYOUT = :pointy

        TILES = {
          # yellow
          '5' => 4,
          '6' => 7,
          '7' => 4,
          '8' => 13,
          '9' => 12,
          '57' => 6,
          '235' => 3,
          '401' => 2,
          '447' => 2,
          '8850' => 3,
          '8851' => 7,
          '8852' => 7,
          '8854' => 1,
          '8855' => 1,
          '8856' => 1,
          '8857' => 1,
          '8858a' =>
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
          '8858' => 1,
          '8862' => 1,
          '8863' => 1,
          '8864' => 1,
          '8865' => 1,
          '8866' => 3,
          '887' => 5,
          '888' => 5,
          'L141' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;'\
                        'path=a:1,b:_1;path=a:4,b:_1;label=00',
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
          '611' => 3,
          '8871' => 2,
          '8872' => 3,
          '8874' => 3,
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

          # red
          'Sib' =>
            {
              'count' => 1,
              'color' => 'red',
              'code' => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;'\
                        'path=a:1,b:_0,terminal:1;label=S',
            },
        }.freeze

        LOCATION_NAMES = {
          'A6' => 'Satu Mare',
          'A10' => 'Sighetu Marmației',
          'A16' => 'Cernăuți',
          'B3' => 'Viena / Budapešta',
          'B9' => 'Baia Mare',
          'B15' => 'Rădăuți',
          'B17' => 'Botoșani / Suceava',
          'B21' => 'Moskova',
          'C4' => 'Oradea',
          'C6' => 'Margita / Simleu',
          'C8' => 'Zalău',
          'C10' => 'Dej',
          'C12' => 'Bistrița',
          'C16' => 'Piatra',
          'C20' => 'Iași',
          'D9' => 'Cluj-Napoca',
          'D11' => 'Târgu Mureș',
          'D19' => 'Bacău',
          'D21' => 'Vaslui',
          'D23' => 'Chișinău',
          'E0' => 'Sinnicolau Mare',
          'E2' => 'Arad',
          'E10' => 'Turda',
          'E12' => 'Mediaș',
          'E16' => 'Miercurea Ciuc / Târgu Ocna',
          'E18' => 'Onești',
          'E20' => 'Bârlad',
          'F3' => 'Timișoara',
          'F7' => 'Deva / Hunedoara',
          'F9' => 'Alba Iulia',
          'F11' => 'Sibiu',
          'F13' => 'Făgăraș',
          'F15' => 'Brașov / Sfântu Gheorghe',
          'F19' => 'Focșani',
          'G4' => 'Reșița',
          'G14' => 'Câmpulung',
          'G22' => 'Galați / Brăila',
          'G24' => 'Tulcea',
          'H1' => 'Belgrad',
          'H3' => 'Oravița / Moldova Veche',
          'H7' => 'Petroșani / Târgu Jiu',
          'H11' => 'Râmnicu Vâlcea',
          'H13' => 'Pitești',
          'H15' => 'Târgoviște / Ploiești',
          'H19' => 'Buzău',
          'H25' => 'Odesa',
          'I6' => 'Drobeta-Turnu Severin',
          'I16' => 'București',
          'I20' => 'Slobozia / Fetești',
          'I24' => 'Năvodari',
          'J9' => 'Craiova',
          'J11' => 'Slatina',
          'J19' => 'Călărași',
          'J23' => 'Constanța',
          'J25' => 'Marea Neagră',
          'K6' => 'Sofia',
          'K8' => 'Băilești',
          'K14' => 'Alexandria',
          'K16' => 'Giurgiu',
          'K18' => 'Istanbul',
          'K22' => 'Varna',
        }.freeze

        HEXES = {
          white: {
            # no cities or towns
            %w[A8 A18 B5 B7 B19 C18 D3 D5 E4 E22 F1 F5 F21 G2 G20 H17 H23 I8 I10 I12 I14 I18 J7 J13 J15 J17 K10 K12] => '',
            %w[B11 B13 D17 E6 E8] => 'upgrade=cost:40,terrain:mountain',
            ['C14'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:province;border=edge:5,type:province',
            ['D7'] => 'upgrade=cost:30,terrain:mountain',
            ['D13'] => 'upgrade=cost:30,terrain:mountain;border=edge:4,type:province',
            ['D15'] => 'upgrade=cost:40,terrain:mountain;border=edge:0,type:province;'\
                       'border=edge:1,type:province;border=edge:2,type:province',
            ['E14'] => 'upgrade=cost:20,terrain:mountain;border=edge:3,type:province;border=edge:4,type:province',
            ['F17'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:province;',
            ['G6'] => 'upgrade=cost:40,terrain:mountain;border=edge:5,type:province',
            ['G8'] => 'upgrade=cost:30,terrain:mountain;border=edge:0,type:province;'\
                      'border=edge:4,type:province;border=edge:5,type:province',
            ['G10'] => 'upgrade=cost:20,terrain:mountain;border=edge:1,type:province;'\
                       'border=edge:2,type:province;border=edge:3,type:province',
            ['G12'] => 'upgrade=cost:20,terrain:mountain;border=edge:2,type:province;border=edge:3,type:province',
            ['G16'] => 'upgrade=cost:30,terrain:mountain;border=edge:2,type:province',
            ['G18'] => 'upgrade=cost:20,terrain:mountain',
            ['H5'] => 'border=edge:4,type:province;border=edge:5,type:province',
            ['H9'] => 'border=edge:2,type:province',
            %w[H21 I22] => 'upgrade=cost:20,terrain:water',
            ['I4'] => 'border=edge:4,type:province;',
            ['J21'] => 'upgrade=cost:10,terrain:water',

            # town
            %w[D21 E20 I24 J11 K14] => 'town=revenue:0',
            %w[E10 E12] => 'town=revenue:0;upgrade=cost:10,terrain:mountain',
            %w[A10 E18] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B15] => 'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:3,type:province;'\
                       'border=edge:4,type:province;border=edge:5,type:province',
            ['C10'] => 'town=revenue:0;upgrade=cost:10,terrain:mountain',
            ['C12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            ['F13'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:0,type:province;border=edge:5,type:province',
            ['G14'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:2,type:province;border=edge:3,type:province',
            ['I6'] => 'town=revenue:0;upgrade=cost:10,terrain:mountain;border=edge:1,type:province;border=edge:2,type:province',
            %w[K8 K16] => 'town=revenue:0;icon=image:port',

            # double towns
            %w[C6 I20] => 'town=revenue:0;town=revenue:0',
            %w[E16] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain;'\
                       'border=edge:0,type:province;border=edge:1,type:province',
            ['F7'] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:mountain',
            ['H3'] => 'town=revenue:0;town=revenue:0;icon=image:port',

            # city
            %w[C4 C20 D9 D11 D19 E2 F3 H13 H19 J9 J23] => 'city=revenue:0',
            ['A6'] => 'city=revenue:0;label=T',
            ['A16'] => 'city=revenue:0;border=edge:0,type:province;label=T',
            ['C16'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:1,type:province;border=edge:2,type:province',
            ['F11'] => 'city=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:0,type:province;'\
                       'border=edge:5,type:province;label=S',
            ['G24'] => 'city=revenue:0;label=T;icon=image:port',

            # double city
            ['F15'] => 'city=revenue:0;city=revenue:0;upgrade=cost:30,terrain:mountain;'\
                       'border=edge:0,type:province;border=edge:3,type:province;'\
                       'border=edge:4,type:province;border=edge:5,type:province',
            ['G22'] => 'city=revenue:0;city=revenue:0;upgrade=cost:10,terrain:water;icon=image:port',
            ['H15'] => 'city=revenue:0;city=revenue:0',
            ['I16'] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:4,b:_1;label=B',

            # town and city
            %w[B9 C8 H11] => 'town=revenue:0;city=revenue:0',
            ['F9'] => 'town=revenue:0;city=revenue:0;upgrade=cost:10,terrain:mountain;border=edge:5,type:province',
            ['F19'] => 'town=revenue:0;city=revenue:0;upgrade=cost:30,terrain:mountain',
            ['G4'] => 'town=revenue:0;city=revenue:0;upgrade=cost:40,terrain:mountain',
            ['J19'] => 'town=revenue:0;city=revenue:0;icon=image:port',

            # double town and city
            ['B17'] => 'town=revenue:0;town=revenue:0;city=revenue:0;city=revenue:0;border=edge:1,type:province',
            ['H7'] => 'town=revenue:0;town=revenue:0;city=revenue:0;city=revenue:0;upgrade=cost:20,terrain:mountain;'\
                      'border=edge:1,type:province;border=edge:2,type:province;border=edge:3,type:province',

          },
          gray: {
            ['E0'] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
          },
          red: {
            ['B3'] => 'city=revenue:yellow_20|green_30|brown_50|gray_70;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['B21'] => 'city=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['D23'] => 'city=revenue:yellow_20|green_50|brown_30|gray_40;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['H1'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['K6'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['K18'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_50;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;'\
                       'path=a:3,b:_0,terminal:1',
            ['K22'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
          },
          blue: {
            ['H25'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['J25'] => 'city=revenue:yellow_20|green_30|brown_40|gray_40;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
        }.freeze
      end
    end
  end
end
