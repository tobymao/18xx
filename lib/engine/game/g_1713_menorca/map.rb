# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Map
        LOCATION_NAMES = {
          'C8' => 'Ciutadella',
          'H5' => 'Fornells',
          'G8' => 'Es Mercadal',
          'J11' => 'Maó / Es Castell',
          'J13' => 'Sant Lluís',
          'H9' => 'Alaior',
          'E8' => 'Ferreries',
          'F9' => 'Es Migjorn Gran',
          'I6' => "Port d'Addaia",
          'C6' => 'Punta Nati',
          'C10' => "Torre d'Artrutx",
          'G4' => 'Torre de Cavalleria',
          'J7' => 'Cap de Favàritx',
          'J15' => "Illa de l'Aire",
          'J9' => "S'Albufera d'es Grau",
          'B3' => 'Barcelona',
          'A12' => 'Mallorca',
          'J3' => 'Marsella',
          'K4' => 'Génova',
          'K16' => 'Valencia',
          'F15' => 'Alger',
        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          yellow: {
            # Initial cities and towns with pre-printed track
            ['C8'] => 'city=revenue:20;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;icon=image:port', # Ciutadella
            ['H5'] => 'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;icon=image:port', # Fornells
            ['G8'] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0', # Es Mercadal
            ['J11'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;icon=image:port', # Maó / Es Castell
            ['J13'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0', # Sant Lluís
          },
          white: {
            # Lighthouses and watchtowers (landmarks, represented as towns)
            ['C6'] => 'town=revenue:0;upgrade=cost:60,terrain:water', # Punta Nati
            ['C10'] => 'town=revenue:0;upgrade=cost:60,terrain:water', # Torre d'Artrutx
            ['G4'] => 'town=revenue:0;upgrade=cost:80,terrain:water',   # Torre de Cavalleria
            ['J7'] => 'town=revenue:0;upgrade=cost:60,terrain:water',   # Cap de Favàritx
            ['J15'] => 'town=revenue:0;upgrade=cost:60,terrain:water', # Illa de l'Aire
            # Open sea (buildable, blue impassable would block track connections)
            %w[B5 B7 B9 B11
               C4 C12
               D5 D11 D13
               E4 E12
               F3 F11
               G2 G12
               H3 H13
               I14
               K6 K8 K10 K12 K14] =>
              '',
            # Maritime entries towards Alger and Marsella
            %w[E14 F13 G14 I4 J5] => 'upgrade=cost:80,terrain:water',
            # Special interior path (cost 60)
            %w[D7 F7] => 'upgrade=cost:60,terrain:hill;path=track:future,a:1,b:5',
            ['I10'] => 'upgrade=cost:60,terrain:hill;path=track:future,a:2,b:5',
            # Rough terrain (cost 30 to cross)
            %w[E6 E10 F5 D9 G6 G10 H7 H11 I8 I12] => 'upgrade=cost:30,terrain:mountain',
            # S'Albufera d'es Grau (wetland, cost 80)
            ['J9'] => 'upgrade=cost:80,terrain:swamp',
            # Towns
            ['H9'] => 'town=revenue:0;upgrade=cost:60,terrain:hill;path=track:future,a:2,b:5',   # Alaior
            ['E8'] => 'town=revenue:0;upgrade=cost:60,terrain:hill;path=track:future,a:2,b:4',   # Ferreries
            ['F9'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain', # Es Migjorn Gran
            ['I6'] => 'town=revenue:0', # Port d'Addaia
          },
          red: {
            # Off-map destinations (values and orientation as per JSON)
            ['B3'] => 'offboard=revenue:yellow_15|green_30|brown_45|gray_60;path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual', # Barcelona (1,6)
            ['A12'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_50;path=a:4,b:_0,track:dual', # Mallorca (5)
            ['J3'] => 'offboard=revenue:yellow_0|green_30|brown_50|gray_80;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual', # Marsella (1,2)
            ['K4'] => 'offboard=revenue:yellow_0|green_0|brown_40|gray_80;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual', # Génova (1,2)
            ['K16'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_45;path=a:3,b:_0,track:dual', # Valencia (4)
            ['F15'] => 'offboard=revenue:yellow_0|green_0|brown_0|gray_100;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual', # Alger (3,4,5)
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat
      end
    end
  end
end
