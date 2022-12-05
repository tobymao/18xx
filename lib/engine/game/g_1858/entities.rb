# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Entities
        CORPORATIONS = [
          {
            sym: 'A',
            name: 'Andalucian Railway',
            color: '#3751dc',
            text_color: 'white',
            logo: '1858/A',
            simple_logo: '1858/A.alt',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'AVT',
            name: 'Almanza, Valencia and Tarragona Railway',
            color: '#18a6d8',
            text_color: 'white',
            logo: '1858/AVT',
            simple_logo: '1858/AVT.alt',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'MZA',
            name: 'Madrid, Zaragoza and Alicante Railway',
            logo: '1858/MZA',
            simple_logo: '1858/MZA.alt',
            color: '#fff114',
            text_color: 'black',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
            city: 2,
          },
          {
            sym: 'N',
            name: 'Northern Railway',
            logo: '1858/N',
            simple_logo: '1858/N.alt',
            color: '#000000',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'RP',
            name: 'Royal Portugese Railway',
            logo: '1858/RP',
            simple_logo: '1858/RP.alt',
            color: '#e51f2e',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'TBF',
            name: 'Tarragona, Barcelona and France Railway',
            logo: '1858/TBF',
            simple_logo: '1858/TBF.alt',
            color: '#59227f',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'W',
            name: 'Western Railway',
            logo: '1858/W',
            simple_logo: '1858/W.alt',
            color: '#109538',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
          {
            sym: 'ZPB',
            name: 'Zaragoza, Pamplona and Barcelona Railway',
            logo: '1858/ZPB',
            simple_logo: '1858/ZPB.alt',
            color: '#ff7700',
            text_color: 'white',
            float_percent: 40,
            type: 'medium',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 20, 20],
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'H&G',
            name: 'Havana and Güines Railway',
            desc: 'P1. Revenue 30. ' \
                  'Cannot be used to start a major company or exchanged for a share.',
            value: 30,
            discount: 0,
            revenue: 10,
            color: :yellow,
            text_color: :black,
            logo: '1858/HG',
            coordinates: [],
            abilities: [
              {
                type: 'no_buy',
              },
            ],
          },
          {
            sym: 'B&M',
            name: 'Barcelona and Mataró Railway',
            desc: 'P2. Revenue 23/35. Home hex is O8. ' \
                  'Can be used to start a public company in Barcelona.',
            value: 115,
            discount: 25,
            revenue: 23,
            color: :yellow,
            text_color: :black,
            logo: '1858/BM',
            coordinates: %w[O8],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 35,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'O8',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[O8],
              },
            ],
          },
          {
            sym: 'M&A',
            name: 'Madrid and Aranjuez Railway',
            desc: 'P3. Revenue 25/38. Home hexes are H9 and H11. ' \
                  'Can be used to start a public company in Madrid.',
            value: 125,
            discount: 25,
            revenue: 25,
            color: :yellow,
            text_color: :black,
            logo: '1858/MA',
            coordinates: %w[H11 H13],
            city: 2,
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 38,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'H11',
                city: 2,
              },
            ],
          },
          {
            sym: 'P&L',
            name: 'Porto and Lisbon Railway',
            desc: 'P4. Revenue 22/33. Home hexes are B9 and B11. ' \
                  'Can be used to start a public company in Porto.',
            value: 110,
            discount: 20,
            revenue: 22,
            color: :yellow,
            text_color: :black,
            logo: '1858/PL',
            coordinates: %w[B9 B11],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 33,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'B9',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[B9 B11],
              },
              {
                type: 'stubs',
                hex_edges: { B9: 0, B11: 3 },
              },
            ],
          },
          {
            sym: 'V&J',
            name: 'Valencia and Jativa Railway',
            desc: 'P5. Revenue 20/30. Home hex is L11. ' \
                  'Can be used to start a public company in Valencia.',
            value: 100,
            discount: 20,
            revenue: 20,
            color: :yellow,
            text_color: :black,
            logo: '1858/VJ',
            coordinates: %w[L13],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 30,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'L13',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[L13],
              },
            ],
          },
          {
            sym: 'R&T',
            name: 'Reus and Tarragona Railway',
            desc: 'P6. Revenue 12/18. Home hex is N9. ' \
                  'Cannot be used to start a public company.',
            value: 60,
            discount: 10,
            revenue: 12,
            color: :yellow,
            text_color: :black,
            logo: '1858/RT',
            coordinates: %w[N9],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 18,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[N9],
              },
            ],
          },
          {
            sym: 'L&C',
            name: 'Lisbon and Carregado Railway',
            desc: 'P7. Revenue 18/27. Home hexes are A14 and B13. ' \
                  'Can be used to start a public company in Lisboa.',
            value: 90,
            discount: 20,
            revenue: 18,
            color: :yellow,
            text_color: :black,
            logo: '1858/LC',
            coordinates: %w[A14 B13],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 27,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'A14',
                slot: 0,
              },
              {
                type: 'blocks_hexes',
                hexes: %w[B13],
              },
              {
                type: 'stubs',
                hex_edges: { B13: 1 },
              },
            ],
          },
          {
            sym: 'M&V',
            name: 'Madrid and Valladolid Railway',
            desc: 'P8. Revenue 24/36. Home hexes are G8, G10 and H11. ' \
                  'Can be used to start a public company in either Madrid or Valladolid.',
            value: 120,
            discount: 25,
            revenue: 24,
            color: :yellow,
            text_color: :black,
            logo: '1858/MV',
            coordinates: %w[G8 H11 G10],
            city: [0, 1],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 36,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'G8',
              },
              {
                type: 'reservation',
                hex: 'H11',
                city: 1,
              },
              {
                type: 'blocks_hexes',
                hexes: %w[G8 G10],
              },
              {
                type: 'stubs',
                hex_edges: { G8: 0, G10: [3, 5] },
              },
            ],
          },
          {
            sym: 'M&Z',
            name: 'Madrid and Zaragoza Railway',
            desc: 'P9. Revenue 19/29. Home hexes are I10, J9, K8 and L7. ' \
                  'Can be used to start a public company in Zaragoza.',
            value: 95,
            discount: 20,
            revenue: 19,
            color: :yellow,
            text_color: :black,
            logo: '1858/MZ',
            coordinates: %w[I10 J9 K8 L7],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 29,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'L7',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[I10 J9 K8],
              },
              {
                type: 'stubs',
                hex_edges: { I10: 4, J9: [1, 4], K8: [1, 4] },
              },
            ],
          },
          {
            sym: 'C&S',
            name: 'Córdoba and Seville Railway',
            desc: 'P10. Revenue 21/32. Home hexes are E18, F17 and G18. ' \
                  'Can be used to start a public company in either Sevilla or Córdoba.',
            value: 105,
            discount: 20,
            revenue: 21,
            color: :yellow,
            text_color: :black,
            logo: '1858/CS',
            coordinates: %w[E18 F17 G18],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 32,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'E18',
              },
              {
                type: 'reservation',
                hex: 'G18',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[E18 F17 G18],
              },
              {
                type: 'stubs',
                hex_edges: { E18: 4, F17: [1, 5], G18: 2 },
              },
            ],
          },
          {
            sym: 'SJ&C',
            name: 'Seville, Jerez and Cadiz Railway',
            desc: 'P11. Revenue 14/21. Home hexes are E18 and E20. ' \
                  'Can be used to start a public company in either Sevilla or Cádiz.',
            value: 70,
            discount: 15,
            revenue: 14,
            color: :yellow,
            text_color: :black,
            logo: '1858/SJC',
            coordinates: %w[E18 E20],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 21,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'E18',
              },
              {
                type: 'reservation',
                hex: 'E20',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[E18 E20],
              },
              {
                type: 'stubs',
                hex_edges: { E18: 0, E20: 3 },
              },
            ],
          },
          {
            sym: 'Z&P',
            name: 'Zaragoza and Pamplona Railway',
            desc: 'P12. Revenue 16/24. Home hexes are K4, K6 and L7. ' \
                  'Can be used to start a public company in Zaragoza.',
            value: 80,
            discount: 15,
            revenue: 16,
            color: :yellow,
            text_color: :black,
            logo: '1858/ZP',
            coordinates: %w[K4 K6 L7],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 24,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'L7',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[K4 K6],
              },
              {
                type: 'stubs',
                hex_edges: { K4: 0, K6: [3, 5] },
              },
            ],
          },
          {
            sym: 'C&B',
            name: 'Castejón and Bilbao Railway',
            desc: 'P13. Revenue 15/23. Home hex is I2. ' \
                  'Can be used to start a public company in Bilbao.',
            value: 75,
            discount: 15,
            revenue: 15,
            color: :yellow,
            text_color: :black,
            logo: '1858/CB',
            coordinates: %w[I2],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 23,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'I2',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[I2],
              },
            ],
          },
          {
            sym: 'C&M',
            name: 'Córdoba and Málaga Railway',
            desc: 'P14. Revenue 17/26. Home hexes are G18 and G20. ' \
                  'Can be used to start a public company in either Córdoba or Málaga.',
            value: 85,
            discount: 15,
            revenue: 17,
            color: :yellow,
            text_color: :black,
            logo: '1858/CM',
            coordinates: %w[G18 G20],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 26,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'G18',
              },
              {
                type: 'reservation',
                hex: 'G20',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[G18 G20],
              },
              {
                type: 'stubs',
                hex_edges: { G18: 0, G20: 3 },
              },
            ],
          },
          {
            sym: 'M&C',
            name: 'Murcia and Cartagena Railway',
            desc: 'P15. Revenue 14/21. Home hex is K18. ' \
                  'Cannot be used to start a public company.',
            value: 70,
            discount: 15,
            revenue: 14,
            color: :yellow,
            text_color: :black,
            logo: '1858/MC',
            coordinates: %w[K18],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 21,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'K18',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[K18],
              },
              {
                type: 'stubs',
                hex_edges: { K18: 5 },
              },
            ],
          },
          {
            sym: 'A&S',
            name: 'Alar and Santander Railway',
            desc: 'P16. Revenue 16/24. Home hexes are G4 and H3. ' \
                  'Can be used to start a public company in Santander.',
            value: 80,
            discount: 15,
            revenue: 16,
            color: :yellow,
            text_color: :black,
            logo: '1858/AS',
            coordinates: %w[G4 H3],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 24,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'H3',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[G4 H3],
              },
              {
                type: 'stubs',
                hex_edges: { G4: 4, H3: 1 },
              },
            ],
          },
          {
            sym: 'B&CR',
            name: 'Badajoz and Ciudad Real Railway',
            desc: 'P17. Revenue 13/20. Home hexes are D15, E14 and F15. ' \
                  'Cannot be used to start a public company.',
            value: 65,
            discount: 15,
            revenue: 13,
            color: :yellow,
            text_color: :black,
            logo: '1858/BCR',
            coordinates: %w[D15 E14 F15],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'revenue_change',
                revenue: 20,
                on_phase: '3',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[D15 E14 F15],
              },
              {
                type: 'stubs',
                hex_edges: { D15: 4, E14: [1, 5], F15: 2 },
              },
            ],
          },
          {
            sym: 'S&C',
            name: 'Santiago and La Coruña Railway',
            desc: 'P18. Revenue 30. Home hexes are C2 and C4. ' \
                  'Can be used to start a public company in La Coruña.',
            value: 100,
            discount: 0,
            revenue: 30,
            color: :green,
            text_color: :black,
            logo: '1858/SC',
            coordinates: %w[C2 C4],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'C2',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[C2 C4],
              },
              {
                type: 'stubs',
                hex_edges: { C2: 0, C4: 3 },
              },
            ],
          },
          {
            sym: 'M&S',
            name: 'Medina and Salamanca Railway',
            desc: 'P19. Revenue 27. Home hex is F9. ' \
                  'Cannot be used to start a public company.',
            value: 90,
            discount: 0,
            revenue: 27,
            color: :green,
            text_color: :black,
            logo: '1858/MS',
            coordinates: %w[F9],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[F9],
              },
            ],
          },
          {
            sym: 'C&MP',
            name: 'Cáceres, Madrid and Portugal Railway',
            desc: 'P20. Revenue 40. Home hexes are D13, E12, F13, G12 and H11. ' \
                  'Can be used to start a public company in Madrid.',
            value: 135,
            discount: -30,
            revenue: 40,
            color: :green,
            text_color: :black,
            logo: '1858/CMP',
            coordinates: %w[H11 D13 E12 F13 G12],
            city: 0,
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'H11',
                city: 0,
              },
              {
                type: 'blocks_hexes',
                hexes: %w[D13 E12 F13 G12],
              },
              {
                type: 'stubs',
                hex_edges: { D13: 4, E12: [1, 5], F13: [2, 4], G12: [1, 4] },
              },
            ],
          },
          {
            sym: 'O&V',
            name: 'Orense and Vigo Railway',
            desc: 'P21. Revenue 33. Home hexes are B5 and C4. ' \
                  'Can be used to start a public company in Vigo.',
            value: 110,
            discount: 0,
            revenue: 33,
            color: :green,
            text_color: :black,
            logo: '1858/OV',
            coordinates: %w[B5 C4],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'B5',
              },
              {
                type: 'blocks_hexes',
                hexes: %w[B5 C4],
              },
              {
                type: 'stubs',
                hex_edges: { B5: 4, C4: 1 },
              },
            ],
          },
          {
            sym: 'L&G',
            name: 'León and Gijón Railway',
            desc: 'P22. Revenue 36. Home hexes are F1, F3 and F5. ' \
                  'Can be used to start a public company in Gijón.',
            value: 120,
            discount: 0,
            revenue: 36,
            color: :green,
            text_color: :black,
            logo: '1858/LG',
            coordinates: %w[F1 F3 F5],
            abilities: [
              {
                type: 'no_buy',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'ipoed',
                from: 'ipo',
              },
              {
                type: 'exchange',
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                corporations: 'any',
                from: 'presidency',
              },
              {
                type: 'reservation',
                hex: 'F1',
                slot: 0,
              },
              {
                type: 'blocks_hexes',
                hexes: %w[F3 F5],
              },
              {
                type: 'stubs',
                hex_edges: { F3: [0, 3], F5: 3 },
              },
            ],
          },
        ].freeze

        QUICK_START_PACKETS_A = {
          3 => [
            { companies: ['M&A', 'V&J', 'M&C', 'B&M', 'R&T', 'H&G'], cost: 500 },
            { companies: ['M&V', 'A&S', 'C&B', 'P&L', 'L&C'], cost: 475 },
            { companies: ['C&S', 'C&M', 'SJ&C', 'B&CR', 'M&Z', 'Z&P'], cost: 500 },
          ],
          4 => [
            { companies: ['M&A', 'V&J', 'M&C', 'B&CR'], cost: 360 },
            { companies: ['B&M', 'R&T', 'M&Z', 'Z&P'], cost: 350 },
            { companies: ['M&V', 'A&S', 'C&B', 'L&C'], cost: 365 },
            { companies: ['C&S', 'C&M', 'SJ&C', 'P&L'], cost: 370 },
          ],
          5 => [
            { companies: ['M&A', 'V&J', 'M&C'], cost: 295 },
            { companies: ['B&M', 'R&T', 'M&Z'], cost: 270 },
            { companies: ['M&V', 'A&S', 'C&B'], cost: 275 },
            { companies: ['C&S', 'C&M', 'SJ&C'], cost: 260 },
            { companies: ['P&L', 'L&C', 'B&CR', 'H&G'], cost: 295 },
          ],
          6 => [
            { companies: ['M&A', 'M&Z'], cost: 220 },
            { companies: ['B&M', 'R&T', 'C&B'], cost: 250 },
            { companies: ['M&V', 'A&S'], cost: 200 },
            { companies: ['C&S', 'B&CR', 'SJ&C'], cost: 240 },
            { companies: ['P&L', 'L&C', 'H&G'], cost: 230 },
            { companies: ['V&J', 'M&C', 'Z&P'], cost: 250 },
          ],
        }.freeze

        QUICK_START_PACKETS_B = QUICK_START_PACKETS_A.merge({
          4 => [
            { companies: ['M&A', 'V&J', 'M&C', 'B&CR'], cost: 360 },
            { companies: ['B&M', 'R&T', 'P&L', 'L&C'], cost: 375 },
            { companies: ['M&V', 'A&S', 'C&B', 'Z&P'], cost: 355 },
            { companies: ['C&S', 'C&M', 'SJ&C', 'M&Z'], cost: 355 },
          ],
        }.freeze)

        def quick_start
          packets = option_quick_start_packets[@players.size].sort_by { rand }
          @players.zip(packets).each do |player, packet|
            cost = packet[:cost]
            player.spend(cost, @bank)
            companies = packet[:companies]
            companies.each do |sym|
              company = @companies.find { |c| c.sym == sym }
              purchase_company(player, company, 0)
            end
            @log << "#{player.name} spends #{format_currency(cost)} and " \
                    "buys private companies #{companies.join(', ')}"
          end
        end
      end
    end
  end
end
