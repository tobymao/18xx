# frozen_string_literal: true

module Engine
  module Game
    module G18NL
      module Map
        TILES = {
          # yellow
          '3' => 2,
          '4' => 2,
          '6' => 3,
          '7' => 4,
          '8' => 8,
          '9' => 7,
          '57' => 4,
          '58' => 2,

          # green
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '59' => 2,
          '87' => 2,
          '88' => 2,
          'NL1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=X',
          },
          'NL2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:4,b:_0;path=a:0,b:_0;label=X',
          },
          'NL3' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=X',
          },
          'NL4' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=X',
          },

          # brown
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '63' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
          'NL5' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=X',
          },
          'NL6' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=X',
          },
          'NL7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50;path=a:2,b:_0;path=a:4,b:_0;label=Z',
          },
        }.freeze

        LOCATION_NAMES = {
          'A12' => 'Leeuwarden',
          'A16' => 'Groningen',
          'B5' => 'Den Helder',
          'B15' => 'Heerenveen',
          'B19' => 'Bremen',
          'C8' => 'Enkhuizen',
          'C18' => 'Emmem',
          'D5' => 'Alkmaar',
          'D15' => 'Zwolle',
          'E4' => 'Haarlem',
          'E6' => 'Amsterdam',
          'E12' => 'Elburg',
          'E16' => 'Ommen',
          'E18' => 'Almelo',
          'E20' => 'Salzbergen',
          'F3' => 'Leiden',
          'F7' => 'Abcoude',
          'F9' => 'Amersfoort',
          'F13' => 'Apeldoorn',
          'F15' => 'Deventer',
          'F19' => 'Hengelo & Enschede',
          'F21' => 'Münster',
          'G2' => "'s-Gravenzande & Delft",
          'G4' => 'Gouda',
          'G8' => 'Utrecht',
          'H3' => 'Rotterdam',
          'H11' => 'Ede',
          'H13' => 'Arnhem & Nijmegen',
          'H15' => 'Doetichem',
          'I4' => 'Barendrecht & Dordrecht',
          'I10' => "'s Hertogenbosch & Oss",
          'I14' => 'Ruhrgebiet',
          'J5' => 'Breda',
          'J7' => 'Tilburg',
          'K10' => 'Eindhoven',
          'L1' => 'Antwerpen',
          'M12' => 'Maastricht',
        }.freeze

        HEXES = {
          gray: {
            ['A12'] => 'town=revenue:10;path=a:5,b:_0',
            ['B5'] => 'city=revenue:20;path=a:5,b:_0',
            ['F13'] => 'city=revenue:20,loc:5.5;path=a:1,b:_0;path=a:4,b:_0;path=a:1,b:4',
            %w[K6 L9] => 'path=a:3,b:4',
          },
          green: {
            ['B15'] => 'city=revenue:10;path=a:1,b:_0;label=Z',
          },
          red: {
            ['A16'] => 'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0',
            ['B17'] => 'offboard=revenue:yellow_30|brown_50,hide:1,groups:Bremen;path=a:5,b:_0;border=edge:4',
            ['B19'] => 'offboard=revenue:yellow_30|brown_50,groups:Bremen;path=a:0,b:_0;border=edge:1',
            ['E20'] => 'offboard=revenue:yellow_10|brown_70;path=a:0,b:_0;path=a:1,b:_0',
            ['F21'] => 'offboard=revenue:yellow_0|brown_40;path=a:1,b:_0',
            ['I14'] => 'offboard=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['L1'] => 'offboard=revenue:yellow_40|brown_80,groups:Antwerpen;path=a:3,b:_0;border=edge:4',
            ['L3'] => 'offboard=revenue:yellow_40|brown_80,hide:1,groups:Antwerpen;path=a:2,b:_0;border=edge:1',
            ['M12'] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0',
          },
          white: {
            %w[B13
               C6
               C14
               C16
               D7
               D13
               D17
               E14
               F11
               F17
               G6
               G10
               G12
               G14
               G16
               G18
               H17
               J3
               J9
               J11
               J13
               K8
               K12
               K14
               L11
               L13] => '',
            %w[F5 H1 H5 H7 H9 I6 I8 I12 K2] => 'upgrade=cost:80,terrain:water',
            %w[I2 J1] => 'upgrade=cost:120,terrain:water',
            %w[C8 C18 D5 D15 E12 E18 F7 G4 H15] => 'town=revenue:0',
            %w[F3 H11] => 'town=revenue:0;upgrade=cost:80,terrain:water',
            %w[E16 F9 F15 G8 J5 J7 K10] => 'city=revenue:0',
            ['E4'] => 'city=revenue:0;upgrade=cost:80,terrain:water',
          },
          yellow: {
            ['E6'] => 'city=revenue:40,loc:2;city=revenue:40,loc:5;path=a:1,b:_0;path=a:5,b:_1;upgrade=cost:80,terrain:water;'\
                      'label=X',
            ['G2'] => 'city=revenue:30;city=revenue:30,loc:5;path=a:3,b:_0;path=a:4,b:_1;label=X',
            ['H3'] => 'city=revenue:30;city=revenue:30,loc:5;path=a:3,b:_0;path=a:5,b:_1;upgrade=cost:80,terrain:water;label=X',
            %w[H13 I4] => 'city=revenue:0;city=revenue:0;upgrade=cost:80,terrain:water;label=OO',
            %w[F19 I10] => 'city=revenue:0;city=revenue:0;label=OO',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
