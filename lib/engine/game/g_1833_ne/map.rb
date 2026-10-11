# frozen_string_literal: true

module Engine
  module Game
    module G1833NE
      module Map
        LAYOUT = :flat

        TILES = {
          # yellow:
          '3' => 4,
          '4' => 4,
          '5' => 3,
          '6' => 4,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 5,
          '58' => 7,
          'N10' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:2,b:_0;path=a:4,b:_0;label=Cape Cod',
          },
          'N11' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Sh',
          },

          # green:
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 5,
          '24' => 5,
          '25' => 3,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '619' => 4,
          'N21' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Sh',
          },
          'N22' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Pr',
          },
          'N23' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2,loc:0.5;city=revenue:50,loc:3.5;offboard=revenue:0;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:5,b:_0;path=a:3,b:_1;path=a:4,b:_1;path=a:2,b:_2;label=B',
          },
          'N24' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;offboard=revenue:0;path=a:1,b:_0;path=a:2,b:_2;path=a:3,b:_1;label=Po',
          },
          'N25' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2,loc:0;city=revenue:50;path=a:0,b:_0;path=a:4,b:_1;path=a:5,b:_0;label=Mo',
          },
          'N26' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:3,b:5;label=We',
          },
          'N27' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Ma',
          },
          'N28' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Ma',
          },
          'N40' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'N41' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'N42' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'N43' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },

          # brown:
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '70' => 1,
          'N32' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Pr',
          },
          'N33' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:90,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
          'N34' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Po',
          },
          'N35' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Mo',
          },
          'N50' =>
          {
            'count' => 5,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'N51' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'N52' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'N53' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          'N54' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'N60' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'N61' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'N62' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A6' => 'Ogdensburg RR',
          'A12' => 'D&H RR',
          'A20' => 'Albany',
          'A24' => 'Hudson Valley',
          'A28' => 'New York',
          'B3' => 'Montreal',
          'B11' => 'Westport',
          'B17' => 'Troy',
          'B27' => 'Bridgeport',
          'C4' => 'St. Jean',
          'C8' => 'St. Albans/Burlington',
          'C12' => 'Rutland',
          'C24' => 'Hartford',
          'C26' => 'New Haven',
          'D19' => 'Greenfield',
          'D21' => 'Springfield',
          'E20' => 'Fitchburg',
          'E22' => 'Worcester',
          'E26' => 'Norwich',
          'F1' => 'Eastern Townships',
          'F3' => 'Richmond',
          'F5' => 'Sherbrooke',
          'F15' => 'Concord',
          'F17' => 'Manchester',
          'F19' => 'Nashua',
          'F21' => 'Concord',
          'F23' => 'Framingham',
          'F25' => 'Providence',
          'F27' => 'Kingston',
          'G2' => 'Eastern Townships',
          'G20' => 'Lowell',
          'G22' => 'Boston',
          'G24' => 'Mansfield',
          'G26' => 'Fall River',
          'H17' => 'Portsmouth',
          'H19' => 'Newburyport',
          'H21' => 'Salem',
          'H23' => 'Quincy',
          'H25' => 'New Bedford & Plymouth',
          'I10' => 'Bethel',
          'I14' => 'Portland',
          'I26' => 'Hyannis',
          'J11' => 'Lewiston',
        }.freeze

        HEXES = {
          white: {
            %w[B5 B15 B23 B25 C6 D3 D5 D9 E2 E4 E8 E10 H15 I12] => '',
            %w[D23 D25] => 'upgrade=cost:60,terrain:water',
            %w[C2 E6 E12 F7 G14 G18 H13] => 'upgrade=cost:40,terrain:water',
            %w[B19 C16] => 'upgrade=cost:120,terrain:mountain',
            %w[C18 F11] => 'upgrade=cost:100,terrain:mountain',
            %w[D7 D11 H11] => 'upgrade=cost:80,terrain:mountain',
            %w[B21 F13 G16] => 'upgrade=cost:60,terrain:mountain',
            %w[B27 C4 F21 G24 I10 I26] => 'town=revenue:0',
            %w[D19 H19] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[C12 C26 E22 F19 G20 H17] => 'city=revenue:0',
            ['B9'] => 'border=edge:4,type:impassable;border=edge:5,type:water,cost:20',
            ['C8'] => 'city=revenue:0;border=edge:1,type:impassable',
            ['C10'] => 'border=edge:1,type:impassable;border=edge:2,type:water,cost:20',
            ['C14'] => 'border=edge:4,type:mountain,cost:60;border=edge:5,type:mountain,cost:60',
            ['C20'] => 'upgrade=cost:60,terrain:mountain;border=edge:5,type:water,cost:40',
            ['C22'] => 'upgrade=cost:60,terrain:mountain;border=edge:4,type:water,cost:40',
            ['D13'] => 'border=edge:1,type:mountain,cost:60;border=edge:5,type:impassable',
            ['D15'] => 'border=edge:2,type:mountain,cost:60;border=edge:4,type:impassable',
            ['D17'] => 'border=edge:5,type:water,cost:60',
            ['D21'] => 'city=revenue:0;border=edge:1,type:water,cost:40;border=edge:2,type:water,cost:40',
            ['D27'] => 'upgrade=cost:100,terrain:water',
            ['E14'] => 'border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['E16'] => 'upgrade=cost:60,terrain:water;border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['E18'] => 'border=edge:2,type:water,cost:60',
            ['E24'] => 'border=edge:4,type:mountain,cost:20',
            ['E26'] => 'city=revenue:0;border=edge:5,type:water,cost:40',
            ['F5'] => 'city=revenue:0;label=Sh',
            ['F9'] => 'upgrade=cost:40,terrain:water;border=edge:5,type:mountain,cost:60',
            ['F15'] => 'town=revenue:0;border=edge:1,type:water,cost:40',
            ['F23'] => 'town=revenue:0;border=edge:1,type:mountain,cost:20',
            ['F27'] => 'town=revenue:0;border=edge:2,type:water,cost:40;border=edge:4,type:impassable',
            ['G8'] => 'border=edge:5,type:mountain,cost:60',
            ['G10'] => 'border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:60',
            ['G12'] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain,cost:40',
            ['G26'] => 'town=revenue:0;border=edge:1,type:impassable',
            ['H9'] => 'border=edge:2,type:mountain,cost:60',
            ['H21'] => 'town=revenue:0;border=edge:0,type:impassable',
            ['H23'] => 'town=revenue:0;border=edge:3,type:impassable',

          },
          yellow: {
            ['B3'] => 'city=revenue:30,loc:5;city=revenue:30,loc:2;path=a:4,b:_1;path=a:5,b:_0;'\
                      'upgrade=cost:40,terrain:water;label=Mo',
            ['B11'] => 'town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;upgrade=cost:40,terrain:water;'\
                       'border=edge:4,type:impassable;label=We',
            ['C24'] => 'city=revenue:20;path=a:0,b:_0;path=a:4,b:_0',
            ['E20'] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0',
            ['F17'] => 'city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;border=edge:2,type:water,cost:40;label=Ma',
            ['F25'] => 'city=revenue:20;path=a:0,b:_0;path=a:4,b:_0;upgrade=cost:40,terrain:water;label=Pr',
            ['G22'] => 'city=revenue:30;city=revenue:30;offboard=revenue:0;path=a:0,b:_2;path=a:1,b:_0;path=a:3,b:_1;label=B',
            ['I14'] => 'city=revenue:30,loc:5.5;junction;path=a:3,b:_0;path=a:1,b:_1,terminal:1;'\
                       'path=a:2,b:_1,terminal:1;label=Po',
          },
          gray: {
            ['B7'] => 'path=a:0,b:2;path=a:0,b:3;path=a:2,b:5',
            ['F3'] => 'town=revenue:10;path=a:0,b:2;path=a:2,b:_0;path=a:3,b:_0',
            ['G4'] => 'path=a:1,b:3',
            ['H25'] => 'city=revenue:20;city=revenue:30;path=a:3,b:_0;path=a:1,b:_1;path=a:5,b:_1',
          },
          red: {
            ['A6'] => 'offboard=revenue:yellow_10|brown_30|gray_10;path=a:5,b:_0',
            ['A12'] => 'offboard=revenue:yellow_40|brown_70|gray_80;path=a:4,b:_0',
            ['A18'] => 'border=edge:0;border=edge:4',
            ['A20'] => 'offboard=revenue:yellow_40|brown_30|gray_0;path=a:5,b:_0;border=edge:3',
            ['A24'] => 'offboard=revenue:yellow_10|brown_40|gray_30;path=a:5,b:_0',
            ['A28'] => 'offboard=revenue:brown_20|gray_90;path=a:4,b:_0',
            ['B17'] => 'offboard=revenue:yellow_30|brown_50|gray_40;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;border=edge:1',
            ['F1'] => 'offboard=revenue:yellow_30|brown_20|gray_0,groups:EasternTownships;path=a:0,b:_0;border=edge:5',
            ['G2'] => 'offboard=revenue:yellow_30|brown_20|gray_0,groups:EasternTownships;path=a:0,b:_0;border=edge:2',
            ['J11'] => 'offboard=revenue:yellow_20|brown_30|gray_20;path=a:2,b:_0',
          },
          blue: {
            ['C28'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0;icon=image:port',
            ['E28'] => 'offboard=revenue:0;path=a:3,b:_0;icon=image:port',
            ['J25'] => 'junction;path=a:1,b:_0,terminal:1',
          },
        }.freeze
      end
    end
  end
end
