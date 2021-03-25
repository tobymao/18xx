# frozen_string_literal: true

module Engine
  module Game
    module G18LosAngeles
      module Entities
        COMPANIES = [
          {
            name: 'Gardena Tramway',
            value: 140,
            treasury: 60,
            revenue: 0,
            desc: 'Starts with $60 in treasury, a 2 train, and a token in Gardena (D5). In ORs, '\
                  'this is the first minor to operate. May only lay or upgrade 1 tile per OR. '\
                  'Splits revenue evenly with owner. May be sold to a corporation for up to $140.',
            sym: 'GT',
            color: nil,
          },
          {
            name: 'Orange County Railroad',
            value: 100,
            treasury: 40,
            revenue: 0,
            desc: 'Starts with $40 in treasury, a 2 train, and a token in Cypress (E10). In ORs, '\
                  'this is the second minor to operate. May only lay or upgrade 1 tile per OR. '\
                  'Splits revenue evenly with owner. May be sold to a corporation for up to $100.',
            sym: 'OCR',
            color: nil,
          },
          {
            name: 'Pacific Maritime',
            value: 60,
            revenue: 10,
            desc: 'Reserves a token slot in Long Beach (E8), in the city next to Norwalk (D9). The '\
                  'owning corporation may place an extra token there at no cost, with no '\
                  'connection needed. Once this company is purchased by a corporation, the slot '\
                  'that was reserved may be used by other corporations.',
            sym: 'PMC',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                hexes: ['E8'],
                city: 2,
                price: 0,
                teleport_price: 0,
                count: 1,
                extra: true,
              },
              { type: 'reservation', remove: 'sold', hex: 'E8', city: 2 },
            ],
            color: nil,
          },
          {
            name: 'United States Mail Contract',
            value: 80,
            revenue: 0,
            desc: 'Adds $10 per location visited by any one train of the owning corporation. Never '\
                  'closes once purchased by a corporation.',
            sym: 'MAIL',
            abilities: [
              {
                type: 'close',
                on_phase: 'never',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Chino Hills Excavation',
            value: 60,
            revenue: 20,
            desc: 'Reduces, for the owning corporation, the cost of laying all hill tiles and '\
                  'tunnel/pass hexsides by $20.',
            sym: 'CHE',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Los Angeles Citrus',
            value: 60,
            revenue: 15,
            desc: 'The owning corporation may assign Los Angeles Citrus to either Riverside (C14) '\
                  'or Port of Long Beach (F7), to add $30 to all routes it runs to this location.',
            sym: 'LAC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C14 F7],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Los Angeles Steamship',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may assign the Los Angeles Steamship to one of Oxnard ('\
                  'B1), Santa Monica (C2), Port of Long Beach (F7), or Westminster (F9), to add $'\
                  '20 per port symbol to all routes it runs to this location.',
            sym: 'LAS',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[B1 C2 F7 F9],
                count_per_or: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'South Bay Line',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may make an extra $0 cost tile upgrade of either Redondo '\
                  'Beach (E4) or Torrance (E6), but not both.',
            sym: 'SBL',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                free: true,
                hexes: %w[E4 E6],
                tiles: %w[14 15 619],
                special: false,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Puente Trolley',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may lay an extra $0 cost yellow tile in Puente (C10), '\
                  'even if they are not connected to Puente.',
            sym: 'PT',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C10'] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['C10'],
                          tiles: %w[7 8 9],
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Beverly Hills Carriage',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may lay an extra $0 cost yellow tile in Beverly Hills ('\
                  'B3), even if they are not connected to Beverly Hills. Any terrain costs are '\
                  'ignored.',
            sym: 'BHC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B3'] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['B3'],
                          tiles: %w[7 8 9],
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Dewey, Cheatham, and Howe',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may place a token (from their charter, paying the normal '\
                  'cost) in a city they are connected to that does not have any open token slots. '\
                  'If a later tile placement adds a new slot, this token fills that slot. This '\
                  'ability may not be used in Long Beach (E8).',
            sym: 'DC&H',
            min_players: 3,
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                count: 1,
                extra: true,
                from_owner: true,
                cheater: 0,
                special_only: true,
                discount: 0,
                hexes: %w[A2 A4 A6 A8 B5 B7 B9 B11 B13 C2 C4 C6 C8 C12 D5 D7 D9
                          D11 D13 E4 E6 E10 E12 F7 F9 F11 F13],
              },
            ],
            color: nil,
          },
          {
            name: 'Los Angeles Title',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may place an Open City token in any unreserved slot '\
                  'except for Long Beach (E8). The owning corporation need not be connected to the '\
                  'city where the token is placed.',
            sym: 'LAT',
            min_players: 3,
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                price: 0,
                teleport_price: 0,
                count: 1,
                extra: true,
                special_only: true,
                neutral: true,
                hexes: %w[A4 A6 A8 B5 B7 B9 B11 B13 C4 C6 C8 C12 D5 D7 D9 D11
                          D13 E4 E6 E10 E12 F7 F9 F11 F13],
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'ELA',
            name: 'East Los Angeles & San Pedro Railroad',
            logo: '18_los_angeles/ELA',
            simple_logo: '18_los_angeles/ELA.alt',
            tokens: [0, 80, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$60 Culver City (C4) token',
                hexes: ['C4'],
                price: 40,
                teleport_price: 60,
              },
              { type: 'reservation', hex: 'C4', remove: 'IV' },
            ],
            coordinates: 'C12',
            color: '#ff0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'LA',
            name: 'Los Angeles Railway',
            logo: '18_los_angeles/LA',
            simple_logo: '18_los_angeles/LA.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 Alhambra (B9) token',
                hexes: ['B9'],
                count: 1,
                price: 40,
              },
              { type: 'reservation', hex: 'B9', remove: 'IV' },
            ],
            coordinates: 'A8',
            color: '#00830e',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'LAIR',
            name: 'Los Angeles and Independence Railroad',
            logo: '18_los_angeles/LAIR',
            simple_logo: '18_los_angeles/LAIR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'A2',
            color: '#b8ffff',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PER',
            name: 'Pacific Electric Railroad',
            logo: '18_los_angeles/PER',
            simple_logo: '18_los_angeles/PER.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'F13',
            color: '#ff6a00',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SF',
            name: 'Santa Fe Railroad',
            logo: '18_los_angeles/SF',
            simple_logo: '18_los_angeles/SF.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 Montebello (C8) token',
                hexes: ['C8'],
                count: 1,
                price: 40,
              },
              { type: 'reservation', hex: 'C8', remove: 'IV' },
            ],
            coordinates: 'D13',
            color: '#ff7fed',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SP',
            name: 'Southern Pacific Railroad',
            logo: '18_los_angeles/SP',
            simple_logo: '18_los_angeles/SP.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Los Angeles (C6) token',
                hexes: ['C6'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              { type: 'reservation', hex: 'C6', remove: 'IV' },
            ],
            coordinates: 'C2',
            color: '#0026ff',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'UP',
            name: 'Union Pacific Railroad',
            logo: '18_los_angeles/UP',
            simple_logo: '18_los_angeles/UP.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'B11',
            color: '#727272',
            always_market_price: true,
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'GT',
            name: 'Gardena Tramway',
            logo: '18_los_angeles/GT',
            simple_logo: '18_los_angeles/GT.alt',
            tokens: [0],
            coordinates: 'D5',
            color: '#644c00',
            text_color: 'white',
          },
          {
            sym: 'OCR',
            name: 'Orange County Railroad',
            logo: '18_los_angeles/OCR',
            simple_logo: '18_los_angeles/OCR.alt',
            tokens: [0],
            coordinates: 'E10',
            color: '#832e9a',
            text_color: 'white',
          },
        ].freeze
      end
    end
  end
end
