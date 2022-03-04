# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Tiles
        TILES = {
          '3' => 5,
          '4' => 7,
          '5' => 9,
          '6' => 10,
          '7' => 6,
          '8' => 29,
          '9' => 30,
          '57' => 10,
          '58' => 9,
          '14' => 6,
          '15' => 8,
          '16' => 3,
          '17' => 1,
          '18' => 1,
          '19' => 3,
          '20' => 3,
          '23' => 13,
          '24' => 13,
          '25' => 5,
          '26' => 3,
          '27' => 3,
          '28' => 4,
          '29' => 4,
          '87' => 3,
          '88' => 3,
          '141' => 2,
          '142' => 2,
          '143' => 4,
          '204' => 2,
          '619' => 6,
          '39' => 2,
          '40' => 2,
          '41' => 4,
          '42' => 4,
          '43' => 3,
          '44' => 2,
          '45' => 3,
          '46' => 3,
          '47' => 3,
          '63' => 12,
          '70' => 3,
          '170' => 3,

          'X10' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20,slots:3;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;label=Atl',
          },
          'X20' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:3;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Atl',
          },
          'X21' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Mob',
          },
          'X22' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=P',
          },
          '442' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=BHM',
          },
          '443' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Mgm',
          },
          '453' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Aug',
          },
          '598' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=P',
          },
          '599' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:4,b:_0;path=a:0,b:_0;label=P',
          },

          'X30' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;'\
                      'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=Atl',
          },
          'X31' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Mob',
          },
          'X32' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=BHM',
          },
          'X33' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;'\
                      'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=Mgm',
          },
          '456' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Aug',
          },
          '457' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Bru',
          },
          '458' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=Mac',
          },
          'X40' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:4;'\
                      'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=Atl',
          },
          'X44' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;'\
                      'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=P',
          },
          '446' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;'\
                      'path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=BHM',
          },
        }.freeze
      end
    end
  end
end
