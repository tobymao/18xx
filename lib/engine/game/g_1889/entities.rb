# frozen_string_literal: true

module Engine
  module Game
    module G1889
      module Entities
        COMPANIES = [
          {
            name: 'Takamatsu E-Railroad',
            value: 20,
            revenue: 5,
            desc: 'Blocks Takamatsu (K4) while owned by a player.',
            sym: 'TR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K4'] }],
            color: nil,
          },
          {
            name: 'Mitsubishi Ferry',
            value: 30,
            revenue: 5,
            desc: 'Player owner may place the port tile on a coastal town (B11,'\
                  ' G10, I12, or J9) without a tile on it already, outside of '\
                  'the operating rounds of a corporation controlled by another '\
                  'player. The player need not control a corporation or have '\
                  'connectivity to the placed tile from one of their '\
                  'corporations. This does not close the company.',
            sym: 'MF',
            abilities: [
              {
                type: 'tile_lay',
                when: %w[stock_round owning_player_track or_between_turns],
                hexes: %w[B11 G10 I12 J9],
                tiles: ['437'],
                owner_type: 'player',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Ehime Railway',
            value: 40,
            revenue: 10,
            desc: 'When this company is sold to a corporation, the selling '\
                  'player may immediately place a green tile on Ohzu (C4), '\
                  'in addition to any tile which it may lay during the same '\
                  'operating round. This does not close the company. Blocks '\
                  'C4 while owned by a player.',
            sym: 'ER',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C4'] },
                        {
                          type: 'tile_lay',
                          hexes: ['C4'],
                          tiles: %w[12 13 14 15 205 206],
                          when: 'sold',
                          owner_type: 'corporation',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Sumitomo Mines Railway',
            value: 50,
            revenue: 15,
            desc: 'Owning corporation may ignore building cost for mountain '\
                  'hexes which do not also contain rivers. This does not close '\
                  'the company.',
            sym: 'SMR',
            abilities: [
              {
                type: 'tile_discount',
                discount: 80,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Dougo Railway',
            value: 60,
            revenue: 15,
            desc: 'Owning player may exchange this private company for a 10% '\
                  'share of Iyo Railway from the initial offering.',
            sym: 'DR',
            abilities: [
              {
                type: 'exchange',
                corporations: ['IR'],
                owner_type: 'player',
                when: 'any',
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'South Iyo Railway',
            value: 80,
            revenue: 20,
            desc: 'No special abilities.',
            sym: 'SIR',
            color: nil,
          },
          {
            name: 'Uno-Takamatsu Ferry',
            value: 150,
            revenue: 30,
            desc: 'Does not close while owned by a player. If owned by a player '\
                  'when the first 5-train is purchased it may no longer be sold '\
                  'to a public company and the revenue is increased to 50.',
            sym: 'UTF',
            min_players: 4,
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'player' },
                        {
                          type: 'revenue_change',
                          revenue: 50,
                          on_phase: '5',
                          owner_type: 'player',
                        }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'AR',
            name: 'Awa Railroad',
            logo: '1889/AR',
            simple_logo: '1889/AR.alt',
            tokens: [0, 40],
            coordinates: 'K8',
            color: '#37383a',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'IR',
            name: 'Iyo Railway',
            logo: '1889/IR',
            simple_logo: '1889/IR.alt',
            tokens: [0, 40],
            coordinates: 'E2',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Sanuki Railway',
            logo: '1889/SR',
            simple_logo: '1889/SR.alt',
            tokens: [0, 40],
            coordinates: 'I2',
            color: '#76a042',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KO',
            name: 'Takamatsu & Kotohira Electric Railway',
            logo: '1889/KO',
            simple_logo: '1889/KO.alt',
            tokens: [0, 40],
            coordinates: 'K4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'TR',
            name: 'Tosa Electric Railway',
            logo: '1889/TR',
            simple_logo: '1889/TR.alt',
            tokens: [0, 40, 40],
            coordinates: 'F9',
            color: '#00a993',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KU',
            name: 'Tosa Kuroshio Railway',
            logo: '1889/KU',
            simple_logo: '1889/KU.alt',
            tokens: [0],
            coordinates: 'C10',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'UR',
            name: 'Uwajima Railway',
            logo: '1889/UR',
            simple_logo: '1889/UR.alt',
            tokens: [0, 40, 40],
            coordinates: 'B7',
            color: '#6f533e',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
