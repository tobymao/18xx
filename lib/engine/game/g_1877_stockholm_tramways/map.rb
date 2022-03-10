# frozen_string_literal: true

module Engine
  module Game
    module G1877StockholmTramways
      module Map
        TILES = {
          '4' => 2,
          '6' => 4,
          '8' => 4,
          '9' => 4,
          '19' => 1,
          '23' => 1,
          '24' => 1,
          '25' => 1,
          '58' => 3,
          '141' => 1,
          '142' => 1,
          '144' => 1,
          '147' => 2,
          '441' => 2,
          '442' => 2,
          '448' => 2,
          '546' => 1,
          'X1' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:_0,b:3;label=C',
          },
          'X2' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:5;label=L',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2,loc:0;city=revenue:50;'\
                      'path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;label=N',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=L',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=N',
          },
          'X9' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2,loc:0;city=revenue:70;'\
                      'path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;path=a:_1,b:4;label=N',
          },
          'X10' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
          },
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Norrtälje',
          'B8' => 'Rimbo',
          'C7' => 'Djursholm',
          'C11' => 'Kyrkviken',
          'D2' => 'Sundbyberg',
          'D4' => 'Råsunda',
          'D10' => 'Lidingö',
          'E1' => 'Ulvsunda',
          'E7' => 'Östermalm',
          'E11' => 'Skärsätra',
          'F2' => 'Alvik',
          'F4' => 'Kungsholmen',
          'F6' => 'Norrmalm',
          'F8' => 'Djurgården',
          'G1' => 'Ålsten',
          'G5' => 'Liljeholmen',
          'G7' => 'Södermalm',
          'G9' => 'Sickla',
          'G11' => 'Saltsjö-Duvnäs',
          'H4' => 'Mälarhöjden',
          'H8' => 'Enskede',
          'I5' => 'Örby',
          'I7' => 'Brännkyrka',
          'I9' => 'Gubbängen',
          'I13' => 'Saltsjöbaden',
        }.freeze

        HEXES = {
          white: {
            %w[E5 H6] => 'blank',
            %w[B10 C9 D6 D8 D12 E3 E9 F10 G3 H10 H12 I11] => 'upgrade=cost:40,terrain:water',
            %w[B8 C11 I5 I9] => 'town',
            %w[F2 G5 G9] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[D2 C7 E11 G11 H8 I7] => 'city=revenue:0',
            ['F8'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['E7'] => 'city=revenue:0;label=C',
            ['F4'] => 'city=revenue:0;label=C;upgrade=cost:40,terrain:water',
          },
          yellow: {
            ['D4'] => 'city=revenue:20;path=a:1,b:_0;path=a:_0,b:5',
            ['D10'] =>
            'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:5;label=L',
            ['F6'] => 'city=revenue:30,loc:0;city=revenue:30;'\
                      'path=a:1,b:_0;path=a:2,b:_1;path=a:_1,b:3;label=N;upgrade=cost:40,terrain:water',
            ['G7'] => 'city=revenue:10;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S;upgrade=cost:40,terrain:water',
            ['H4'] => 'city=revenue:20;path=a:3,b:_0;path=a:_0,b:5',
          },
          gray: {
            ['A9'] => 'city=revenue:yellow_40|brown_30;path=a:0,b:_0;path=a:_0,b:5',
            ['C3'] => 'path=a:0,b:5',
            ['E1'] => 'town=revenue:30;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['G1'] => 'city=revenue:yellow_10|brown_30;path=a:3,b:_0;path=a:4,b:_0',
            ['I13'] => 'city=revenue:yellow_60|brown_40;path=a:1,b:_0;path=a:2,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
