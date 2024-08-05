# frozen_string_literal: true

module Engine
  module Game
    module GSteamOverHolland
      module Map
        TILES = {
          # yellow
          '3' => 6,
          '4' => 6,
          '6' => 8,
          '7' => 3,
          '8' => 8,
          '9' => 8,
          '57' => 7,
          '58' => 6,
          'SOH1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30,loc:5.5;city=revenue:30,loc:1.5;path=a:0,b:_0;path=a:_0,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:1;label=AM',
          },

          # green
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '981' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,loc:5;town=revenue:10,loc:4;path=a:2,b:_0;path=a:_0,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:4',
          },
          '991' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,loc:5;town=revenue:10,loc:0;path=a:2,b:_0;path=a:_0,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:0',
          },
          'SOH2' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,loc:5;town=revenue:10,loc:1;path=a:2,b:_0;path=a:_0,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:1',
          },
          'SOH3' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,loc:5;town=revenue:10,loc:3;path=a:2,b:_0;path=a:_0,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:3',
          },
          'SOH4' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,loc:0;town=revenue:10,loc:1;path=a:2,b:_0;path=a:_0,b:0;path=a:2,b:_1;'\
                      'path=a:_1,b:1',
          },
          'SOH5' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,loc:3;town=revenue:10,loc:4;path=a:2,b:_0;path=a:_0,b:3;path=a:2,b:_1;'\
                      'path=a:_1,b:4',
          },
          'SOH6' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:5.5;city=revenue:40,loc:1.5;path=a:0,b:_0;path=a:_0,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:1;label=AM',
          },

          # brown
          '39' => 1,
          '40' => 2,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '125' => 3,
          '217' => {
            'count' => 3,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:5,b:_0',
          },
          'SOH7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:5,b:_0;label=AM',
          },
        }.freeze

        LOCATION_NAMES = {
          'B13' => 'Leeuwarden',
          'B17' => 'Groningen',
          'C8' => 'Den Helder',
          'C16' => 'Assen',
          'C20' => 'Papenburg',
          'D9' => 'Enkhuizen',
          'E14' => 'Zwolle',
          'F7' => 'Haarlem',
          'F9' => 'Amsterdam',
          'F17' => 'Almelo',
          'G6' => 'Leiden',
          'G12' => 'Amersfoort',
          'G14' => 'Apeldoorn',
          'G18' => 'Enschede',
          'G20' => 'Salzbergen',
          'H5' => 'Den Haag',
          'H7' => 'Gouda',
          'H9' => 'Utrecht',
          'H13' => 'Arnhem',
          'I6' => 'Rotterdam',
          'I10' => 'Den Bosch',
          'I12' => 'Nijmegen',
          'I16' => 'Emmerich am Rhein',
          'J1' => 'Vlissingen',
          'J7' => 'Breda',
          'J9' => 'Tilburg',
          'J15' => 'Kleve',
          'K2' => 'Middelburg',
          'K12' => 'Eindhoven',
          'K14' => 'Venlo',
          'L5' => 'Antwerpen',
          'N13' => 'Maastricht',
          'O12' => 'Liège',
        }.freeze

        HEXES = {
          blue: {
            ['D9'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:4',
            ['D11'] => 'path=a:1,b:3',
            %w[E10 E12 F11] => '',
          },
          red: {
            ['C8'] => 'offboard=revenue:yellow_30|brown_40;path=a:0,b:_0',
            ['C20'] => 'offboard=revenue:yellow_40|brown_60;path=a:2,b:_0',
            ['G20'] => 'offboard=revenue:yellow_40|brown_60;path=a:1,b:_0',
            ['I16'] => 'offboard=revenue:yellow_40|brown_50;path=a:1,b:_0',
            ['J1'] => 'offboard=revenue:yellow_40|brown_60;path=a:5,b:_0',
            ['J15'] => 'offboard=revenue:yellow_40|brown_50;path=a:0,b:_0;'\
                       'border=edge:0,type:water,cost:50;border=edge:1,type:water',
            ['L5'] => 'offboard=revenue:yellow_40|brown_50;path=a:3,b:_0',
            ['O12'] => 'offboard=revenue:yellow_40|brown_60;path=a:3,b:_0',
          },
          white: {
            %w[
              A14
              A16
              A18
              B15
              B19
              C12
              C14
              C18
              D7
              D13
              D15
              D17
              D19
              E8
              E16
              E18
              F19
              G8
              G10
              H17
              J11
              K6
              K8
              K10
              L11
              L13
              M12
              M14
              ] => 'blank',
            %w[C16 F7 F17 G6 G12 G18 H7 N13] => 'town',
            %w[B13 B17 H5 K12] => 'city',
            ['F9'] => 'city=revenue:0;city=revenue:0;label=AM',
            # plain hexes with river borders
            ['F13'] => 'border=edge:3,type:water,cost:50;border=edge:4,type:water,cost:50',
            ['F15'] => 'border=edge:0,type:water,cost:50;border=edge:1,type:water,cost:50',
            ['G16'] => 'border=edge:1,type:water,cost:50',
            ['H11'] => 'border=edge:0,type:water,cost:50;border=edge:5,type:water,cost:50',
            ['H15'] => 'border=edge:0,type:water,cost:50;border=edge:1,type:water,cost:50;'\
                       'border=edge:2,type:water,cost:50',
            ['I4'] => 'border=edge:0,type:water,cost:50;border=edge:5,type:water,cost:50',
            ['I8'] => 'border=edge:0,type:water,cost:50;border=edge:4,type:water,cost:50;'\
                      'border=edge:5,type:water,cost:50',
            ['I14'] => 'border=edge:0,type:water,cost:50;border=edge:1,type:water,cost:50;'\
                       'border=edge:2,type:water,cost:50;border=edge:3,type:water,cost:50',
            ['J3'] => 'border=edge:0,type:water,cost:50;border=edge:3,type:water,cost:50;'\
                      'border=edge:4,type:water,cost:50;border=edge:5,type:water,cost:50',
            ['J5'] => 'border=edge:1,type:water,cost:50;border=edge:2,type:water,cost:50;'\
                      'border=edge:3,type:water,cost:50',
            ['J13'] => 'border=edge:3,type:water,cost:50;border=edge:4,type:water',
            ['K4'] => 'border=edge:1,type:water,cost:50;border=edge:2,type:water,cost:50',
            # towns with river borders
            ['G14'] => 'town=revenue:0;border=edge:3,type:water,cost:50;'\
                       'border=edge:4,type:water,cost:50;border=edge:5,type:water,cost:50',
            ['I10'] => 'town=revenue:0;border=edge:1,type:water,cost:50;'\
                       'border=edge:2,type:water,cost:50;border=edge:3,type:water,cost:50',
            ['J9'] => 'town=revenue:0;border=edge:2,type:water,cost:50',
            ['K2'] => 'town=revenue:0;border=edge:3,type:water,cost:50;border=edge:4,type:water,cost:50',
            ['K14'] => 'town=revenue:0;border=edge:3,type:water,cost:50',
            # cities with river borders
            ['E14'] => 'city=revenue:0;border=edge:0,type:water,cost:50',
            ['H9'] => 'city=revenue:0;border=edge:5,type:water,cost:50',
            ['H13'] => 'city=revenue:0;border=edge:0,type:water,cost:50;border=edge:4,type:water,cost:50;'\
                       'border=edge:5,type:water,cost:50',
            ['I6'] => 'city=revenue:0;border=edge:0,type:water,cost:50;border=edge:5,type:water,cost:50',
            ['I12'] => 'city=revenue:0;border=edge:2,type:water,cost:50;border=edge:3,type:water,cost:50;'\
                       'border=edge:4,type:water,cost:50',
            ['J7'] => 'city=revenue:0;border=edge:2,type:water,cost:50;border=edge:3,type:water,cost:50',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
