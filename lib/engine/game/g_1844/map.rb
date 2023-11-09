# frozen_string_literal: true

module Engine
  module Game
    module G1844
      module Map
        TILES = {
          '3' => 3,
          '4' => 6,
          '5' => 5,
          '6' => 6,
          '7' => 5,
          '8' => 11,
          '9' => 11,
          '14' => 4,
          '15' => 7,
          '16' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 6,
          '24' => 6,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 6,
          '58' => 6,
          '59' => 2,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
          '87' => 2,
          '88' => 2,
          '204' => 2,
          '611' => 6,
          '619' => 4,
          '901' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;'\
                      'path=a:3,b:_1;label=L',
          },
          '902' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
          '903' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=L',
          },
          '904' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
          '905' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=B',
          },
          '906' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=B',
          },
          '907' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Z',
          },
          '908' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Z',
          },
          '909' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Z',
          },
          '910' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'label=Z',
          },
          '911' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '915' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'XM1' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'offboard=revenue:yellow_10|green_20|brown_50|gray_80',
          },
          'XM2' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'offboard=revenue:yellow_10|green_40|brown_50|gray_60',
          },
          'XM3' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'offboard=revenue:yellow_10|green_50|brown_80|gray_10',
          },
          'X78' => {
            'count' => 5,
            'color' => 'purple',
            'code' => 'path=a:0,b:2,track:narrow',
          },
          'X79' => {
            'count' => 5,
            'color' => 'purple',
            'code' => 'path=a:0,b:3,track:narrow',
          },
          'OP1' => {
            'count' => 1,
            'hidden' => true,
            'color' => 'purple',
            'code' => 'path=a:3,b:5',
          },
          'OP2' => {
            'count' => 3,
            'hidden' => true,
            'color' => 'purple',
            'code' => 'path=a:1,b:4',
          },
          'OP3' => {
            'count' => 1,
            'hidden' => true,
            'color' => 'purple',
            'code' => 'town=revenue:10,loc:4;path=a:0,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A18' => 'Stuttgart',
          'B11' => 'Strasbourg',
          'B19' => 'Schaffhausen',
          'B23' => 'Rorschach',
          'C8' => 'Belfort',
          'C12' => 'Basel',
          'C14' => 'Liestal',
          'C20' => 'Winterthur & Frauenfeld',
          'C24' => 'Sankt Gallen',
          'C26' => 'München',
          'D13' => 'Olten',
          'D15' => 'Aarau',
          'D17' => 'Baden',
          'D19' => 'Zurich',
          'D21' => 'Rapperswil',
          'D25' => 'Appelzell',
          'E8' => 'Biel',
          'E10' => 'Solothurn',
          'E18' => 'Zug',
          'E26' => 'Vaduz',
          'F3' => 'Dijon/Paris',
          'F7' => 'Neuchatel',
          'F11' => 'Bern',
          'F13' => 'Langnau',
          'F17' => 'Lucerne',
          'F19' => 'Rigi-Bahnen',
          'F21' => 'Goldau',
          'F25' => 'Sargans',
          'G8' => 'Romont & Fribourg',
          'G14' => 'Pilatus Bahn',
          'G16' => 'Sarnen',
          'G18' => 'Stans',
          'G20' => 'Altdorf',
          'G26' => 'Chur',
          'G28' => 'Arosa',
          'H3' => 'Yverdon',
          'H7' => 'Rochers de Naye',
          'H13' => 'Thun',
          'H17' => 'Andermatt',
          'H19' => 'Gotthard',
          'H21' => 'Lukmanier',
          'H25' => 'Disentis',
          'H27' => 'Albula',
          'H29' => 'Innsbruck',
          'I4' => 'Lausanne',
          'I6' => 'Montreux',
          'I10' => 'Gstaad',
          'I12' => 'Lötschberg',
          'I14' => 'Jungfraubahnen',
          'I28' => 'St. Moritz',
          'J1' => 'Nyon',
          'J11' => 'Visp',
          'J13' => 'Brig',
          'J29' => 'Bernina',
          'K2' => 'Genève',
          'K8' => 'Martigny',
          'K10' => 'Sion',
          'K14' => 'Simplon',
          'K20' => 'Locarno',
          'K22' => 'Bellinzona',
          'L1' => 'Lyon',
          'L11' => 'Zermatt',
          'L13' => 'Matterhornbahnen',
          'L21' => 'Como',
          'L23' => 'Monte Generoso',
          'M8' => 'Torino',
          'M18' => 'Milano',
        }.freeze

        HEXES = {
          red: {
            ['A18'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_70,groups:Stuttgart|N;path=a:5,b:_0;border=edge:0;'\
                       'border=edge:4;label=N;icon=image:1844/bonus_30',
            ['A20'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_70,groups:Stuttgart|N,hide:1;path=a:0,b:_0;'\
                       'path=a:5,b:_0;border=edge:1',
            ['B11'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60,groups:N;path=a:0,b:_0;path=a:5,b:_0;label=N;'\
                       'icon=image:1844/bonus_30',
            ['B17'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_70,groups:Stuttgart|N,hide:1;path=a:4,b:_0;'\
                       'border=edge:3',
            ['C8'] => 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:W;path=a:0,b:_0;path=a:4,b:_0;label=W;'\
                      'icon=image:1844/bonus_50',
            ['C26'] => 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:E;path=a:0,b:_0;path=a:1,b:_0;label=E;'\
                       'icon=image:1844/bonus_50',
            ['F3'] => 'offboard=revenue:yellow_10|green_30|brown_50|gray_70,groups:W;path=a:4,b:_0;path=a:5,b:_0;label=W;'\
                      'icon=image:1844/bonus_50',
            ['G30'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80,groups:Innsbruck|E,hide:1;path=a:1,b:_0;'\
                       'border=edge:0',
            ['H29'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80,groups:Innsbruck|E;path=a:0,b:_0;path=a:1,b:_0;'\
                       'path=a:2,b:_0;border=edge:3;border=edge:5;label=E;icon=image:1844/bonus_90',
            ['I30'] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80,groups:Innsbruck|E,hide:1;path=a:1,b:_0;'\
                       'border=edge:2',
            ['L1'] => 'offboard=revenue:yellow_30|green_50|brown_70|gray_90,groups:W;path=a:3,b:_0;label=W;'\
                      'icon=image:1844/bonus_90',
            ['L15'] => 'offboard=revenue:yellow_40|green_50|brown_70|gray_90,groups:Milano|S,hide:1;path=a:2,b:_0;border=edge:5',
            ['M8'] => 'offboard=revenue:yellow_0|green_30|brown_50|gray_70,groups:S;path=a:2,b:_0;path=a:3,b:_0;label=S;'\
                      'icon=image:1844/bonus_40',
            ['M16'] => 'border=edge:2;border=edge:4',
            ['M18'] => 'offboard=revenue:yellow_40|green_50|brown_70|gray_90,groups:Milano|S;border=edge:1;border=edge:4;'\
                       'label=S;icon=image:1844/bonus_40',
            ['M20'] => 'offboard=revenue:yellow_40|green_50|brown_70|gray_90,groups:Milano|S,hide:1;path=a:3,b:_0;'\
                       'border=edge:1;border=edge:4',
            ['M22'] => 'offboard=revenue:yellow_40|green_50|brown_70|gray_90,groups:Milano|S,hide:1;path=a:2,b:_0;border=edge:1',
          },
          gray: {
            ['E26'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:5,b:_0',
            ['F19'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:4,b:_0',
            ['G14'] => 'offboard=revenue:0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                       'path=a:4,b:_0;path=a:5,b:_0',
            ['G20'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['H7'] => 'offboard=revenue:0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0',
            ['I14'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['J13'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
            ['J17'] => 'path=a:1,b:2',
            ['J29'] => 'offboard=revenue:0;path=a:2,b:_0',
            ['K2'] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0',
            ['L13'] => 'offboard=revenue:0;path=a:1,b:_0;path=a:2,b:_0;border=edge:3,type:impassable',
            ['L23'] => 'offboard=revenue:0;path=a:1,b:_0;path=a:2,b:_0',
          },
          white: {
            %w[B21 C10 C18 E14 E16 E24 F27 G12 I2] => 'blank',
            %w[C16 E12 E22] => 'upgrade=cost:20,terrain:river',
            %w[C22 D7 D9 D11 D23 E6 F15 H15 I8 J7] => 'upgrade=cost:30,terrain:mountain',
            %w[F23 G10 G24 H9 H11 I22 I24 I26 J19 J21 J23 J27 K6 K12 L7 L9] => 'upgrade=cost:60,terrain:mountain',
            %w[G22 I20] => 'upgrade=cost:90,terrain:mountain',
            %w[B23 C14 D17 G16] => 'town=revenue:0',
            %w[E10 F25 J1 K8] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[F13 H3 L11] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[C24 D25 G18] => 'city=revenue:0',
            %w[B19 C12 D13 E18 H13 K10 K20 K22] => 'city=revenue:0;upgrade=cost:20,terrain:river',
            %w[F21 G28 I28] => 'city=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[G26 L21] => 'city=revenue:10;path=a:0,b:_0;upgrade=cost:20,terrain:river',
            ['D19'] => 'city=revenue:0;upgrade=cost:20,terrain:river;border=edge:5,type:impassable;' \
                       'future_label=label:Z,color:green',
            ['D21'] => 'town=revenue:0;border=edge:0,type:impassable',
            ['E8'] => 'town=revenue:0;border=edge:5,type:impassable',
            ['E20'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['F5'] => 'border=edge:5,type:impassable',
            ['F7'] => 'city=revenue:10;path=a:1,b:_0;upgrade=cost:20,terrain:river',
            ['F9'] => 'upgrade=cost:20,terrain:river;border=edge:2,type:impassable',
            ['F11'] => 'city=revenue:10;path=a:5,b:_0;future_label=label:B,color:green',
            ['F17'] => 'city=revenue:10;path=a:1,b:_0;upgrade=cost:20,terrain:river',
            ['G4'] => 'border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['G6'] => 'border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['H5'] => 'upgrade=cost:30,terrain:mountain;border=edge:2,type:impassable',
            ['H25'] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            ['I6'] => 'city=revenue:0;upgrade=cost:20,terrain:river',
            ['I10'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain' \
                       ';border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['I18'] => 'upgrade=cost:90,terrain:mountain;border=edge:1,type:impassable;border=edge:3,type:impassable',
            ['J11'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain' \
                       ';border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['J15'] => 'upgrade=cost:60,terrain:mountain;border=edge:0,type:impassable',
          },
          yellow: {
            %w[C20 G8] => 'city=revenue:0;city=revenue:0;label=OO',
            ['D15'] => 'city=revenue:10,loc:2;city=revenue:10,loc:4;path=a:2,b:_0;path=a:4,b:_1;upgrade=cost:20,terrain:river',
            ['I4'] => 'city=revenue:20,loc:1.5;city=revenue:20,loc:4;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_1;label=L',
          },
          brown: {
          },
          purple: {
            # Gotthard tunnel
            ['H17'] => 'town=revenue:0,loc:4;path=track:future,a:0,b:_0;path=track:future,a:4,b:_0',
            ['H19'] => 'path=track:future,a:1,b:4;border=edge:0,type:impassable',
            ['H21'] => 'path=track:future,a:1,b:4',
            ['H23'] => 'path=track:future,a:1,b:4',
            ['I16'] => 'path=track:future,a:5,b:3;border=edge:4,type:impassable',
            # other tunnels
            %w[H27 J9] => '',
            ['I12'] => 'border=edge:0,type:impassable;border=edge:1,type:impassable',
            ['K14'] => 'border=edge:0,type:impassable;border=edge:3,type:impassable',
          },
          blue: {
            %w[K16 K18 L17 L19] => '',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
