# frozen_string_literal: true

module Engine
  module Game
    module G1837
      module Map
        LAYOUT = :pointy

        TILES = {
          # yellow
          '1' => 2,
          '2' => 3,
          '3' => 6,
          '4' => 12,
          '5' => 2,
          '7' => 12,
          '8' => 28,
          '9' => 22,
          '55' => 1,
          '56' => 1,
          '57' => 3,
          '58' => 12,
          '69' => 2,
          '201' => 3,
          '202' => 3,
          '401' => {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:30,slots:1;path=a:0,b:_0;path=a:5,b:_0;label=T',
          },
          '402' => {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:1;path=a:0,b:_0;path=a:2,b:_0;label=X',
          },
          '404' => {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:1;city=revenue:20,slots:1;path=a:0,b:_0;path=a:4,b:_0;' \
                      'path=a:1,b:_1;path=a:3,b:_1',
          },
          # green
          '12' => 2,
          '16' => 3,
          '17' => 1,
          '18' => 1,
          '19' => 3,
          '20' => 3,
          '23' => 12,
          '24' => 12,
          '25' => 5,
          '26' => 4,
          '27' => 4,
          '28' => 3,
          '29' => 3,
          '30' => 1,
          '31' => 1,
          '87' => 2,
          '88' => 2,
          '204' => 2,
          '205' => 2,
          '206' => 2,
          '207' => 4,
          '208' => 2,
          '405' => {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
          },
          '406' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=X',
          },
          '408' => {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;city=revenue:30,slots:1,loc:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;' \
                      'path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1',
          },
          '410' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:2;path=a:0,b:_0;path=a:3,b:_0',
          },
          '411' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:4;path=a:0,b:_0;path=a:3,b:_0',
          },
          '412' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:3;path=a:0,b:_0;path=a:2,b:_0',
          },
          '413' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:3;path=a:0,b:_0;path=a:4,b:_0',
          },
          '414' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:1;path=a:0,b:_0;path=a:3,b:_0',
          },
          '415' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:5;path=a:0,b:_0;path=a:3,b:_0',
          },
          '416' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:3;path=a:0,b:_0;path=a:1,b:_0',
          },
          '417' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:3;path=a:0,b:_0;path=a:5,b:_0',
          },
          '418' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:4;path=a:0,b:_0;path=a:2,b:_0',
          },
          '419' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:2;path=a:0,b:_0;path=a:4,b:_0',
          },
          '420' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:5;path=a:0,b:_0;path=a:4,b:_0',
          },
          '421' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:1;path=a:0,b:_0;path=a:2,b:_0',
          },
          '422' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:4;path=a:0,b:_0;path=a:5,b:_0',
          },
          '423' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:2;path=a:0,b:_0;path=a:1,b:_0',
          },
          '424' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:1,b:3;path=a:0,b:_0;path=a:4,b:_0',
          },
          '425' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:1;city=revenue:50,slots:1,loc:2;path=a:0,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1;path=a:_0,b:_1;label=Bu',
          },
          '426' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:1;path=a:0,b:_0;path=a:1,b:_0;label=Bo',
          },
          '427' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60,groups:Vienna;path=a:0,b:_0;city=revenue:60,groups:Vienna;path=a:1,b:_1;' \
                      'city=revenue:60,groups:Vienna;path=a:2,b:_2;city=revenue:60,groups:Vienna;path=a:3,b:_3;' \
                      'city=revenue:60,groups:Vienna;path=a:4,b:_4;city=revenue:60,groups:Vienna;path=a:5,b:_5;' \
                      'label=W',
          },
          '429' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=X',
          },
          # brown
          '39' => 2,
          '40' => 3,
          '41' => 4,
          '42' => 4,
          '43' => 2,
          '44' => 3,
          '45' => 3,
          '46' => 3,
          '47' => 3,
          '63' => 4,
          '70' => 2,
          '216' => 5,
          '430' => {
            'count' => 5,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=X',
          },
          '431' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
          },
          '432' => {
            'count' => 4,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;city=revenue:40,slots:2,loc:2;path=a:0,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1;path=a:_0,b:_1',
          },
          '434' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:1;path=a:0,b:_0;path=a:5,b:_0;label=B',
          },
          '435' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0;label=Bu',
          },
          '436' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,groups:Vienna;path=a:0,b:_0;city=revenue:80,groups:Vienna;path=a:1,b:_1;' \
                      'city=revenue:80,groups:Vienna;path=a:2,b:_2;path=a:3,b:_2;path=a:4,b:_2;' \
                      'city=revenue:80,groups:Vienna;path=a:5,b:_3;label=W',
          },
        }.freeze

        YELLOW_SINGLE_TOWN_UPGRADES = %w[410 411 412 413 414 415 416 417 418 419 420 421 422 423 424].freeze
        YELLOW_DOUBLE_TOWN_UPGRADES = %w[87 88 204].freeze

        LOCATION_NAMES = {
          'C11' => 'Prague',
          'C23' => 'Krakow',
          'C33' => 'Lemberg',
          'D36' => 'Tarnopol',
          'E17' => 'Brünn',
          'F28' => 'Kaschau',
          'F38' => 'Czernowitz',
          'G13' => 'Linz & Wels',
          'G17' => 'Vienna',
          'G19' => 'Preßburg',
          'H10' => 'Salzburg',
          'H20' => 'Raab & Tatabanya',
          'H22' => 'Budapest',
          'H30' => 'Debrecen & Großwardein',
          'H34' => 'Klausenburg',
          'I3' => 'Bregenz',
          'I7' => 'Innsbruck',
          'I15' => 'Graz',
          'J16' => 'Marburg',
          'J26' => 'Szegedin',
          'J28' => 'Arad & Temesvar',
          'J36' => 'Kronstadt',
          'K5' => 'Bozen',
          'K17' => 'Agram',
          'K21' => 'Fünfkirchen',
          'L2' => 'Milan',
          'L8' => 'Venice',
          'L12' => 'Triest',
          'N20' => 'Serajevo',
        }.freeze

        MINE_HEXES = %w[A13 B32 C19 C21 E11 F26 K31 K33 L30 P20].freeze

        ITALY_HEXES = %w[K1 K3 K7 K9 L2 L4 L6 L8 M3 M5 M7].freeze

        HEXES = {
          gray: {
            ['A11'] => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0',
            ['A13'] => 'city=revenue:yellow_30|brown_50,slots:1;path=a:0,b:_0',
            ['B8'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
            ['B26'] => 'path=a:0,b:4',
            ['B32'] => 'city=revenue:yellow_20|brown_50,slots:1;path=a:0,b:_0',
            ['C19'] => 'city=revenue:yellow_20|brown_40,slots:1;path=a:0,b:_0',
            ['C21'] => 'city=revenue:yellow_25|brown_45,slots:1;path=a:5,b:_0',
            ['D38'] => 'path=a:0,b:1',
            ['E11'] => 'city=revenue:yellow_20|brown_40,slots:1;path=a:2,b:_0',
            ['F26'] => 'city=revenue:yellow_20|brown_40,slots:1;path=a:5,b:_0;path=a:3,b:4',
            ['G9'] => 'path=a:4,b:5',
            ['G37'] => 'path=a:0,b:3;path=a:0,b:2;path=a:2,b:3',
            ['H8'] => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0',
            ['J34'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:0',
            ['K1'] => 'town=revenue:10;path=a:5,b:_0',
            ['K31'] => 'city=revenue:yellow_30|brown_50,slots:1;path=a:2,b:_0',
            ['K33'] => 'city=revenue:yellow_25|brown_50,slots:1;path=a:3,b:_0',
            ['L30'] => 'city=revenue:yellow_25|brown_50,slots:1;path=a:2,b:_0',
            ['M13'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['N14'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['N22'] => 'path=a:1,b:2',
            ['O17'] => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0',
            ['P20'] => 'city=revenue:yellow_35|brown_60,slots:1;path=a:2,b:_0',
          },
          white: {
            %w[B10 B12 B14 B28 B30 B34 C9 C13 C29 C35 D12 D14 D16 D20 D24 D26
               D32 D34 E19 E29 E37 F14 F24 F36 G25 G31 H12 H24 H28 I17 I19 I31
               I35 I37 J14 J20 J30 K15 K27 L16 L20 L26 L28 M3 M7 M15 N16 O19] => 'blank',
            %w[B16 C17 C25 D28 D30 E21 E23 E27 E31 E33 F12 F20 F34 G33 G35 H14
               H32 I9 I11 I13 J32 L14 M17 M19 M21 N18] => 'upgrade=cost:70,terrain:mountain',
            %w[C15 D10 D18 D22 E13 E15 E35 F16 F22 F30 F32 G11 I21 I27 I33 J18 J24 K29 L18 M5] => 'town=revenue:0',
            ['C23'] => 'city=revenue:0,slots:1;label=T',
            %w[C27 E25 H36] => 'town=revenue:0;upgrade=cost:70,terrain:mountain',
            %w[C31 H18] => 'town=revenue:0;town=revenue:0',
            %w[C33 D36 H10 I7 L2 N20] => 'city=revenue:0,slots:1;label=Y',
            %w[E17 J26] => 'city=revenue:0,slots:1;label=X',
            %w[F28 H34 I15 K17 L8] => 'city=revenue:0',
            %w[F38 J36 L12] => 'city=revenue:0,slots:1;label=T',
            %w[G13 H20 H30 J28] => 'city=revenue:0,slots:1;city=revenue:0,slots:1',
            %w[G15 G21 G29 I25 J22 K19 K23 K25] => 'upgrade=cost:50,terrain:water',
            ['G19'] => 'city=revenue:0,slots:1;upgrade=cost:50,terrain:water;label=X',
            ['G23'] => 'town=revenue:0;upgrade=cost:50,terrain:water',
            %w[H16 I5] => 'upgrade=cost:110,terrain:mountain',
            %w[I23 L24] => 'town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:water',
            ['J4'] => 'upgrade=cost:70,terrain:mountain;border=edge:0,type:province,color:red',
            ['J6'] => 'upgrade=cost:110,terrain:mountain;border=edge:5,type:province,color:red',
            ['J8'] => 'town=revenue:0;upgrade=cost:70,terrain:mountain;' \
                      'border=edge:0,type:province,color:red;border=edge:5,type:province,color:red',
            ['J10'] => 'upgrade=cost:110,terrain:mountain;border=edge:0,type:province,color:red',
            ['J12'] => 'town=revenue:0;town=revenue:0;upgrade=cost:110,terrain:mountain',
            ['K3'] => 'upgrade=cost:70,terrain:mountain;border=edge:3,type:province,color:red;' \
                      'border=edge:4,type:province,color:red',
            ['K5'] => 'city=revenue:0,slots:1;future_label=label:B,color:brown;border=edge:0,type:province,color:red;' \
                      'border=edge:1,type:province,color:red;border=edge:4,type:province,color:red;' \
                      'border=edge:5,type:province,color:red',
            ['K7'] => 'upgrade=cost:70,terrain:mountain;border=edge:1,type:province,color:red;' \
                      'border=edge:2,type:province,color:red;border=edge:3,type:province,color:red',
            ['K9'] => 'town=revenue:0;border=edge:2,type:province,color:red;border=edge:3,type:province,color:red;' \
                      'border=edge:4,type:province,color:red',
            ['K11'] => 'upgrade=cost:110,terrain:mountain;border=edge:1,type:province,color:red',
            ['K13'] => 'town=revenue:0;upgrade=cost:110,terrain:mountain',
            ['L4'] => 'border=edge:3,type:province,color:red',
            ['L6'] => 'town=revenue:0;town=revenue:0;border=edge:2,type:province,color:red',
          },
          yellow: {
            ['C11'] => 'city=revenue:20;path=a:2,b:_0;path=a:4,b:_0;label=X',
            ['F18'] => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;town=revenue:10;path=a:1,b:_1;path=a:5,b:_1',
            ['G17'] => 'city=revenue:40,groups:Vienna;city=revenue:40,groups:Vienna;city=revenue:40,groups:Vienna;' \
                       'city=revenue:40,groups:Vienna;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;label=W',
            ['G27'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
            ['H22'] => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:5,b:_0;' \
                       'path=a:1,b:_1;path=a:3,b:_1;label=Bu',
            ['H26'] => 'path=a:1,b:4',
            ['J16'] => 'city=revenue:30;path=a:1,b:_0;label=X',
            ['L22'] => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0',

          },
          green: {
            ['I3'] => 'city=revenue:20;path=a:4,b:_0;label=B',
            ['I29'] => 'path=a:0,b:3;path=a:1,b:3',
            ['K21'] => 'city=revenue:30,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0',
          },
        }.freeze
      end
    end
  end
end
