# frozen_string_literal: true

module Engine
  module Game
    module G18EUS
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        TILES = {
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '57' => 'unlimited',
          '60' => 'unlimited',
          '63' => 'unlimited',
          '80' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '455' => 3,
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '619' => 'unlimited',
          'X07' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10,visit_cost:0;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=RJ',
          },
          'X08' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10,visit_cost:0;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=RJ',
          },
          'X09' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10,visit_cost:0;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=RJ',
          },
          'X12' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60,slots:2;city=revenue:60;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,'\
                      'b:_1;label=NY',
          },
          'X17' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
          'NYB' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY',
          },
          'NYG' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
          },
          'CHI1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=CHI',
          },
          'CHI2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=CHI',
          },
          'CHI3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0,lanes:2;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=CHI',
          },
          'CHI4' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0,lanes:2;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=CHI',
          },
          'M1' =>
          {
            'count' => 1,
            'hidden' => true,
            'color' => 'yellow',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=M',
          },
          'M2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          'M3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=M',
          },
          'M4' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;' \
                      'path=a:5,b:_0;label=M',
          },
          'RA' =>
          {
            'count' => 2,
            'hidden' => true,
            'color' => 'red',
            'code' => 'city=revenue:0,slots:1;path=a:0,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:5,b:_0',
          },
          'RB' =>
          {
            'count' => 2,
            'hidden' => true,
            'color' => 'red',
            'code' => 'city=revenue:0,slots:1;path=a:2,b:_0;path=a:3,b:_0;' \
                      'path=a:4,b:_0;path=a:5,b:_0',
          },
          'RC' =>
          {
            'count' => 2,
            'hidden' => true,
            'color' => 'red',
            'code' => 'city=revenue:0,slots:1;path=a:0,b:_0;path=a:2,b:_0;' \
                      'path=a:3,b:_0;path=a:4,b:_0',
          },
          'GK50' =>
          {
            'count' => 3,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',

          },
        }.freeze

        RURAL_JUNCTION_TILE_NAMES = %w[X07 X08 X09].freeze
        RED_CITY_TILE_NAMES = %w[RA RB RC].freeze
        METROPOLIS_TILE_NAME = 'M1'

        LOCATION_NAMES = {
          'A15' => 'Montreal',
          'C3' => 'Milwaukee',
          'C5' => 'Grand Haven',
          'C9' => 'Toronto',
          'C13' => 'Rochester',
          'C17' => 'Boston',
          'D0' => 'The West',
          'D2' => 'Chicago',
          'D8' => 'Detroit',
          'D10' => 'Cleveland',
          'D16' => 'New York',
          'E7' => 'Toledo',
          'E11' => 'Pittsburgh',
          'E15' => 'Philadelphia',
          'F4' => 'Indianapolis',
          'F8' => 'Columbus',
          'F14' => 'Baltimore',
          'G7' => 'Cincinnati',
          'G11' => 'WV Coal',
          'G15' => 'Norfolk',
          'H2' => 'St. Louis',
          'H6' => 'Louisville',
          'H12' => 'Charlotte',
          'I9' => 'Knoxville',
          'J4' => 'Memphis',
          'J8' => 'Atlanta',
          'J12' => 'Charleston',
          'K11' => 'Savannah',
          'L10' => 'Florida',
        }.freeze

        HEXES = {
          red: {
            %w[A15] => 'offboard=revenue:0;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[C3] => 'offboard=revenue:0;path=a:0,b:_0,lanes:2',
            %w[C9] => 'city=revenue:0;path=a:0,b:_0;path=a:4,b:_0',
            %w[D0] => 'offboard=revenue:0;path=a:4,b:_0;path=a:5,b:_0',
            %w[G11] => 'city=revenue:0;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            %w[H2] => 'city=revenue:0;path=a:3,b:_0;path=a:4,b:_0',
            %w[J4] => 'offboard=revenue:0;path=a:3,b:_0;path=a:4,b:_0',
            %w[L10] => 'city=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
          },
          gray: {
            %w[C11] => 'junction;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[K7] => 'junction;path=a:3,b:_0,terminal:1',
          },
          blue: {
            %w[B12] => 'junction;path=a:5,b:_0,terminal:1',
            %w[F16] => 'junction;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
          },
          white: {
            %w[A17 B6 B14 B16 B18 C7 C15 D4 D6 D12 D14 E1 E3 E5 E9 E13 F2 F6 F10 F12 G3 G5 G9 G13 H4 H8 H10 H14 I5 I7 I11 I13 J6
               J10 K9] => '',
            %w[C5 C13 C17 D2 D8 D10 D16 E7 E11 E15 F4 F8 F14 G7 G15 H6 H12 I9 J8 J12 K11] => 'city=revenue:0',
          },
          yellow: {
            %w[D16] => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:3,b:_0;label=NY',
          },
        }.freeze
      end
    end
  end
end
