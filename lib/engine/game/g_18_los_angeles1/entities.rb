# frozen_string_literal: true

module Engine
  module Game
    module G18LosAngeles1
      module Entities
        # companies found only in 1st Edition
        COMPANIES = [
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
        ].freeze

        # companies with different properties in 1st Edition
        COMPANIES_1E = {
          'CHE' => {
            name: 'Chino Hills Excavation',
            value: 60,
            revenue: 20,
            desc: 'Reduces, for the owning corporation, the cost of laying '\
                  'all hill tiles and tunnel/pass hexsides by $20.',
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

          'LAC' => {
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

          'LAS' => {
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
          'PT' => {
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
        }.freeze

        # corporations with different properties in 1st Edition
        CORPORATIONS_1E = {
          'ELA' => {
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
          'PER' => {
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
          'SF' => {
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
          'SP' => {
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
        }.freeze
      end
    end
  end
end
