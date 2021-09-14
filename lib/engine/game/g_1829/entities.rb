# frozen_string_literal: true

module Engine
  module Game
    module G1829
      module Entities
        UNIT1_COMPANIES = [
          {
            name: 'Swansea & Mumbles',
            sym: 'SM',
            value: 30,
            revenue: 5,
            desc: 'No special abilities.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J3'] }],
          },
          {
            name: 'Cromford & High Peak',
            sym: 'CH',
            value: 75,
            revenue: 10,
            desc: 'No special abilities. Blocks D11, while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D11'] }],
          },
          {
            name: 'Canterbury & Whitstable',
            sym: 'CW',
            value: 130,
            revenue: 15,
            desc: 'No special abilities. Blocks K22, while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K22'] }],
          },
          {
            name: 'Liverpool & Manchester',
            sym: 'LM',
            value: 210,
            revenue: 20,
            desc: 'No special abilities. Blocks Liverpool (C6,C8), while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[C6 C8] }],
          },
          {
            name: 'Hull',
            sym: 'HU',
            type: 'steam',
            value: 315,
            revenue: 25,
            desc: 'Steam. pays 40$ to company with token in B17',
          },
          {
            name: 'Preston',
            sym: 'PR',
            value: 435,
            revenue: 30,
            type: 'steam',
            desc: 'Steam. pays 40$ to company with token in B7',
          },
          {
            name: 'Holyhead',
            sym: 'HO',
            value: 570,
            type: 'steam',
            revenue: 35,
            desc: 'Steam. pays 40$ to company with token in D1',
          },
          {
            name: 'Harwich',
            sym: 'HA',
            type: 'steam',
            value: 720,
            revenue: 40,
            desc: 'Steam. pays 40$ to company with token in I22',
          },
          {
            name: 'Dover',
            sym: 'DO',
            value: 900,
            revenue: 45,
            type: 'steam',
            desc: 'Steam. pays 40$ to company with token in K22',
          },
        ].freeze

        UNIT2_COMPANIES = [].freeze

        UNIT3_COMPANIES = [].freeze

        UNIT1_CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'LNWR',
            name: 'London & North Western',
            logo: '1822/LNWR',
            simple_logo: '1829/LNWR.alt',
            tokens: [0, 40, 100, 100, 100],
            max_ownership_percent: 100,
            coordinates: 'E8',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
            type: 'init1',
            color: 'black',
          },
          {
            float_percent: 60,
            sym: 'GWR',
            name: 'Great Western',
            logo: '1822/GWR',
            simple_logo: '1829/GWR.alt',
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'J11',
            min_price: 90,
            type: 'init2',
            color: 'darkgreen',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'Mid',
            name: 'Midland',
            logo: '1822/MR',
            simple_logo: '1829/MR.alt',
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'E12',
            min_price: 82,
            color: 'red',
            type: 'init3',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'LSWR',
            name: 'London & South Western',
            logo: '1829/lswr',
            simple_logo: '1829/LSWR.alt',
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'J17',
            city: 0,
            type: 'init4',
            color: 'lightgreen',
            text_color: 'black',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'GNR',
            name: 'Great Northern',
            logo: '1829/gnr',
            simple_logo: '1829/GNR.alt',
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'C14',
            color: 'blue',
            type: 'init5',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'LBSC',
            name: 'London Brighton & South Coast',
            logo: '1822/LBSCR',
            max_ownership_percent: 100,
            simple_logo: '1829/LBSC.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'L17',
            color: 'sandybrown',
            text_color: 'black',
            type: 'init6',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'GER',
            name: 'Great Eastern',
            logo: '1829/ger',
            max_ownership_percent: 100,
            simple_logo: '1829/GER.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'J17',
            city: 2,
            type: 'init7',
            color: 'darkblue',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'GCR',
            name: 'Great Central',
            max_ownership_percent: 100,
            logo: '1829/gcr',
            simple_logo: '1829/GCR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'C12',
            type: 'init8',
            color: 'lightskyblue',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s 55a],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'LYR',
            name: 'Lancashire & Yorkshire',
            logo: '1829/lyr',
            max_ownership_percent: 100,
            simple_logo: '1822/LYR.alt',
            tokens: [0, 40, 100],
            coordinates: 'C8',
            city: 1,
            type: 'init9',
            color: 'peru',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'SECR',
            name: 'South Eastern & Chatham',
            max_ownership_percent: 100,
            logo: '1829/secr',
            simple_logo: '1822/SECR.alt',
            tokens: [0, 40, 100],
            coordinates: 'L21',
            type: 'init10',
            color: 'yellow',
            text_color: 'black',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: %w[B7 B9 B11 B13 B15 C6 C8 C10 C12 C16 D3 D7 D9 D11 D13 D15 D17 E2 E4 E6 E8 E10 E12 E14 E16 F3 F5 F7 F9 F11
                          F13 F15 F17 F19 F21 G4 G6 G8 G10 G12 G14 G16 G18 G20 G22 H1 H3 H5 H7 H9 H11 H13 H15 H17 H19 H21 I2 I4
                          I6 I8 I10 I12 I14 I16 I18 I20 J5 J7 J9 J13 J15 J17 K8 K10 K12 K14 K16 K18 K20 K22 L1 L3 L5 L7 L9 L11
                          L13 L15 L17 L19 M2 M4 M6 M8],
                tiles: %w[1a 2a 3a 4a 5 6 7 8 9 10 11s 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33s 34 35
                          36 37 38 39 40 41 42 43 44 45 46 47 48 49 50s 51 60 59s],
              },
            ],
          },
        ].freeze

        PAR_BY_CORPORATION = {
          'LNWR' => 100,
          'GWR' => 90,
          'Mid' => 82,
          'LSWR' => 76,
          'GNR' => 71,
          'LBSC' => 67,
          'GER' => 64,
          'GCR' => 61,
          'LYR' => 58,
          'SECR' => 56,
        }.freeze

        REQUIRED_TRAIN = {
        }.freeze

        # combining is based on http://fwtwr.com/fwtwr/18xx/1829/privates.asp
        def game_companies
          comps = []
          comps.concat(UNIT1_COMPANIES) if @units[1]
          comps
        end

        def game_corporations
          corps = []
          corps.concat(UNIT1_CORPORATIONS) if @units[1]
          corps
        end
      end
    end
  end
end
