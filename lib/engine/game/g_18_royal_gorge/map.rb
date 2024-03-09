# frozen_string_literal: true

module Engine
  module Game
    module G18RoyalGorge
      module Map
        LAYOUT = :flat

        TILES = {
          # yellow
          '3' => 5,
          '4' => 5,
          '5' => 3,
          '6' => 4,
          '7' => 4,
          '8' => 12,
          '9' => 12,
          '57' => 5,
          '58' => 5,
          'RG1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=R',
          },
          'RG4' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          # green
          '14' => 5,
          '15' => 5,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '87' => 2,
          '88' => 2,
          '143' => 2,
          '144' => 2,
          '204' => 1,
          'RG2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=R',
          },
          'RG5' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          'RG6' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          'RG-A' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:2,b:_0;path=a:5,b:_0;border=edge:1',
            # 'hidden' => 1,
          },
          'RG-B' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:40;path=a:2,b:_0;path=a:4,b:_0;border=edge:1',
            # 'hidden' => 1,
          },
          'RG-C' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60;path=a:1,b:_0;path=a:4,b:_0;border=edge:1',
            # 'hidden' => 1,
          },
          # brown
          '39' => 2,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '63' => 2,
          '911' => 3,
          'RG3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=R',
          },
          'RG7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          'RG8' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=S',
          },
          'RG-D' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;path=a:2,b:_0;path=a:5,b:_0;border=edge:1',
            # 'hidden' => 1,
          },
          'RG-E' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:60;path=a:2,b:_0;path=a:4,b:_0;border=edge:1',
            # 'hidden' => 1,
          },
          'RG-F' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80;path=a:1,b:_0;path=a:4,b:_0;border=edge:1',
            # 'hidden' => 1,
          },
          # gray
          '171' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A3' => 'Leadville',
          'B6' => 'Buena Vista',
          'B8' => 'Nathrop',
          'C11' => 'Salida',
          'C15' => 'Silverton',
          'C3' => 'Fairplay',
          'E19' => 'Crestone',
          'E3' => 'Sulphur Springs',
          'E13' => 'The Royal Gorge',
          'F16' => 'Westcliffe',
          'F6' => 'Guffy',
          'G9' => 'Current',
          'G17' => 'Silvercliffe',
          'H12' => 'Cañon City',
          'H14' => 'Coal Creek',
          'H4' => 'Divide',
          'I13' => 'Florence',
          'I17' => 'Augusta',
          'I7' => 'Cripple Creek',
          'I9' => 'Victor',
          'K1' => 'Denver',
          'K3' => 'Castle Rock',
          'K7' => 'Colorado Springs',
          'L12' => 'Eden',
          'L14' => 'Pueblo',
          'L8' => 'Fountain',
          'M3' => 'Petyon',
          'O17' => 'La Junta',
          'O3' => 'Kit Carson',
        }.freeze

        HEXES = {
          white: {
            # blank
            %w[N2 G3 B4 F4 L4 N4 C5 G5 M5 H6 N6 C7 G7 M7 F8 E9 K9 M9 H10 L10 K11
               M11 J12 N12 G13 K13 M13 N14 G15 I15 H16 J16 L16 E17 K17 H18 G19] => '',
            # mines only
            %w[E7 H8 F18] => 'icon=image:18_royal_gorge/mine,name:mine;',
            # mountains
            %w[I11 J10 L6] => 'upgrade=cost:10,terrain:mountain;',
            %w[J8] => 'upgrade=cost:10,terrain:mountain;icon=image:18_royal_gorge/mine,name:mine;',
            %w[C9 D16 E5 I5 J4 J6 K5] => 'upgrade=cost:20,terrain:mountain;',
            %w[B10 D4 D6 D8 D18] => 'upgrade=cost:30,terrain:mountain;icon=image:18_royal_gorge/mine,name:mine;',
            # water
            %w[K15 M15] => 'upgrade=cost:20,terrain:water;icon=image:18_royal_gorge/mine,name:mine',
            %w[G11 J14 N16] => 'upgrade=cost:20,terrain:water;',
            # towns
            %w[B8 C3 G9 I17 K3 M3] => 'town=revenue:0;',
            %w[E19 F16] => 'town=revenue:0;upgrade=cost:10,terrain:mountain;',
            %w[H4 I9 F6 H14 L12] => 'town=revenue:0;icon=image:18_royal_gorge/mine,name:mine;',
            %w[E3] => 'town=revenue:0;label=R',
            # cities
            %w[G17 K7] => 'city=revenue:0',
            %w[B6] => 'city=revenue:0;icon=image:18_royal_gorge/mine,name:mine;'\
                      'icon=image:18_royal_gorge/mine,name:mine;upgrade=cost:20,terrain:water,loc:1.5;',
            %w[C11] => 'city=revenue:0;upgrade=cost:20,terrain:water;label=S',
            %w[I7] => 'city=revenue:0;icon=image:18_royal_gorge/mine,name:mine;'\
                      'icon=image:18_royal_gorge/mine,name:mine;',
            %w[H12 L14] => 'city=revenue:0;upgrade=cost:20,terrain:water;',
          },
          yellow: {
            # royal gorge
            ['D12'] => 'city=revenue:20;path=a:2,b:_0;border=edge:5',
            ['E13'] => 'border=edge:2;border=edge:4',
            ['F12'] => 'city=revenue:40;path=a:4,b:_0;border=edge:1',
          },
          gray: {
            # mountains around royal gorge
            %w[E11 E15] => 'border=edge:2;border=edge:4',
            %w[F10 F14] => 'border=edge:1',
            ['C13'] => 'border=edge:5',
            ['D10'] => 'border=edge:5',
            ['D14'] => 'border=edge:2;border=edge:5',
          },
          red: {
            # Leadville
            ['A3'] => 'offboard=groups:Leadville,revenue:yellow_30|green_50|brown_70|gray_90;'\
                      'path=a:5,b:_0;border=edge:4',
            ['B2'] => 'city=groups:Leadville,revenue:yellow_30|green_50|brown_70|gray_90,hide:1;'\
                      'path=a:0,b:_0;path=a:5,b:_0;border=edge:1',
            # Denver
            ['J2'] => 'city=groups:Denver,revenue:yellow_30|green_40|brown_60|gray_90,hide:1;'\
                      'path=a:0,b:_0;border=edge:4',
            ['K1'] => 'city=groups:Denver,revenue:yellow_30|green_40|brown_60|gray_90;path=a:0,b:_0;'\
                      'border=edge:1;border=edge:5',
            ['L2'] => 'city=groups:Denver,revenue:yellow_30|green_40|brown_60|gray_90,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;border=edge:2',
            # Kit Carson
            ['O3'] => 'offboard=groups:KitCarson,revenue:yellow_30|green_40|brown_60|gray_90;'\
                      'path=a:1,b:_0;border=edge:0;',
            ['O5'] => 'city=groups:KitCarson,revenue:yellow_30|green_40|brown_60|gray_90,hide:1;'\
                      'path=a:1,b:_0;border=edge:3;',
            # La Junta
            ['O15'] => 'city=groups:LaJunta,revenue:yellow_30|green_50|brown_70|gray_90,hide:1;'\
                       'path=a:1,b:_0;path=a:2,b:_0;border=edge:0;',
            ['O17'] => 'offboard=groups:LaJunta,revenue:yellow_30|green_50|brown_70|gray_90;'\
                       'path=a:2,b:_0;border=edge:3;',
            # Silverton
            ['C15'] => 'offboard=groups:Silverton,revenue:yellow_70|green_60|brown_50|gray_40;'\
                       'path=a:5,b:_0;border=edge:0;',
            ['C17'] => 'city=groups:Silverton,revenue:yellow_70|green_60|brown_50|gray_40,hide:1;'\
                       'path=a:4,b:_0;path=a:5,b:_0;border=edge:3;',
          },
        }.freeze

        HOME_TOWN_HEXES = {
          'FCC' => {
            city: {
              %w[I13] => 'city=revenue:0;upgrade=cost:20,terrain:water;',
            },
            town: {
              %w[I13] => 'town=revenue:0;upgrade=cost:20,terrain:water;',
            },
          },
          'NO' => {
            city: {
              %w[L8] => 'city=revenue:0;',
            },
            town: {
              %w[L8] => 'town=revenue:0;',
            },
          },
        }.freeze
      end
    end
  end
end
