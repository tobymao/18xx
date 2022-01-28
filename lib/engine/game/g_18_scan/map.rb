# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module Engine
  module Game
    module G18Scan
      module Map
        TILE_TYPE = :lawson

        LAYOUT = :pointy

        TILES = {
          '5' => 12,
          '8' => 8,
          '9' => 8,
          '58' => 7,
          '403' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10,loc:0;city=revenue:30,loc:3;path=a:0,b:_0;path=a:_0,b:_1;label=COP',
          },
          '15' => 6,
          '80' => 3,
          '81' => 3,
          '82' => 3,
          '83' => 3,
          '121' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=COP;',
          },
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '622' => 3,
          '145' => 3,
          '146' => 3,
          '147' => 3,
          '544' => 3,
          '545' => 3,
          '546' => 3,
          '582' => 1,
          '584' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=COP;',
          },
          '623' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Newcastle',
          'A18' => 'Narvik',
          'A20' => 'Kiruna',
          'B5' => 'Bergen',
          'B11' => 'Trondheim',
          'B19' => 'Gällivare',
          'C4' => 'Stavanger',
          'C12' => 'Östersund',
          'C18' => 'Luleå',
          'D5' => 'Kristiansand',
          'D7' => 'Oslo',
          'D15' => 'Umea',
          'D19' => 'Oulu',
          'E4' => 'Arhus',
          'E6' => 'Goteborg',
          'E10' => 'Gävle',
          'F3' => 'Odense & Copenhagen',
          'F7' => 'Norrköping',
          'F11' => 'Stockholm',
          'F13' => 'Turku',
          'F15' => 'Tampere',
          'G2' => 'Stettin',
          'G4' => 'Malmö',
          'G12' => 'Ferry crossing',
          'G14' => 'Helsinki',
          'G16' => 'Lahti',
          'H13' => 'Tallin',
          'H17' => 'Vyborg',
        }.freeze

        HEXES = {
          red: {
            ['A4'] => 'city=revenue:yellow_20|green_50|brown_80;path=a:5,b:_0,terminal:1',
            ['A20'] => 'town=revenue:yellow_10|green_50|brown_10;junction;path=a:0,b:_0;path=a:1,b:_0',
            ['F1'] => 'city=revenue:yellow_20|green_30|brown_50;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['G2'] => 'city=revenue:yellow_10|green_30|brown_60;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['H13'] => 'city=revenue:yellow_0|green_30|brown_60;path=a:3,b:_0,terminal:1',
            ['H17'] => 'city=revenue:yellow_30|green_50|brown_80;path=a:2,b:_0,terminal:1',
          },
          yellow: {
            # TODO: Stockholm
            ['F11'] => 'city=revenue:30,loc:0.5;city=revenue:30,loc:2.5;path=a:1,b:_0;path=a:2,b:_1;border=edge:4,type:impassable,color:blue;label=Y',
          },
          white: {
            %w[A6 A8 A10 A14 A16 B7 B9 B13 B15 B17 C6 C8 C10] => 'upgrade=cost:60,terrain:mountain',
            %w[C14 C16 D9 D11 E2 E8 E14 E16 E18 F5 F9 F17 G6 G8] => 'blank',
            %w[B19 C4 E6 F15] => 'city',
            %w[C12 C18 E10 F7 G16] => 'town',
            ['A18'] => 'city=revenue:30;upgrade=cost:60,terrain:mountain',
            ['B5'] => 'city=revenue:30;border=edge:0,type:impassable,color:blue',

            # TODO: Trondheim
            ['B11'] => 'city=revenue:30;upgrade=cost:60,terrain:mountain',

            ['D5'] => 'town=revenue:0;border=edge:0,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',

            # TODO: Oslo
            ['D7'] => 'city=revenue:30;label=Y',

            ['D13'] => 'border=edge:5,type:impassable,color:blue',
            ['D15'] => 'city=revenue:30;border=edge:0,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
            ['D17'] => 'border=edge:0,type:impassable,color:blue;border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
            ['D19'] => 'town=revenue:0;border=edge:1,type:impassable,color:blue',
            ['E4'] => 'city=revenue:30;border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
            ['E12'] => 'border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',

            ['F3'] => 'city=revenue:30,loc:4.5;town=revenue:0,loc:1.5;upgrade=cost:40,terrain:water;label=COP',

            ['F13'] => 'city=revenue:30;border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue',

            # TODO: Malmo
            ['G4'] => 'city=revenue:30;upgrade=cost:40,terrain:water',

            # TODO: Helsinki
            ['G14'] => 'city=revenue:30;label=Y',
          },
          gray: {
            ['G12'] => 'path=a:2,b:3',
          },
        }.freeze
      end
    end
  end
end

# rubocop:enable Layout/LineLength
