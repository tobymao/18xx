# frozen_string_literal: true

module Engine
  module Game
    module G18BF
      module Tiles
        TILES = {
          # Yellow tiles.
          '3' => 4,
          '4' => 12,
          '5' => 6,
          '6' => 6,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 6,
          '58' => 10,
          '201' => 4,
          '202' => 4,
          '621' => 4,

          # Green tiles
          '14' => 4,
          '15' => 8,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 2,
          '22' => 2,
          '23' => 8,
          '24' => 8,
          '25' => 6,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '87' => 5,
          '88' => 5,
          '204' => 5,
          '207' => 6,
          '208' => 4,
          '619' => 4,
          '622' => 4,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          'BF1' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;label=BGM;' \
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;' \
                      'path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_2',
          },
          'BF4' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;label=BGM;' \
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;' \
                      'path=a:3,b:_2;path=a:4,b:_1;path=a:5,b:_0',
          },
          'BF5' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;label=BGM;' \
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_1;' \
                      'path=a:3,b:_2;path=a:4,b:_2;path=a:5,b:_0',
          },
          'BF9' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'offboard=revenue:50;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'BF12' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:2.5;city=revenue:40,loc:4;city=revenue:40,loc:5.5;label=L;' \
                      'path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_2',
          },

          # Brown tiles.
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 6,
          '70' => 2,
          '216' => 2,
          '448' => 8,
          '611' => 3,
          '623' => 4,
          '801' => 3,
          '911' => 5,
          'BF6' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;city=revenue:50,slots:1;label=BGM;' \
                      'path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_1',
          },
          'BF7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;city=revenue:50,slots:1;label=BGM;' \
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_0',
          },
          'BF10' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'offboard=revenue:70;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'BF13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=L;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },

          # Grey tiles.
          '49' => 1,
          'BF11' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'offboard=revenue:100;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'BF14' => {
            'count' => 4,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;' \
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze
      end
    end
  end
end
