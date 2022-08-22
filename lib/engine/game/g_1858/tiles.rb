# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Tiles
        TILE_TYPE = :lawson
        FIRST_OR_MINOR_TILE_LAYS = [{ lay: true, upgrade: false }, { lay: true, upgrade: false }].freeze
        MINOR_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        TILES = {
          '1' => :unlimited,
          '2' => :unlimited,
          '3' => :unlimited,
          '4' => :unlimited,
          '5' => :unlimited,
          '6' => :unlimited,
          '7' => :unlimited,
          '8' => :unlimited,
          '9' => :unlimited,
          '14' => 2,
          '15' => 4,
          '55' => :unlimited,
          '56' => :unlimited,
          '57' => :unlimited,
          '58' => :unlimited,
          '69' => :unlimited,
          '71' => :unlimited,
          '72' => :unlimited,
          '73' => :unlimited,
          '74' => :unlimited,
          '75' => :unlimited,
          '76' => :unlimited,
          '77' => :unlimited,
          '78' => :unlimited,
          '79' => :unlimited,
          '80' => 2,
          '81' => 2,
          '82' => 4,
          '83' => 4,
          '84' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'junction;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          '85' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'junction;path=a:0,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          '86' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'junction;path=a:0,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          '87' => 4,
          '88' => 4,
          '89' => 1,
          '106' => 2,
          '107' => 2,
          '108' => 2,
          '112' => 2,
          '201' => :unlimited,
          '202' => :unlimited,
          '204' => 4,
          '207' => 4,
          '208' => 2,
          '619' => 2,
          '621' => :unlimited,
          '622' => 2,
          '630' => :unlimited,
          '631' => :unlimited,
          '660' => 1,
          '661' => 1,
          '662' => 1,
          '663' => 1,
          '664' => 1,
          '665' => 1,
          '666' => 1,
          '667' => 1,
          '668' => 1,
          '669' => 1,
          '670' => 1,
          '671' => 1,
          '673' => 4,
          '680' => 1,
          '681' => 1,
          '682' => 1,
          '683' => 1,
          '684' => 1,
          '685' => 1,
          '686' => 1,
          '687' => 1,
          '688' => 1,
          '689' => 1,
          '690' => 1,
          '691' => 1,
          '700' => 1,
          '701' => 1,
          '702' => 1,
          '703' => 1,
          '704' => 1,
          '705' => 1,
          '706' => 1,
          '707' => 1,
          '710' => 1,
          '711' => 1,
          '712' => 1,
          '713' => 1,
          '714' => 1,
          '715' => 1,
          'A1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40,slots:1;path=a:1,b:_0;path=a:2,b:_0;label=B',
          },
          'A2' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=B',
          },
          'A3' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:40,slots:1;path=a:1,b:_0;path=a:4,b:_0;label=B',
          },
          'A4' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'junction;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'A5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'town=revenue:10;' \
              'path=a:0,b:_0,track:narrow;path=a:3,b:_0,track:narrow;' \
              'path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'A6' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'town=revenue:10;' \
              'path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;' \
              'path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'A7' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
              'city=revenue:50,loc:1,slots:1;path=a:1,b:_0;' \
              'city=revenue:50,loc:2.5,slots:1;path=a:2,b:_1;' \
              'city=revenue:50,loc:4,slots:1;path=a:0,b:_2;path=a:4,b:_2;label=M',
          },
          'A8' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
          },
          'A9' =>
          {
            'count' => 4,
            'color' => 'brown',
            'code' =>
              'city=revenue:40,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;' \
              'path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'A10' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:40,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:3,b:_0,track:dual;' \
              'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'A11' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:3,b:_0,track:dual;' \
              'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=Y',
          },
          'A12' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;' \
              'path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=Y',
          },
          'A13' =>
          {
            'count' => 8,
            'color' => 'brown',
            'code' =>
              'town=revenue:10;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:3,b:_0,track:dual;' \
              'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'A14' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;label=L',
          },
          'A15' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:70,slots:3;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:3,b:_0,track:dual;' \
              'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=M',
          },
          'A16' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:3,b:_0,track:dual;' \
              'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=P',
          },
          'A17' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
              'city=revenue:60,slots:2;' \
              'path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;' \
              'path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;label=B',
          },
          'A18' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:70,slots:2;' \
              'path=a:0,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;label=L',
          },
          'A19' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:100,slots:3;' \
              'path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;' \
              'path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual;label=M',
          },
          'A20' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
              'city=revenue:80,slots:2;' \
              'path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;' \
              'path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;label=B',
          },
        }.freeze
      end
    end
  end
end
