# frozen_string_literal: true

module Engine
  module Game
    module G1826
      module Map
        TILES = {
          # yellow
          '3' => 2,
          '4' => 6,
          '5' => 2,
          '6' => 2,
          '7' => 4,
          '8' => 18,
          '9' => 23,
          '57' => 4,
          '58' => 6,
          # green
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 5,
          '24' => 5,
          '25' => 3,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '87' => 2,
          '88' => 2,
          '141' => 1,
          '142' => 1,
          '143' => 1,
          '203' => 1,
          '204' => 2,
          '514' => 1,
          '619' => 3,
          # brown
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 3,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 3,
          '63' => 5,
          '70' => 1,
          '515' => 1,
          '611' => 2,
          # gray
          '513' => 3,
          '516' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A13' => 'Amsterdam',
          'B8' => 'London',
          'B10' => 'Ostende',
          'B12' => 'Antwerp',
          'C9' => 'Calais',
          'C11' => 'Lille',
          'C13' => 'Brussels',
          'C15' => 'Liege',
          'C17' => 'Cologne',
          'D10' => 'Amiens',
          'D12' => 'Mons',
          'D14' => 'Namur',
          'D16' => 'Luxembourg',
          'E5' => 'Le Havre',
          'E7' => 'Rouen',
          'E15' => 'Metz',
          'F12' => 'Reims',
          'F14' => 'Nancy',
          'G19' => 'Strasbourg',
          'H2' => 'Rennes',
          'H6' => 'Le Mans',
          'H18' => 'Mulhouse',
          'I1' => 'Nantes',
          'I3' => 'Angers',
          'I7' => 'Orléans',
          'I13' => 'Dijon',
          'I17' => 'Besancon',
          'I19' => 'Basel',
          'J6' => 'Tours',
          'K5' => 'Poitiers',
          'K11' => 'Clermont-Ferrand',
          'K17' => 'Geneva',
          'L8' => 'Limoges',
          'L14' => 'Lyon',
          'M3' => 'Bordeaux',
          'M13' => 'St-Etienne',
          'M17' => 'Grenoble',
          'M19' => 'Milan',
          'N2' => 'Madrid',
          'N16' => 'Marseille',
        }.freeze

        HEXES = {
          red: {
            ['A13'] => 'offboard=revenue:yellow_20|brown_50|blue_70|gray_70;path=a:0,b:_0;path=a:5,b:_0',
            ['B8'] => 'offboard=revenue:yellow_40|brown_60|blue_80|gray_120;path=a:4,b:_0;path=a:5,b:_0',
            ['C17'] => 'offboard=revenue:yellow_20|brown_40|blue_60|gray_100;path=a:0,b:_0;path=a:1,b:_0',
            ['I19'] => 'offboard=revenue:yellow_20|brown_50|blue_70|gray_100;path=a:2,b:_0',
            ['M19'] => 'offboard=revenue:yellow_30|brown_50|blue_90|gray_120;path=a:1,b:_0',
            ['N2'] => 'offboard=revenue:yellow_20|brown_50|blue_70|gray_100;path=a:3,b:_0',
            ['N16'] => 'offboard=revenue:yellow_40|brown_60|blue_80|gray_80;path=a:2,b:_0',
          },
          gray: {
            ['E5'] => 'city=revenue:40;path=a:5,b:_0;path=a:4,b:_0',
            ['G19'] => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['I1'] => 'city=revenue:40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['K17'] => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0',
            ['M3'] => 'city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          white: {
            %w[
              D8
              E9
              E11
              E13
              F14
              F18
              G3
              G5
              G7
              G11
              G13
              G15
              G17
              H4
              H8
              H10
              H12
              H14
              H16
              I9
              I11
              I15
              J2
              J4
              J8
              J12
              J14
              J16
              K3
              K7
              K13
              K15
              L4
              L6
              L16
              M7
              M9
              M11
            ] => 'blank',
            %w[B14 F6 F8 F10 I5 M5 M15] => 'upgrade=cost:40,terrain:water',
            %w[E17 J10 K9 L10 L12] => 'upgrade=cost:60,terrain:mountain',
            %w[B10 C9 D10 D12 F16 H2 H18 I17 J6 K5 L8] => 'town=revenue:0',
            %w[E7 I3] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[D14 D16 K11 M17] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[E15 H6 I13 M13] => 'city=revenue:0',
            %w[B12 C15 F12] => 'city=revenue:0;upgrade=cost:40,terrain:water',
          },
          yellow: {
            ['C11'] => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0',
            ['G9'] => 'city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;'\
                      'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=P',
            ['I7'] => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0',
          },
          green: {
            ['C13'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['L14'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
