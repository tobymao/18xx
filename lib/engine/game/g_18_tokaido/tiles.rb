# frozen_string_literal: true

module Engine
  module Game
    module G18Tokaido
      module Tiles
        TILES = {
          # Yellow
          '3' => 2,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 2,
          '58' => 3,
          '201' => 1,
          '202' => 1,
          '621' => 1,
          # Green
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '87' => 1,
          '88' => 1,
          '204' => 1,
          '207' => 1,
          '208' => 1,
          '619' => 1,
          '622' => 1,
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=OO',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          },
          'X10' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:3,b:_1;path=a:_1,b:4;label=O',
          },
          'X11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=O',
          },
          'X12' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:3,b:_1;path=a:_1,b:4;label=OO',
          },
          # Brown
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 2,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '70' => 1,
          '216' => 3,
          '611' => 3,
          'X13' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=O',
          },
          'X14' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=OO',
          },
          # Gray
          '915' => 1,
          'X15' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
          },
          'X16' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=O',
          },
          'X17' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:100,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;' \
              'path=a:4,b:_0;path=a:5,b:_0;label=OO',
          },
        }.freeze
      end
    end
  end
end
