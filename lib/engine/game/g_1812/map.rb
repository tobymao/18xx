# frozen_string_literal: true

module Engine
  module Game
    module G1812
      module Map
        TILES = {
          # yellow
          '3' => 3,
          '4' => 5,
          '5' => 2,
          '6' => 2,
          '7' => 4,
          '8' => 10,
          '9' => 10,
          '57' => 2,
          '58' => 7,
          '201' => 2,
          '202' => 2,
          '621' => 2,

          # green
          '14' => 2,
          '15' => 2,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '87' => 4,
          '88' => 2,
          '204' => 2,
          '207' => 2,
          '208' => 2,
          '619' => 2,
          '622' => 2,

          # brown
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '70' => 1,
          '611' => 3,
          '623' => 3,
          '911' => 3,
          'X20' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'path=a:5,b:_0;label=Y',
            },

          # gray
          'X30' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:60,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'path=a:5,b:_0;path=a:0,b:_0;label=Y',
            },
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Carlisle',
          'A8' => 'Carlisle',
          'A12' => 'Preston',
          'A16' => 'Manchester',
          'C12' => 'Harrogate',
          'C14' => 'Leeds',
          'C16' => 'Barnsley',
          'C18' => 'Sheffield',
          'C20' => 'Derby',
          'D9' => 'Darlington',
          'D11' => 'Northallerton',
          'D17' => 'Doncaster',
          'E4' => 'Newcastle',
          'E6' => 'Durham',
          'E8' => 'Middlesbrough',
          'E14' => 'York',
          'E16' => 'Selby',
          'E20' => 'Newark',
          'F1' => 'Berwick',
          'F5' => 'Sunderland',
          'F7' => 'Hartlepool',
          'F19' => 'Lincoln',
          'G10' => 'Whitby',
          'G12' => 'Scarborough',
          'G16' => 'Hull',
          'I1' => 'North-South Bonus',
          'I3' => 'Mine to Port Bonus',
        }.freeze

        HEXES = {
          red: {
            ['A4'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30;path=a:4,b:_0;icon=image:1812/north',
            ['A8'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30;path=a:5,b:_0;icon=image:1812/north',
            ['A12'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:5,b:_0',
            ['A16'] => 'offboard=revenue:yellow_40|green_50|brown_60|gray_70;path=a:4,b:_0;path=a:5,b:_0',
            ['C20'] => 'city=revenue:yellow_30|green_40|brown_50|gray_50;path=a:3,b:_0;path=a:4,b:_0;icon=image:18_gb/south',
            ['E20'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:2,b:_0;path=a:3,b:_0;icon=image:18_gb/south',
            ['F1'] => 'offboard=revenue:yellow_10|green_30|brown_40|gray_40;path=a:1,b:_0;icon=image:1812/north',
            ['F19'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:3,b:_0;icon=image:18_gb/south',
            ['I1'] => 'offboard=revenue:yellow_40|green_50|brown_60|gray_70;icon=image:18_gb/south;icon=image:1812/north',
          },
          gray: {
            ['F9'] => 'path=a:2,b:4',
          },
          white: {
            %w[B3 B13 C4 D13 D15 D19 E10 E12 F13 F15 G14 H15] => '',
            %w[G18 H13] => 'border=edge:3,type:impassable',
            ['H11'] => 'border=edge:0,type:impassable',
            %w[D7 E2] => 'icon=image:mine,sticky:1',
            %w[B17 C2 C6 C8 C10 D1 D5 F11] => 'upgrade=cost:40,terrain:mountain',
            ['B15'] => 'upgrade=cost:40,terrain:mountain;icon=image:mine,sticky:1',
            %w[B9 B11 B19] => 'upgrade=cost:60,terrain:mountain',
            %w[B5 B7] => 'upgrade=cost:80,terrain:mountain',
            %w[D3 E18] => 'upgrade=cost:20,terrain:water',
            ['F17'] => 'upgrade=cost:40,terrain:water',
            %w[C12 D11 F7 G12] => 'town=revenue:0',
            %w[D9 E16] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            ['G10'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[D17 E6] => 'town=revenue:0;icon=image:mine,sticky:1',
            %w[C16 F5] => 'city=revenue:0',
            ['C18'] => 'city=revenue:0;label=Y',
            ['E8'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            ['G16'] => 'city=revenue:0;border=edge:0,type:impassable;label=Y',
          },
          blue: {
            %w[F3 G4 G6 G8 H9] => 'offboard=revenue:yellow_0,visit_cost:0;path=a:1,b:_0;icon=image:port',
            %w[H17 H19] => 'offboard=revenue:yellow_0,visit_cost:0;path=a:2,b:_0;icon=image:port',
            ['I3'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60,visit_cost:0;icon=image:port;'\
                      'icon=image:mine,sticky:1',
          },
          yellow: {
            ['C14'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_1;label=Y',
            ['E4'] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=Y;'\
                      'upgrade=cost:20,terrain:water',
            ['E14'] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=Y',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
