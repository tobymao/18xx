# frozen_string_literal: true

module Engine
  module Game
    module G18EUS
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        TILES = {}.freeze

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
