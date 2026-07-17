# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Tiles
        # rubocop:disable Layout/LineLength
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
          # Standard broad-gauge plain track
          '7' => 6,
          '8' => 6,
          '9' => 6,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '40' => 1,
          # Standard narrow-gauge plain track
          '77' => 10,
          '78' => 10,
          '79' => 10,
          '677' => 4,
          '678' => 4,
          '692' => 4,
          '693' => 4,
          '694' => 4,
          '695' => 4,
          '699' => 4,
        }.freeze
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
