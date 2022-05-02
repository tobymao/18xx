# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Map
        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        LOCATION_NAMES = {
          'A13' => 'Louisville',
          'A17' => 'Lexington',
          'B4' => 'St. Louis',
          'B10' => 'Clarksville',
          'B22' => 'Bristol Coalfields',
          'C5' => 'Dyersburg',
          'C11' => 'Nashville',
          'C13' => 'Lebanon',
          'C17' => 'Knoxville',
          'D6' => 'Jackson',
          'D12' => 'Murfreesboro',
          'E1' => 'Little Rock',
          'E3' => 'Memphis',
          'E7' => 'Cornith',
          'E15' => 'Chattanooga',
          'E23' => 'Greenville',
          'F6' => 'Tupelo',
          'F10' => 'Huntsville',
          'F14' => 'Gadsen',
          'F16' => 'Rome',
          'G3' => 'Grenada',
          'G13' => 'Anniston',
          'G17' => 'Atlanta',
          'G23' => 'Augusta',
          'H6' => 'Starkville',
          'H8' => 'Tuscaloosa',
          'H10' => 'Birmingham',
          'H20' => 'Milledgeville',
          'H28' => 'Charleston',
          'I7' => 'York',
          'I19' => 'Macon',
          'J2' => 'Jackson',
          'J6' => 'Meridian',
          'J10' => 'Selma',
          'J12' => 'Montgomery',
          'J16' => 'Columbus',
          'J24' => 'Statesboro',
          'J26' => 'Savannah',
          'K17' => 'Albany',
          'L4' => 'Hattiesburg',
          'L14' => 'Dothan',
          'L20' => 'Valdosta',
          'L22' => 'Waycross',
          'L24' => 'Brunswick',
          'M5' => 'Gulfport',
          'M7' => 'Mobile',
          'M9' => 'Pensacola',
          'M17' => 'Tallahassee',
          'M25' => 'Jacksonville',
          'N2' => 'New Orleans',

        }.freeze

        HEXES = {
          red: {
            ['B4'] => 'offboard=revenue:yellow_30|brown_70;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0',
            ['E1'] => 'offboard=revenue:yellow_30|brown_50;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0',
            ['A17'] => 'offboard=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:5,b:_0',
            ['B22'] => 'offboard=revenue:yellow_60|brown_40;path=a:0,b:_0;path=a:1,b:_0',
            ['E23'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0',
            ['H28'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;city=revenue:0',
            ['N2'] => 'city=revenue:yellow_50|brown_80,loc:center;town=revenue:10,loc:5.5;path=a:3,b:_0;path=a:_1,b:_0;',
          },
          gray: {
            ['M17'] => 'city=revenue:yellow_20|brown_50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
            ['J26'] => 'city=revenue:yellow_30|brown_60,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_0;',
            ['J2'] => 'city=revenue:yellow_30|brown_60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
            ['M25'] => 'city=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:2,b:_0',
            ['A13'] => 'city=revenue:40;path=a:0,b:_0;path=a:5,b:_0;',
          },
          white: {
            %w[B6 B12 B18 B20
               C3 C7
               D2 D4 D10
               E5 E11
               F2 F4 F8 F20 F22
               G5 G7 G9 G11 G15 G19 G21
               H2 H4 H12 H14 H18 H22 H24 H26
               I3 I5 I9 I11 I13 I17 I23 I25
               J4 J14 J18 J20
               K5 K11 K13 K19 K21
               L6 L10 L12 L18
               M11 M13 M15 M19 M21 M23] => 'blank',
            %w[L2 K3 L8 K7 K9 J8 L16 K15 I15 H16 K25 K23 J22 I21 F18 I27] => 'upgrade=cost:20,terrain:river',
            %w[B8 C9 D8 E9 F12 D16 M3] => 'upgrade=cost:40,terrain:river',
            %w[E19 E21 B14 B16 C15 D14 E13] => 'upgrade=cost:60,terrain:mountain',
            %w[C19 C21 D18 D20 E17] => 'upgrade=cost:120,terrain:mountain',

            %w[B10 C5 C13 G3 H6 I7 J24 L4 L14 L20 M5] => 'town',
            %w[M9 H20] => 'town=revenue:0;upgrade=cost:20,terrain:river',
            %w[F10] => 'town=revenue:0;upgrade=cost:40,terrain:river',

            %w[D12 E7 F6 F14 G13 H8 J6 J10 K17 L22] => 'city=revenue:0',
            %w[G23] => 'city=revenue:0;future_label=label:Aug,color:brown',
            %w[H10] => 'city=revenue:0;future_label=label:Bhm,color:green',
            %w[M7] => 'city=revenue:0;future_label=label:Mob,color:green',
            %w[I19] => 'city=revenue:0;future_label=label:Mac,color:brown',
            %w[C11] => 'city=revenue:0;future_label=label:Nash,color:green',
            %w[L24] => 'city=revenue:0;future_label=label:Bru,color:brown',
            %w[E3] => 'city=revenue:0;future_label=label:Mem,color:green',
            %w[D6] => 'city=revenue:20',
            %w[G17] => 'city=revenue:0,slots:3;label=Atl',
            %w[J16] => 'city=revenue:0;upgrade=cost:20,terrain:river',
            %w[C17] => 'city=revenue:0;upgrade=cost:40,terrain:river',

          },
          yellow: {
            ['J12'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:3,b:_0;label=Mgm',
            ['F16'] => 'town=revenue:10;path=a:2,b:_0;path=a:5,b:_0',
            ['E15'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;future_label=label:Chat,color:green',
          },
        }.freeze
      end
    end
  end
end
