# frozen_string_literal: true

module Engine
  module Game
    module G1860
      module Map
        TILES = {
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 4,
          '9' => 4,
          '12' => 2,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '57' => 2,
          '115' => 2,
          '205' => 1,
          '206' => 1,
          '625' => 1,
          '626' => 1,
          '741' =>
          {
            'count' => 5,
            'color' => 'yellow',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0',
          },
          '742' =>
          {
            'count' => 10,
            'color' => 'yellow',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:2,b:_0',
          },
          '743' =>
          {
            'count' => 7,
            'color' => 'yellow',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:3,b:_0',
          },
          '744' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' =>
            'halt=symbol:£,loc:0;halt=symbol:£,loc:3;path=a:0,b:_0;path=a:3,b:_1;path=a:_0,b:_1',
          },
          '745' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' =>
            'halt=symbol:£,loc:0;halt=symbol:£,loc:2;path=a:0,b:_0;path=a:2,b:_1;path=a:_0,b:_1',
          },
          '746' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:_0,b:3;label=B',
          },
          '747' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
          },
          '748' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:2',
          },
          '749' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3',
          },
          '750' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '751' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          '752' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          '753' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'halt=symbol:£;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '754' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'halt=symbol:£,loc:0;town=revenue:10,loc:center;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
            'path=a:_0,b:_1',
          },
          '755' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'halt=symbol:£,loc:0;town=revenue:10,loc:center;path=a:0,b:_0;path=a:4,b:_1;path=a:3,b:_1;'\
            'path=a:_0,b:_1',
          },
          '756' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0',
          },
          '757' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
          },
          '758' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:4,b:_0;path=a:5,b:_0;label=R',
          },
          '759' =>
          { 'count' => 3, 'color' => 'green', 'code' => 'city=revenue:30;path=a:0,b:_0' },
          '760' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,loc:4;city=revenue:40,loc:0.5;path=a:1,b:_1;path=a:2,b:_0;label=V',
          },
          '761' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:20,loc:center;halt=symbol:£,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
            'path=a:3,b:_1;path=a:_0,b:_1;label=M',
          },
          '762' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=B',
          },
          '763' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,loc:2.5;city=revenue:30,loc:5.5;path=a:1,b:_0;path=a:2,b:_0;'\
            'path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_1;label=N',
          },
          '764' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:1',
          },
          '765' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:3',
          },
          '766' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:2',
          },
          '767' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          '768' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '769' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          '770' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;label=B',
          },
          '771' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '772' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0',
          },
          '773' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2,loc:2.5;city=revenue:20,loc:5.5;path=a:1,b:_0;path=a:2,b:_0;'\
            'path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1;path=a:_0,b:_1;label=N',
          },
          '774' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,loc:4;city=revenue:50,loc:1;path=a:2,b:_0;path=a:1,b:_1,loc:0.5;label=V',
          },
          '775' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:20,slots:2,loc:center;town=revenue:10,loc:3;path=a:0,b:_0;path=a:1,b:_0;'\
            'path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1;label=M',
          },
          '776' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          '777' =>
          { 'count' => 2, 'color' => 'brown', 'code' => 'city=revenue:60;path=a:0,b:_0' },
          '778' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:5;path=a:2,b:4',
          },
          '779' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:4,b:5;path=a:1,b:3;path=a:0,b:2',
          },
          '780' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:1,b:2;path=a:4,b:5;path=a:0,b:3',
          },
          '781' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:1;path=a:2,b:3;path=a:4,b:5',
          },
          '782' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:2,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1',
          },
          '783' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;'\
            'path=a:3,b:_0;path=a:5,b:_0;path=a:_0,b:_1',
          },
          '784' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1',
          },
          '785' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;'\
            'path=a:3,b:_0;path=a:4,b:_0;path=a:_0,b:_1',
          },
          '786' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:4,b:_0;path=a:5,b:_0;label=R',
          },
          '787' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:20,loc:3;town=revenue:10,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;'\
            'path=a:_2,b:_1;path=a:_0,b:_1;label=C',
          },
          '788' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,loc:3;town=revenue:10,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;'\
            'path=a:1,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C',
          },
          '789' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,loc:3;town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;'\
            'path=a:1,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C',
          },
        }.freeze

        LOCATION_NAMES = {
          'A5' => 'Norton Green',
          'A7' => 'Totland',
          'G1' => 'East Cowes',
          'F2' => 'Cowes',
          'J2' => 'Ryde Pier',
          'G3' => 'Whippingham',
          'I3' => 'Ryde Esp',
          'B4' => 'Yarmouth',
          'F4' => 'Cement Mills',
          'H4' => 'Wooton & Havenstreet',
          'J4' => 'Ryde',
          'H8' => 'Horringford',
          'G11' => 'Whitwell',
          'F6' => 'Carisbrooke',
          'D6' => 'Calbourne',
          'E5' => 'Watchingwell',
          'C5' => 'Ningwood',
          'F10' => 'Chale Green',
          'G5' => 'Newport',
          'I5' => 'Ashey',
          'K5' => 'St. Helens',
          'B6' => 'Freshwater',
          'J8' => 'Sandown',
          'J6' => 'Brading',
          'L6' => 'Bembridge',
          'C7' => 'Shalcombe',
          'H10' => 'Wroxall',
          'H12' => 'St. Lawrence',
          'G7' => 'Merstone',
          'I7' => 'Newchurch & Alverstone',
          'E9' => 'Shorwell',
          'G9' => 'Godshill',
          'I9' => 'Shanklin',
          'I11' => 'Ventnor',
          'F12' => 'Chale',
        }.freeze

        HEXES = {
          white: {
            ['G1'] => 'town=revenue:0;border=edge:1,type:impassable',
            ['G3'] => 'town=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable',
            %w[H8 G11 F6 D6 E5 C5 F10] => 'town=revenue:0',
            %w[A5 F4] => 'town=revenue:0;border=edge:4,type:impassable',
            ['I5'] => 'town=revenue:0;border=edge:0,type:impassable',
            ['F2'] => 'city=revenue:0,loc:3;town=revenue:0,loc:1;town=revenue:0,loc:0;label=C;'\
                      'border=edge:4,type:impassable;border=edge:5,type:impassable',
            %w[H2 D4] => 'upgrade=cost:60,terrain:water',
            %w[E3 E11 K7 D8] => '',
            ['B4'] => 'city=revenue:0;border=edge:1,type:impassable',
            %w[J4 A7 B6 J8 L6 F12] => 'city=revenue:0',
            ['I9'] => 'city=revenue:0;border=edge:0,type:impassable',
            ['H4'] => 'town=revenue:0;town=revenue:0',
            ['I7'] => 'town=revenue:0;town=revenue:0;border=edge:3,type:impassable',
            ['K5'] => 'town=revenue:0;upgrade=cost:60,terrain:water',
            %w[C7 H10 H12] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[H6 E7 F8 G13] => 'upgrade=cost:60,terrain:mountain',
            %w[J6 E9 G9] => 'city=revenue:0;label=B',
          },
          blue: { ['J2'] => 'offboard=revenue:yellow_0|green_20|brown_40;path=a:1,b:_0' },
          yellow: {
            ['I3'] => 'city=revenue:30;path=a:5,b:_0;label=R',
            ['G5'] => 'city=revenue:30;path=a:2,b:_0;path=a:3,b:_0;label=N',
            ['G7'] => 'city=revenue:10;town=revenue:0;path=a:5,b:_0;label=M',
            ['I11'] =>
            'city=revenue:30;path=a:2,b:_0;label=V;border=edge:3,type:impassable',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
