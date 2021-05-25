# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Entities
        COMPANIES = [
            {
              name: 'Nürnberg-Fürth',
              sym: 'NF',
              value: 100,
              revenue: 5,
              desc: 'Nürnberg-Fürth Bahn, Director of AG may lay token on L14 north or south, 10% Bayern',
              abilities: [{ type: 'shares', shares: 'BY_2' }, { type: 'no_buy' }],
              color: nil,
            },
            {
              sym: 'P1',
              name: 'M1 Bergisch Märkische Bahn',
              value: 80,
              revenue: 0,
              abilities: [
                 {
                   type: 'exchange',
                   minors: %w[M1],
                   owner_type: 'player',
                   when: ['Phase 1.1'],
                   from: 'ipo',
                 },
                 { type: 'no_buy' },
               ],
              desc: 'Buyer take control of pre-staatsbahn V1, which will be exchanged for the 5% certificate '\
                 'of Pru when V2 declares Pru starting or 5-Train is sold. Pre-Staatsbahnen starts in Köln (H2). '\
                 ' Cannot be sold.',
              color: nil,
            },
            {
              name: 'Leipzig-Dresdner Bahn',
              sym: 'LD',
              value: 190,
              revenue: 20,
              desc: 'Leipzig-Dresdner Bahn - Sachsen Direktor Papier',
              abilities: [{ type: 'shares', shares: %w[SX_0] },
                          { type: 'no_buy' },
                          { type: 'close', when: 'bought_train', corporation: 'SX' }],
              color: nil,
            },
            {
              sym: 'P2',
              name: 'M2 Berlin Potsdamer Bahn',
              value: 170,
              revenue: 0,
              desc: "Buyer take control of pre-staatsbahn M2, which will be exchanged for the Director's certificate "\
                'of SD when the first 4 train is sold and Pru is opened. P2 starts in Berlin (E19). '\
                'Cannot be sold.',
              color: nil,
            },
            {
              sym: 'P3',
              name: 'M3 Magdeburger-Bahn',
              value: 80,
              revenue: 0,
              desc: 'Buyer take control of pre-staatsbahn M3, which will be exchanged for a 5% share of Pru when the '\
                'first 4 train is sold and M2 declares Pru open. M3 starts in Innsbruck (F14). Cannot be sold.',
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
              color: nil,
            },
            {
              sym: 'P4',
              name: 'M4 Köln-Mindener Bahn',
              value: 160,
              revenue: 0,
              desc: 'Buyer take control of pre-staatsbahn M3, which will be exchanged for a 10% share of Pru when the '\
                'first 4 train is sold and M2 declares Pru open. M3 starts in Innsbruck (G5). Cannot be sold.',
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
              color: nil,
            },
            {
              name: 'Bayrische Eisenbahn Director Share',
              sym: 'BX',
              value: 184,
              tokens: [0, 40, 100],
              revenue: 0,
              desc: 'Bayrische Eisenbahn Director Share',
              abilities: [
                {
                  type: 'exchange',
                  corporations: %w[BY_0x],
                  owner_type: 'player',
                  when: ['Phase 1.1'],
                  from: 'ipo',
                },
              ],
              color: nil,
            },
            {
              name: 'Braunschweigische Bahn',
              sym: 'BB',
              value: 130,
              revenue: 25,
              desc: 'which will be exchanged for a 10% share of Pru when the '\
                'first 4 train is sold and M2 declares Pru open. Cannot be sold.',
              abilities: [
                {
                  type: 'exchange',
                  corporations: %w[PR_2],
                  owner_type: 'player',
                  when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                  from: 'ipo',
                },
              ],
              color: nil,
            },
            {
              name: 'Hannoversche Bahn',
              sym: 'HB',
              value: 160,
              revenue: 30,
              desc: 'Buyer take control of pre-staatsbahn M3, which will be exchanged for a 10% share of Pru when the '\
                'first 4 train is sold and M2 declares Pru open. M3 starts in Innsbruck (F14). Cannot be sold.',
              abilities: [
                {
                  type: 'exchange',
                  corporations: %w[PR_1],
                  owner_type: 'player',
                  when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                  # reserved papers perhaps a option
                  from: 'ipo',
                },
              ],
              color: nil,
            },
            {
              sym: 'P5',
              name: 'M5 Berlin Stettiner Bahn',
              value: 80,
              revenue: 0,
              desc: 'Buyer take control of pre-staatsbahn M5, which will be exchanged for a 5% share of Pru when the '\
                'first 4 train is sold and M2 declares Pru open. M5 starts in Innsbruck (E19). Cannot be sold.',
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
              color: nil,
            },
            {
              sym: 'P6',
              name: 'M6 Altona Kiel Bahn',
              value: 80,
              revenue: 0,
              desc: 'Buyer take control of pre-staatsbahn M3, which will be exchanged for a 5% share of Pru when the '\
                'first 4 train is sold and M2 declares Pru open. M3 starts in Innsbruck (C11). Cannot be sold.',
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
              color: nil,
            },
            {
              name: 'Ostbayrische Bahn',
              sym: 'OBB',
              value: 120,
              revenue: 10,
              desc: 'Ostbayrische Bahn - 2 Tiles on M15, M17 extra (one per OR) and without cost',
              abilities: [
                  {
                    type: 'tile_lay',
                    description: "Place a free track tile at m15, M17 at any time during the corporation's operations.",
                    owner_type: 'player',
                    hexes: %w[M15 M17],
                    tiles: %w[3 4 7 8 9 58],
                    free: true,
                    count: 1,
                  },
                  { type: 'shares', shares: 'BY_1' },
                ],
              color: nil,
            },
            {
              name: 'Pfalzbahnen',
              sym: 'PB',
              value: 150,
              revenue: 15,
              desc: 'Can lay a tile on L6 and Token on L6 if Baden AG is active already',
              abilities: [
                {
                  type: 'teleport',
                  owner_type: 'player',
                  free_tile_lay: true,
                  hexes: ['L6'],
                  tiles: %w[210 211 212 213 214 215],
                },
                { type: 'shares', shares: 'BY_3' },
              ],
              color: nil,
            },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BY',
            name: 'Bayrische Eisenbahn',
            logo: '1835/BY',
            simple_logo: '1835/BY.alt',
            max_ownership_percent: 100,
            tokens: [0, 0, 0, 0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            coordinates: 'O15',
            color: :Blue,
            reservation_color: nil,
          },
          {
            sym: 'SX',
            name: 'Sächsische Eisenbahn',
            logo: '1835/SX',
            max_ownership_percent: 100,
            simple_logo: '1835/SX.alt',
            tokens: [0, 0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            coordinates: 'H16',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            sym: 'BA',
            name: 'Badische Eisenbahn',
            logo: '1835/BA',
            simple_logo: '1835/BA.alt',
            tokens: [0, 0],
            max_ownership_percent: 100,
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            # last_cert = true,
            coordinates: 'L6',
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            sym: 'HE',
            name: 'Hessische Eisenbahn',
            logo: '1835/HE',
            simple_logo: '1835/HE.alt',
            tokens: [0, 0],
            max_ownership_percent: 100,
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            last_cert: %w[HE_7],
            # last_cert = true,
            coordinates: 'J8',
            color: :green,
            reservation_color: nil,
          },
          {
            sym: 'WT',
            name: 'Württembergische Eisenbahn',
            logo: '1835/WT',
            simple_logo: '1835/WT.alt',
            tokens: [0, 0],
            max_ownership_percent: 100,
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            last_cert: ['WT_7'],
            # last_cert = true,
            coordinates: 'M9',
            color: :yellow,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'MS',
            name: 'Eisenbahn Mecklenburg Schwerin',
            logo: '1835/MS',
            simple_logo: '1835/MS.alt',
            tokens: [0, 0],
            max_ownership_percent: 100,
            percent: 10,
            float_percent: 60,
            shares: [20, 10, 20, 20, 10, 10, 10],
            # the shares order creates a 10 share company, but the first 3 sold papers are 20%
            coordinates: 'C13',
            color: :violet,
            reservation_color: nil,
          },
          {
            sym: 'OL',
            name: 'Oldenburgische Eisenbahn',
            logo: '1835/OL',
            simple_logo: '1835/OL.alt',
            tokens: [0, 0],
            max_ownership_percent: 100,
            float_percent: 60,
            shares: [20, 10, 20, 20, 10, 10, 10],
            # the shares order creates a 10 share company, but the first 3 sold papers are 20%
            coordinates: 'D6',
            color: '#6e6966',
            reservation_color: nil,
          },

          {
            sym: 'PR',
            name: 'Preussische Eisenbahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0, 0, 0, 0, 0],
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 5, 5, 5, 5],
            # shares for minors and Privates should be reserved
            coordinates: 'E19',
            color: '#37383a',
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'M1',
            name: 'Bergisch Märkische Bahn',
            logo: '1822/1',
            type: 'PreStaatsbahn',
            tokens: [0],
            coordinates: 'H2',
            city: 0,
            color: '#37383a',
          },
          {
            sym: 'P2',
            name: 'Berlin Potsdamer Bahn',
            logo: '1822/2',
            simple_logo: '1835/P2.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_0x],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'E19',
            color: '#37383a',
          },
          {
            sym: 'P3',
            name: 'Magdeburger-Bahn',
            logo: '1822/3',
            simple_logo: '1835/P3.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_10],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'F14',
            color: '#37383a',
          },
          {
            sym: 'P4',
            name: 'Köln-Mindener Bahn',
            logo: '1822/4',
            simple_logo: '1835/P4.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_3],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'G5',
            color: '#37383a',
          },
          {
            sym: 'P5',
            name: 'Berlin Stettiner Bahn',
            logo: '1822/5',
            simple_logo: '1835/P5.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_11],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'E19',
            city: 1,
            color: '#37383a',
          },
          {
            sym: 'P6',
            name: 'Altona Kiel Bahn',
            logo: '1822/6',
            simple_logo: '1835/P6.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_12],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'C11',
            color: '#37383a',
          },
        ].freeze
      end
    end
  end
end
