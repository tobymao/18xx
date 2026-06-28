# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Map
        WATER_HEXES = %w[
          B5 B7 B9 B11
          C4 C12
          D5 D11 D13
          E4 E12 E14
          F3 F11 F13
          G2 G12 G14
          H3 H13
          I4 I14
          J5
          K6 K8 K10 K12 K14
        ].freeze

        LIGHTHOUSE_HEXES = %w[C6 C10 G4 J7 J15].freeze
        KANE_HEXES = %w[D7 E8 F7 H9 I10].freeze
        KANE_ENDPOINT_HEXES = %w[C8 J11].freeze
        KANE_BONUS = 50
        GSC_TARGET_OFFBOARD_HEXES = %w[B3 A12 J3].freeze
        ALBUFERA_HEX = 'J9'
        ILLA_AIRE_HEX = 'J15'

        FIXED_TILES_BY_HEX = {
          'C8' => %w[CI2 CI3 CI4],
          'J11' => %w[MO2 MO3 MO4],
          'G8' => %w[ME2 ME3 ME4],
          'H5' => %w[FE2 FE3 FE4],
          'E8' => %w[F1 F2 F3 F4],
          'F9' => %w[MG1 MG2 MG3 MG4],
          'H9' => %w[AL1 AL2 AL3 AL4],
          'I6' => %w[PA1 PA2],
          'J13' => %w[SL2 SL3 SL4],
          'C6' => %w[PN1 PN2 PN3 PN4],
          'C10' => %w[TA1 TA2 TA3 TA4],
          'G4' => %w[TC1 TC2 TC3 TC4],
          'J7' => %w[CF1 CF2 CF3 CF4],
          'J15' => %w[IA1 IA2 IA3 IA4],
        }.freeze

        NON_ROTATABLE_TILE_PREFIXES = FIXED_TILES_BY_HEX.values.flatten.map { |name| name[/\A[A-Z]+/] }.uniq.freeze

        LOCATION_NAMES = {
          'C8'  => 'Ciutadella',
          'H5'  => 'Fornells',
          'G8'  => 'Es Mercadal',
          'J11' => 'Maó / Es Castell',
          'J13' => 'Sant Lluís',
          'H9'  => 'Alaior',
          'E8'  => 'Ferreries',
          'F9'  => 'Es Migjorn Gran',
          'I6'  => "Port d'Addaia",
          'C6'  => 'Punta Nati',
          'C10' => "Torre d'Artrutx",
          'G4'  => 'Torre de Cavalleria',
          'J7'  => "Cap de Favàritx",
          'J15' => "Illa de l'Aire",
          'J9'  => "S'Albufera d'es Grau",
          'B3'  => 'Barcelona',
          'A12' => 'Mallorca',
          'J3'  => 'Marsella',
          'K4'  => 'Génova',
          'K16' => 'Valencia',
          'F15' => 'Alger',
        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          yellow: {
            # Ciutats i pobles inicials amb via preimpresa
            ['C8'] => 'city=revenue:20;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;icon=image:port', # Ciutadella
            ['H5'] => 'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;icon=image:port', # Fornells
            ['G8'] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0', # Es Mercadal
            ['J11'] => 'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0,track:narrow;path=a:5,b:_0,track:narrow;icon=image:port', # Maó / Es Castell
            ['J13'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0', # Sant Lluís
          },
          blue: {
            # Mar obert blau (editable: permet col·locar losetes a sobre)
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
            # Entrades marítimes cap a Alger i Marsella
            %w[E14 F13 G14 I4 J5] => 'upgrade=cost:40,terrain:water',
          },
          orange: {
            # Fars i torres de guaita (fites, representades com a pobles)
            ['C6']  => 'town=revenue:0;upgrade=cost:20,terrain:water',   # Punta Nati
            ['C10'] => 'town=revenue:0;upgrade=cost:20,terrain:water',   # Torre d'Artrutx
            ['G4']  => 'town=revenue:0;upgrade=cost:20,terrain:water',   # Torre de Cavalleria
            ['J7']  => 'town=revenue:0;upgrade=cost:20,terrain:water',   # Cap de Favàritx
            ['J15'] => 'town=revenue:0;upgrade=cost:20,terrain:water',   # Illa de l'Aire
          },
          white: {
            # Camí especial interior (cost 60)
            %w[D7 F7] => 'upgrade=cost:60,terrain:hill;path=track:future,a:1,b:5',
            ['I10'] => 'upgrade=cost:60,terrain:hill;path=track:future,a:2,b:5',
            # Terreny accidentat (cost 15 per travessar)
            %w[E6 E10 F5 D9 G6 G10 H7 H11 I8 I12] => 'upgrade=cost:15,terrain:mountain',
            # S'Albufera d'es Grau (aiguamoll, cost 80)
            ['J9'] => 'upgrade=cost:80,terrain:swamp',
            # Pobles
            ['H9']  => 'town=revenue:0;upgrade=cost:60,terrain:hill;path=track:future,a:2,b:5',   # Alaior
            ['E8']  => 'town=revenue:0;upgrade=cost:60,terrain:hill;path=track:future,a:2,b:4',   # Ferreries
            ['F9']  => 'town=revenue:0;upgrade=cost:30,terrain:mountain', # Es Migjorn Gran
            ['I6']  => 'town=revenue:0',   # Port d'Addaia
          },
          red: {
            # Destinacions fora del mapa (valors i orientació segons JSON)
            ['B3']  => 'offboard=revenue:yellow_30|green_45|brown_60|gray_70;path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual', # Barcelona (1,6)
            ['A12'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:4,b:_0,track:dual',               # Mallorca (5)
            ['J3']  => 'offboard=revenue:yellow_0|green_45|brown_60|gray_80;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual',           # Marsella (1,2)
            ['K4']  => 'offboard=revenue:yellow_0|green_0|brown_60|gray_80;path=a:0,b:_0,track:dual;path=a:1,b:_0,track:dual',                    # Génova (1,2)
            ['K16'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:3,b:_0,track:dual',               # Valencia (4)
            ['F15'] => 'offboard=revenue:yellow_0|green_0|brown_0|gray_80;path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual',               # Alger (3,4,5)
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat
      end
    end
  end
end
