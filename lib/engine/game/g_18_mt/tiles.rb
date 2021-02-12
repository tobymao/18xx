# frozen_string_literal: true

module Engine
  module Game
    module G18MT
      module Tiles
        TILES = {
          '3' => 4,
          '4' => 5,
          '5' => 2,
          '6' => 4,
          '7' => 10,
          '8' => 15,
          '9' => 15,
          '57' => 5,
          '58' => 6,
          '14' => 4,
          '15' => 4,
          '619' => 2,
          '16' => 3,
          '17' => 3,
          '18' => 3,
          '19' => 3,
          '20' => 3,
          '21' => 2,
          '22' => 2,
          '63' => 3,
          '338' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;',
          },
          '770' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;',
          },
          '141' => 4,
          '142' => 4,
          '143' => 3,
          '144' => 3,
          '767' => 2,
          '768' => 2,
          '769' => 2,
          'mtoy' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30,loc:2;city=revenue:30,loc:0;path=a:2,b:_0;path=a:5,b:_1;label=OO;',
          },
          'mtgy' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=G;',
          },
          'mtog2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1;label=OO',
          },
          'mtog3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:3,b:_1;label=OO',
          },
          'mtog4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_1;path=a:3,b:_1;label=OO',
          },
          'mtog5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:3.5;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;'\
                      'path=a:4,b:_1;label=OO',
          },
          'mtog6' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40,loc:4.5;path=a:0,b:_0;path=a:2,b:_0;'\
                      'path=a:4,b:_1;path=a:5,b:_1;label=OO',
          },
          'mtgg' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=G;',
          },
          'mtob1' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;city=revenue:50,slots:2;label=OO;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_1;',
          },
          'mtob2' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;city=revenue:50,slots:2;label=OO;'\
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_0;'\
                      'path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_1;',
          },
          'mtgb' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;label=G;',
          },
          'mts' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
        }.freeze
      end
    end
  end
end
