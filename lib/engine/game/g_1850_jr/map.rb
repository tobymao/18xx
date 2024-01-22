# frozen_string_literal: true

module Engine
  module Game
    module G1850Jr
      module Map
        TILES = {
          # yellow
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 4,
          '8' => 8,
          '9' => 7,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '69' => 1,
          # green
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '53' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
          },
          '54' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=P',
          },
          '59' => 1,
          # brown
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '61' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:1,b:_0;label=C',
          },
          '62' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:2;city=revenue:80,slots:2;path=a:0,b:_0;'\
                      'path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=P',
          },
          '63' => 2,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A5' => 'Tunisia',
          'B4' => 'Trapani & Marsala',
          'C1' => 'Genova',
          'C3' => 'Partinico & Alcamo',
          'D2' => 'Palermo',
          'D6' => 'Girgenti',
          'E5' => 'Caltanissetta',
          'E9' => 'Malta',
          'F2' => 'San Stefano',
          'F6' => 'Caltagirone',
          'F8' => 'Terranova',
          'G5' => 'Catania',
          'H0' => 'Napoli',
          'H2' => 'Messina',
          'H8' => 'Siracusa',
          'I1' => 'Villa San Giovanni',
          'I3' => 'Taranto',
        }.freeze

        HEXES = {
          blue: {
            %w[A5 E9] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:4,b:_0;icon=image:port;',
            ['C1'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:5,b:_0;icon=image:port;'\
                      'border=edge:0,type:impassable',
            ['H0'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:0,b:_0;icon=image:port',
            ['I1'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:1,b:_0;icon=image:port',
            ['I3'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:2,b:_0;icon=image:port',
          },
          white: {
            %w[B2 E3 E7 G9 H4] => '',
            %w[C5 D4 F4 G7] => 'upgrade=cost:120,terrain:mountain',
            %w[D6 F8 H2] => 'city=revenue:0',
            %w[F2 F6] => 'town=revenue:0;upgrade=cost:120,terrain:mountain',
            ['G3'] => 'upgrade=cost:120,terrain:mountain;border=edge:0,type:impassable',
            ['C3'] => 'town=revenue:0;town=revenue:0;border=edge:3,type:impassable',
            ['E5'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
          },
          yellow: {
            ['B4'] => 'city=revenue:0;city=revenue:0;label=OO',
            ['D2'] => 'city=revenue:40;city=revenue:40;path=a:2,b:_0;path=a:5,b:_1;label=P',
            ['G5'] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;border=edge:3,type:impassable;label=C',
          },
          gray: {
            ['A3'] => 'path=a:4,b:5',
            ['G1'] => 'path=a:1,b:5',
            ['H6'] => 'path=a:0,b:1',
            ['H8'] => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
