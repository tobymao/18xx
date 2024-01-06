# frozen_string_literal: true

module Engine
  module Game
    module G18PA
      module Map
        TILES = {
        }.freeze

        LOCATION_NAMES = {
          'B5' => 'Rochester',
          'C2' => 'Buffalo',
          'C10' => 'Syracuse',
          'C14' => 'Utica',
          'D1' => 'Cleveland',
          'D15' => 'Schenectady',
          'D17' => 'Albany',
          'D25' => 'Worchester',
          'D27' => 'Boston',
          'E10' => 'Binghamton',
          'E22' => 'Springfield & Hartford',
          'F27' => 'Providence',
          'G12' => 'Scranton',
          'G18' => 'Yonkers',
          'G20' => 'Bridgeport',
          'G22' => 'New Haven',
          'G24' => 'New London',
          'H17' => 'Newark',
          'H19' => 'New York',
          'H21' => 'Islip',
          'I2' => 'Pittsburgh',
          'I8' => 'Harrisburg',
          'I12' => 'Reading',
          'I16' => 'Trenton',
          'I18' => 'Long Beach',
          'J13' => 'Philadelphia',
          'K2' => 'Columbus',
          'K10' => 'Baltimore',
          'K16' => 'Atlantic City',
          'L15' => 'Cape May',
          'M8' => 'Washington',
        }.freeze

        HEXES = {
          red: {
            ['D1'] => 'offboard=revenue:yellow_0|green_30|brown_60;path=a:3,b:_0',
            ['I2'] => 'offboard=revenue:yellow_30|green_40|brown_60;path=a:4,b:_0',
            ['K2'] => 'offboard=revenue:yellow_30|green_40|brown_60;path=a:4,b:_0',
            ['M8'] => 'city=revenue:yellow_10|green_20|brown_60;path=a:2,b:_0;path=a:3,b:_0',
          },
          gray: {
            ['B1'] => 'path=a:4,b:5',
            ['C28'] => 'town=revenue:30;path=a:0,b:_0',
            ['E22'] => 'town=revenue:10,loc:5.5;town=revenue:10,loc:2.5;path=a:0,b:_0;path=a:5,b:_0;path=a:2,b:_1;'\
                       'path=a:3,b:_1;path=a:_0,b:_1',
            ['E28'] => 'path=a:0,b:2',
            ['G12'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I18'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            ['L15'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
          },
          white: {
            %w[B3 B7 C4 C6 C12 D23 E24 F25 H15 I14 J11 J15 J17 K8 L7 L9] => '',
            %w[
              D3
              D11
              D13
              D21
              E2
              E4
              E6
              E8
              E12
              E14
              E20
              F3
              F5
              F7
              F9
              F11
              F13
              F19
              G2
              G4
              G6
              G8
              G10
              G14
              H3
              H5
              H7
              H9
              H11
              H13
              I4
              I6
              I10
              J3
              J5
              J7
              J9
              K4
              K6
              ] => 'upgrade=cost:40,terrain:mountain',
            %w[C10 C14 D15 E10 K16] => 'town=revenue:0',
            ['C8'] => 'border=edge:0,type:impassable',
            ['D19'] => 'border=edge:1,type:water,cost:20',
            ['D25'] => 'town=revenue:0;stub=edge:4',
            ['E26'] => 'stub=edge:3',
            ['D5'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:impassable',
            ['D7'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:impassable;border=edge:3,type:impassable;'\
                      'border=edge:4,type:impassable',
            ['D9'] => 'upgrade=cost:40,terrain:mountain;border=edge:1,type:impassable',
            ['E16'] => 'border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['E18'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            ['F15'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:water,cost:20',
            ['F17'] => 'border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            ['F21'] => 'border=edge:4,type:water,cost:20',
            ['F23'] => 'border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20',
            ['G16'] => 'border=edge:3,type:water,cost:20;border=edge:4,type:impassable',
            ['G18'] => 'town=revenue:0;stub=edge:5;border=edge:0,type:impassable;border=edge:1,type:impassable;'\
                       'border=edge:4,type:impassable',
            ['G20'] => 'town=revenue:0;stub=edge:0;border=edge:1,type:impassable;border=edge:5,type:impassable;'\
                       'upgrade=cost:40,terrain:water',
            ['G24'] => 'town=revenue:0;border=edge:1,type:water,cost:20;border=edge:0,type:impassable;'\
                       'border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['H21'] => 'town=revenue:0;stub=edge:1;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['H23'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['I12'] => 'town=revenue:0;stub=edge:5',
            ['I16'] => 'town=revenue:0;stub=edge:3',
            ['K12'] => 'border=edge:4,type:impassable',
            ['K14'] => 'border=edge:1,type:impassable',
          },
          yellow: {
            ['B5'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            ['C2'] => 'city=revenue:30,slots:2;path=a:2,b:_0;label=BUF',
            ['D17'] => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:4,b:_0;border=edge:4,type:water,cost:20;'\
                       'border=edge:5,type:water,cost:20',
            ['D27'] => 'city=revenue:20;city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=BOS',
            ['F27'] => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
            ['G22'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;border=edge:3,type:water,cost:20;'\
                       'border=edge:4,type:water,cost:20;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['H17'] => 'city=revenue:20;city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:2,b:_1;'\
                       'path=a:4,b:_2;border=edge:3,type:impassable;label=EWR',
            ['H19'] => 'city=revenue:30;city=revenue:30,loc:2.5;city=revenue:30;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
                       'path=a:4,b:_2;label=NYC',
            ['I8'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            ['J13'] => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;'\
                       'path=a:4,b:_2;label=PHI',
            ['K10'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0',
          },
          blue: {
            ['G26'] => 'path=a:0,b:3,track:narrow;border=edge:1,type:impassable',
            ['H25'] => 'town=revenue:yellow_20|green_10|brown_0;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;'\
                       'border=edge:2,type:impassable',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
