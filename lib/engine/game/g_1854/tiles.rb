# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Tiles
        TILES = {
          '1' => 2,
          '2' => 2,
          '3' => 3,
          '4' => 6,
          '5' => 5,
          '6' => 6,
          '7' => 5,
          '8' => 11,
          '9' => 11,
          '14' => 4,
          '15' => 7,
          '16' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 6,
          '24' => 6,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '55' => 2,
          '56' => 2,
          '57' => 6,
          '58' => 6,
          '69' => 1,
          '70' => 1,
          '611' => 6,
          '619' => 4,
          '433' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,loc:0;city=revenue:50,loc:1;city=revenue:50,loc:2;city=revenue:50,loc:3;'\
                      'city=revenue:50,loc:4;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;label=W',
          },
          '451' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60;city=revenue:60,loc:1.5,slots:2;city=revenue:60,loc:4.5,slots:2;'\
                      'path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:5;label=W',
          },
          '456' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:5;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=W',
          },
          '915' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze
      end
    end
  end
end
