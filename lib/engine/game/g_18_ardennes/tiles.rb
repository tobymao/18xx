# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Tiles
        TILE_TYPE = :lawson

        TILES = {
          # Yellow tiles.
          '3' => 4,
          '4' => 8,
          '5' => 2,
          '6' => 4,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 6,
          '58' => 9,
          '201' => 2,
          '202' => 4,
          '621' => 4,

          # Green tiles.
          '14' => 3,
          '15' => 7,
          '80' => 3,
          '81' => 3,
          '82' => 6,
          '83' => 6,
          '141' => 5,
          '142' => 5,
          '143' => 2,
          '144' => 2,
          '207' => 6,
          '208' => 6,
          '405' => {
            'count' => 2,
            'color' => 'green',
            'code' =>
                      'label=T;' \
                      'city=revenue:40,slots:2;' \
                      'path=a:2,b:_0;' \
                      'path=a:3,b:_0;' \
                      'path=a:4,b:_0;',
          },
          '580' => 1,
          '619' => 3,
          '622' => 4,
          'X10' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
                      'label=A;' \
                      'city=revenue:40;' \
                      'city=revenue:40;' \
                      'path=a:0,b:_0;' \
                      'path=a:1,b:_0;' \
                      'path=a:4,b:_1;' \
                      'path=a:5,b:_1;',
          },
          'X11' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
                      'label=R;' \
                      'city=revenue:60,slots:2;' \
                      'path=a:0,b:_0;' \
                      'path=a:1,b:_0;' \
                      'path=a:5,b:_0;',
          },

          # Brown tiles.
          '63' => 6,
          '216' => 6,
          '431' => {
            'count' => 2,
            'color' => 'brown',
            'code' =>
                      'label=T;' \
                      'city=revenue:60,slots:2;' \
                      'path=a:2,b:_0;' \
                      'path=a:3,b:_0;' \
                      'path=a:4,b:_0;',
          },
          '583' => 1,
          'X20' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
                      'label=A;' \
                      'city=revenue:60,slots:2;' \
                      'path=a:0,b:_0;' \
                      'path=a:1,b:_0;' \
                      'path=a:4,b:_0;' \
                      'path=a:5,b:_0;',
          },
          'X21' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
                      'label=R;' \
                      'city=revenue:80,slots:3;' \
                      'path=a:0,b:_0;' \
                      'path=a:1,b:_0;' \
                      'path=a:5,b:_0;',
          },
          'X22' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
                      'label=B;' \
                      'city=revenue:60,slots:3;' \
                      'path=a:0,b:_0;' \
                      'path=a:1,b:_0;' \
                      'path=a:2,b:_0;' \
                      'path=a:3,b:_0;' \
                      'path=a:4,b:_0;' \
                      'path=a:5,b:_0;',
          },
        }.freeze
      end
    end
  end
end
