# frozen_string_literal: true

module Engine
  module Game
    module G18LosAngeles1
      module Map
        HEXES = {
          white: {
            ['C10'] => '',
            ['D3'] => 'upgrade=cost:40,terrain:water',
            ['A4'] => 'city=revenue:0;border=edge:0,type:mountain,cost:20',
            ['B3'] => 'border=edge:3,type:mountain,cost:20;border=edge:4,type:mountain,cost:20',
            ['B9'] => 'city=revenue:0;border=edge:3,type:mountain,cost:20;border=edge:1,type:water,cost:40',
            ['B13'] => 'city=revenue:0;border=edge:2,type:mountain,cost:20;'\
                       'border=edge:3,type:mountain,cost:20;label=Z',
            ['B7'] => 'city=revenue:0;border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['C8'] => 'city=revenue:0;border=edge:2,type:water,cost:40',
            ['D5'] => 'city=revenue:0;border=edge:3,type:water,cost:40',
            ['C12'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            ['D9'] => 'city=revenue:0;border=edge:4,type:water,cost:40;stub=edge:0',
            ['D11'] => 'city=revenue:0;border=edge:1,type:water,cost:40',
            ['E4'] => 'city=revenue:0;icon=image:18_los_angeles/sbl,sticky:1',
            ['E6'] => 'city=revenue:0;icon=image:18_los_angeles/sbl,sticky:1;stub=edge:4',
            ['E10'] => 'city=revenue:0;border=edge:0,type:water,cost:40;stub=edge:1',
            ['E12'] => 'city=revenue:0;label=Z',
            ['E14'] => 'upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:20',
            %w[A6 C4 F11] => 'city=revenue:0',
            ['D7'] => 'city=revenue:0;stub=edge:5',
          },
          gray: {
            ['B5'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'border=edge:1,type:mountain,cost:20',
            ['C2'] => 'city=revenue:10;icon=image:port;icon=image:port;path=a:2,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;',
            ['D13'] => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
            ['F9'] => 'city=revenue:10;border=edge:3,type:water,cost:40;icon=image:port;'\
                      'icon=image:port;path=a:3,b:_0;path=a:4,b:_0',
            ['F5'] => 'path=a:2,b:3',
            ['a9'] => 'offboard=revenue:0,visit_cost:100;path=a:0,b:_0',
            ['G14'] => 'offboard=revenue:0,visit_cost:100;path=a:2,b:_0',
          },
          red: {
            ['A2'] => 'city=revenue:yellow_30|brown_50,groups:NW;label=N/W;icon=image:1846/20;'\
                      'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A10'] => 'offboard=revenue:yellow_20|brown_40,groups:N|NW|NE;label=N;'\
                       'border=edge:0,type:mountain,cost:20;border=edge:1,type:mountain,cost:20;'\
                       'border=edge:5,type:mountain,cost:20;icon=image:1846/30;path=a:0,b:_0;'\
                       'path=a:1,b:_0;path=a:5,b:_0',
            ['A12'] => 'offboard=revenue:yellow_20|brown_40,groups:N|NW|NE;label=N;'\
                       'border=edge:0,type:mountain,cost:20;border=edge:5,type:mountain,cost:20;'\
                       'icon=image:1846/20;path=a:0,b:_0;path=a:5,b:_0',
            ['A14'] => 'offboard=revenue:yellow_20|brown_40,groups:NE;label=N/E;'\
                       'border=edge:0,type:mountain,cost:20;icon=image:1846/20;path=a:0,b:_0',
            ['B1'] => 'offboard=revenue:yellow_40|brown_10,groups:W|NW|SW;label=W;icon=image:port;'\
                      'icon=image:1846/30;path=a:4,b:_0;path=a:5,b:_0',
            ['B15'] => 'offboard=revenue:yellow_20|brown_50,groups:E|NE|SE;label=E;'\
                       'icon=image:1846/30;path=a:1,b:_0',
            ['C14'] => 'offboard=revenue:yellow_30|brown_70,groups:E|NE|SE;label=E;'\
                       'icon=image:1846/30;icon=image:18_los_angeles/meat;path=a:1,b:_0;'\
                       'path=a:2,b:_0',
            ['D15'] => 'offboard=revenue:yellow_20|brown_40,groups:E|NE|SE;label=E;'\
                       'icon=image:1846/30;path=a:0,b:_0;path=a:1,b:_0',
            ['E16'] => 'offboard=revenue:yellow_20|brown_40,groups:SE;label=S/E;icon=image:1846/20;'\
                       'path=a:1,b:_0',
            ['F15'] => 'offboard=revenue:yellow_20|brown_50,groups:SE;label=S/E;'\
                       'border=edge:2,type:mountain,cost:20;path=a:1,b:_0;path=a:2,b:_0;'\
                       'icon=image:1846/20',
            ['F7'] => 'offboard=revenue:yellow_20|brown_40,groups:S|SE|SW;label=S;path=a:3,b:_0;'\
                      'icon=image:1846/50;icon=image:18_los_angeles/meat;icon=image:port',
          },
          yellow: {
            ['A8'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;border=edge:4,type:mountain,cost:20',
            ['B11'] => 'city=revenue:20;border=edge:2,type:mountain,cost:20;'\
                       'border=edge:3,type:mountain,cost:20;path=a:1,b:_0;path=a:4,b:_0',
            ['C6'] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;label=Z;'\
                      'border=edge:0,type:water,cost:40',
            ['E8'] => 'city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;'\
                      'city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;'\
                      'path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;stub=edge:0;label=LB',
            ['F13'] => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0',
          },
        }.freeze
      end
    end
  end
end
