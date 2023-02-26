# frozen_string_literal: true

module Engine
  module Game
    module G1836Jr30
      module Map
        TILES = {
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 4,
          '8' => 8,
          '9' => 7,
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
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '53' => 2,
          '54' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '59' => 2,
          '61' => 2,
          '62' => 1,
          '63' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Leeuwarden',
          'A13' => 'Hamburg',
          'B8' => 'Enkhuizen & Stavoren',
          'B10' => 'Groningen',
          'D6' => 'Amsterdam',
          'E5' => 'Rotterdam & Den Haag',
          'E7' => 'Utrecht',
          'E11' => 'Arnhem & Nijmegen',
          'F4' => 'Hoek van Holland',
          'F10' => 'Eindhoven',
          'G7' => 'Antwerp',
          'H2' => 'Bruges',
          'H4' => 'Gand',
          'H6' => 'Brussels',
          'H10' => 'Maastricht & Liège',
          'I3' => 'Lille',
          'I9' => 'Namur',
          'J6' => 'Charleroi',
          'J8' => 'Hainaut Coalfields',
          'E3' => 'Harwich',
          'G1' => 'Dover',
          'J2' => 'Paris',
          'E13' => 'Dortmund',
          'H12' => 'Cologne',
          'K11' => 'Arlon & Luxembourg',
          'K13' => 'Strasbourg',
        }.freeze

        HEXES = {
          gray: { ['A9'] => 'city=revenue:10;path=a:0,b:_0;path=a:_0,b:5' },
          white: {
            %w[A11 B12 C11 D12 E9 H8 I5 I7 K5 J4] => 'blank',
            ['C7'] => 'border=edge:4,type:impassable,color:blue',
            ['C9'] => 'border=edge:1,type:impassable,color:blue',
            ['G3'] => 'border=edge:3,type:impassable,color:blue',
            ['G5'] => 'border=edge:2,type:impassable,color:blue;border=edge:3,type:impassable,color:blue',
            ['B8'] => 'town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:water',
            %w[B10 E7 G7 H4 J6] => 'city=revenue:0',
            %w[D8 D10 F8 G9 G11] => 'upgrade=cost:40,terrain:water',
            ['F4'] =>
            'town=revenue:0;upgrade=cost:40,terrain:water;'\
            'border=edge:0,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
            ['F6'] => 'upgrade=cost:80,terrain:water;border=edge:0,type:impassable,color:blue',
            %w[F10 H2] => 'town=revenue:0',
            %w[I11 J10 J12 K7 K9] => 'upgrade=cost:60,terrain:mountain',
            ['I9'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['J8'] => 'city=revenue:0;upgrade=cost:60,terrain:mountain',
            ['K11'] => 'town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:mountain',
          },
          red: {
            ['A13'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:1,b:_0',
            %w[E13 H12] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0',
            ['K13'] => 'offboard=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:2,b:_0',
          },
          yellow: {
            ['D6'] =>
                     'city=revenue:40;path=a:0,b:_0;path=a:_0,b:5;label=NY;upgrade=cost:40,terrain:water',
            ['E5'] => 'city=revenue:0;city=revenue:0;label=OO',
            %w[E11 H10] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water',
            ['H6'] => 'city=revenue:30;path=a:1,b:_0;path=a:_0,b:3;label=B',
            ['I3'] => 'city=revenue:30;path=a:0,b:_0;path=a:_0,b:4;label=B',
          },
          blue: {
            %w[E3 G1] =>
            'offboard=revenue:green_20|brown_30,format:+%s,groups:port,route:never;path=a:4,b:_0;path=a:5,b:_0',
          },
          green: {
            ['J2'] =>
            'offboard=revenue:green_20|brown_30,format:+%s,groups:port,route:never;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
