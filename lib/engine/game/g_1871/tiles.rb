# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Tiles
        TILES = {
          '1' => 2,
          '3' => 8,
          '5' => 7,
          '6' => 7,
          '7' => 12,
          '8' => 25,
          '9' => 1,
          '16' => 3,
          '17' => 3,
          '21' => 2,
          '22' => 2,
          '25' => 4,
          '28' => 4,
          '29' => 4,
          '30' => 3,
          '31' => 3,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '56' => 2,
          '58' => 6,
          '70' => 1,
          '143' => 2,
          '144' => 2,
          '624' => 2,
          '625' => 2,
          '626' => 2,
          '627' => 1,
          '628' => 1,
          '629' => 1,
          '630' => 2,
          '631' => 2,
          '632' => 2,
          '633' => 2,
          '767' => 1,
          '769' => 1,
          'PEI1' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'PEI2' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'PEI3' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'PEI4' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:5,b:_0;path=a:0,b:_0;label=T',
          },
          'PEI5' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:3,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=X',
          },
          'PEI6' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=X',
          },
          'PEI7' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0;label=X',
          },
          'PEI8' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=X',
          },
          'PEI9' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'PEI10' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:0,b:_0;path=a:1,b:_0;label=T',
          },
          'PEI11' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=X',
          },
          'PEI12' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=X',
          },
          'PEI13' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=X',
          },
          'PEI14' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=X',
          },
          'PEI15' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;label=C',
          },
          'PEI16' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:1,b:_0;path=a:5,b:_0;path=a:4,b:_0;path=a:3,b:_0;path=a:2,b:_0;label=X',
          },
        }.freeze
      end
    end
  end
end
