# frozen_string_literal: true

module Engine
  module Game
    module G18GA
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          'I11' => 'Brunswick',
          'C3' => 'Rome',
          'D4' => 'Atlanta',
          'D10' => 'Augusta',
          'E7' => 'Milledgeville',
          'F6' => 'Macon',
          'G3' => 'Columbus',
          'H4' => 'Albany',
          'I9' => 'Waycross',
          'J12' => 'Jacksonville',
          'E1' => 'Montgomery',
          'J4' => 'Tallahassee',
          'A3' => 'Chattanooga',
          'B10' => 'Greeneville',
          'G13' => 'Savannah',
          'G11' => 'Statesboro',
          'I7' => 'Valdosta',
        }.freeze

        HEXES = {
          white: {
            %w[B4
               C7
               C9
               D2
               D6
               D8
               E5
               E9
               F4
               F10
               G1
               G5
               G7
               H6
               H8
               I5
               J6
               J8
               E11] => '',
            %w[C5 E3 F2 F8 G9 H2 H10 H12 I3] => 'upgrade=cost:20,terrain:water',
            %w[F12 J10] => 'upgrade=cost:40,terrain:water',
            %w[B2 B6 B8 C1] => 'upgrade=cost:60,terrain:water',
            ['D4'] => 'city=revenue:0;city=revenue:0;city=revenue:0;label=ATL;',
            %w[I11 C3 D10 F6 G3 H4 G13] => 'city=revenue:0',
            ['I9'] => 'city=revenue:0;icon=image:18_ga/wsr,sticky:1',
            %w[G11 I7] => 'town=revenue:0',
            ['E7'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
          },
          red: {
            ['J12'] => 'city=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0',
            ['A3'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:5,b:_0',
            ['B10'] => 'offboard=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:1,b:_0',
          },
          gray: {
            ['E1'] =>
                     'city=revenue:yellow_30|brown_40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J4'] =>
            'city=revenue:yellow_20|brown_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze
      end
    end
  end
end
