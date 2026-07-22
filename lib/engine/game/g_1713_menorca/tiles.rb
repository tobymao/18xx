# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Tiles
        TILES = {
          'PN1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'PN2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'PN3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'PN4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:40;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'TA1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:5,b:_0,track:narrow;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          'TA2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:5,b:_0,track:narrow;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          'TA3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:5,b:_0,track:narrow;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          'TA4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:40;path=a:5,b:_0,track:narrow;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          'TC1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'TC2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'TC3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'TC4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:40;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'CF1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'CF2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'CF3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'CF4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:40;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'IA1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'IA2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'IA3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:30;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'IA4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:40;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'CI2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0;icon=image:port',
          },
          'CI3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0;icon=image:port',
          },
          'CI4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0;icon=image:port',
          },
          'MO2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;icon=image:port',
          },
          'MO3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;icon=image:port',
          },
          'MO4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;icon=image:port',
          },
          'ME2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
          'ME3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'ME4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:40,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'FE2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;icon=image:port',
          },
          'FE3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;icon=image:port',
          },
          'FE4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;icon=image:port',
          },
          'F1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10,to_city:1;path=a:0,b:_0;path=a:3,b:_0',
          },
          'F2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
          },
          'F3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0',
          },
          'MG1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:2,b:_0;path=a:4,b:_0',
          },
          'MG2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:15;path=a:2,b:_0;path=a:4,b:_0',
          },
          'MG3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:2,b:_0;path=a:4,b:_0',
          },
          'AL1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:1,b:_0;path=a:4,b:_0',
          },
          'AL2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
          },
          'AL3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:4,b:_0',
          },
          'PA1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
          },
          'PA2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:15;path=a:0,b:_0;path=a:1,b:_0',
          },
          'SL2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:15;path=a:2,b:_0;path=a:3,b:_0',
          },
          'SL3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:25;path=a:2,b:_0;path=a:3,b:_0',
          },
          'E1W1' => {
            'count' => 10,
            'color' => 'blue',
            'code' => 'path=a:1,b:4,track:narrow',
          },
          'E1W2' => {
            'count' => 10,
            'color' => 'blue',
            'code' => 'path=a:1,b:3,track:narrow',
          },
          'E1W3' => {
            'count' => 10,
            'color' => 'blue',
            'code' => 'path=a:1,b:2,track:narrow',
          },
          'E2W1' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:3,b:0,track:narrow;path=a:4,b:0,track:narrow',
          },
          'E2W2' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:3,b:0,track:narrow;path=a:0,b:2,track:narrow',
          },
          'E2W3' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:4,b:0,track:narrow;path=a:0,b:2,track:narrow',
          },
          'E2W4' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:3,b:0,track:narrow;path=a:5,b:0,track:narrow',
          },
          'E2W5' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:3,b:0,track:narrow;path=a:0,b:1,track:narrow',
          },
          'E2W6' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:1,b:0,track:narrow;path=a:0,b:2,track:narrow',
          },
          'E2W7' => {
            'count' => 4,
            'color' => 'blue',
            'code' => 'path=a:4,b:0,track:narrow;path=a:5,b:0,track:narrow',
          },

          'E1T1' => {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'path=a:1,b:4',
          },
          'E1T2' => {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'path=a:1,b:3',
          },
          'E1T3' => {
            'count' => 6,
            'color' => 'yellow',
            'code' => 'path=a:1,b:2',
          },
          'E2T1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:1,b:4;path=a:2,b:5',
          },
          'E2T2' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:3,b:0;path=a:4,b:0',
          },
          'E2T3' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:3,b:0;path=a:0,b:2',
          },
          'E2T4' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:4,b:0;path=a:0,b:2',
          },
          'E2T5' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:3,b:0;path=a:5,b:0',
          },
          'E2T6' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:3,b:0;path=a:0,b:1',
          },
          'E2T7' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:1,b:0;path=a:0,b:2',
          },
          'E2T8' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:4,b:0;path=a:5,b:0',
          },
          'E3T1' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:4,b:0;path=a:0,b:2;path=a:2,b:4',
          },
        }.freeze
      end
    end
  end
end
