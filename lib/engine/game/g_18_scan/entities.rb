# frozen_string_literal: true

module Engine
  module Game
    module G18Scan
      module Entities
        COMPANIES = [
          {
            sym: 'Ferry',
            name: 'Stockholm-Åbo Ferry Company',
            value: 120,
            revenue: 20,
            desc:
              'Comes with two +20 bonus tokens. '\
              'Tokens may be purchased by a Corporation for K20 to gain a +20 '\
              'bonus to runs across the ferry on L7. '\
              'Comes with a 10% share of the Valtionraurariet (VR)',
            abilities: [
              { type: 'no_buy' },
              { type: 'shares', shares: 'VR_1' },
              # TODO: Ferry token svg
              {
                type: 'assign_corporation',
                when: 'owning_player_token',
                count: 2,
                owner_type: 'player',
              },
            ],
            color: nil,
          },
          {
            sym: 'Mine',
            name: 'Lapland Ore Line',
            value: 150,
            revenue: 25,
            desc:
              'Comes with one +50 bonus token. '\
              'Token can be purchased by a Corporation for K50 to gain a +50 '\
              'bonus to one run through Kiruna (A20) hex once per OR. '\
              'Comes with a 10% share of the Sveriges & Norges Järnvägar '\
              '(S&NJ)',
            abilities: [
              { type: 'no_buy' },
              { type: 'shares', shares: 'S&NJ_1' },
              # TODO: Ore mine token svg
              {
                type: 'assign_corporation',
                when: 'owning_player_token',
                count: 1,
                owner_type: 'player',
              },
            ],
            color: nil,
          },
          {
            sym: 'SJS',
            name: 'Sjællandske Jernbaneselskab',
            value: 180,
            revenue: 30,
            desc:
              'May lay or upgrade a COP (F3) tile for free. '\
              'Comes with a president\'s certificate of the '\
              'Danske Statsbaner (DSB)',
            abilities: [
              { type: 'no_buy' },
              { type: 'shares', shares: 'DSB_0' },
              { type: 'close', when: 'bought_train', corporation: 'DSB' },
              {
                type: 'tile_lay',
                hexes: %w[F3],
                tiles: %w[403 121 584],
                when: 'owning_player_track',
                owner_type: 'player',
                count: 1,
                consume_tile_lay: true,
                special: true,
              },
            ],
            color: nil,
          },
          {
            sym: '1',
            name: 'Södra Stambanan',
            value: 260,
            revenue: 0,
            desc:
              'Owner takes control of Minor Company 1, which begins in '\
              'Malmo (G4) and has destination in Goteborg (B11). When Phase 5 '\
              'begins, the Minor Company closes, transferring all belongings '\
              'to SJ, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: '2',
            name: 'Nordvärsta Stambanan',
            value: 220,
            revenue: 0,
            desc:
              'Owner takes control of Minor Company 2, which begins in '\
              'Stockholm (F11/NW) and has destination in Trondheim (F11). '\
              'When Phase 5 begins, the Minor Company closes, transferring '\
              'all belongings to SJ, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: '3',
            name: 'Värsta Stambanan',
            value: 200,
            revenue: 0,
            desc:
              'Owner takes control of Minor Company 3, which begins in '\
              'Stockholm (F11/SW) and has destination in Oslo (D7). When '\
              'Phase 5 begins, the Minor Company closes, transferring all '\
              'belongings to SJ, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },

        ].freeze

        MINORS = [
          {
            sym: '1',
            name: 'Södra Stambanan',
            logo: '18_scan/1',
            simple_logo: '18_scan/1.alt',
            type: 'minor',
            tokens: [0, 40],
            coordinates: 'G4',
            destination_coordinates: 'B11',
            color: '#5b74b4',
            abilities: [
              {
                type: 'train_limit',
                increase: -2,
              },
              {
                type: 'token',
                hexes: ['B11'],
                cheater: 1,
                price: 0,
                special_only: true,
              },
            ],
          },
          {
            sym: '2',
            name: 'Nordvärsta Stambanan',
            logo: '18_scan/2',
            simple_logo: '18_scan/2.alt',
            type: 'minor',
            tokens: [0, 40],
            coordinates: 'F11',
            city: 1,
            destination_coordinates: 'B11',
            color: '#5b74b4',
            abilities: [
              {
                type: 'train_limit',
                increase: -2,
              },
              {
                type: 'token',
                hexes: ['F11'],
                cheater: 1,
                price: 0,
                special_only: true,
              },
            ],
          },
          {
            sym: '3',
            name: 'Västra Stambanan',
            logo: '18_scan/3',
            simple_logo: '18_scan/3.alt',
            type: 'minor',
            tokens: [0, 40],
            coordinates: 'F11',
            city: 0,
            destination_coordinates: 'D7',
            color: '#5b74b4',
            abilities: [
              {
                type: 'train_limit',
                increase: -2,
              },
              {
                type: 'token',
                hexes: ['D7'],
                cheater: 1,
                price: 0,
                special_only: true,
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'DSB',
            name: 'Danske Statsbaner',
            type: 'major',
            logo: '18_scan/DSB',
            simple_logo: '18_scan/DSB.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 40, 100],
            coordinates: 'F3',
            color: '#C62A1D',
          },
          {
            sym: 'S&NJ',
            name: 'Sveriges & Norges Järnvägar',
            type: 'major',
            logo: '18_scan/SNJ',
            simple_logo: '18_scan/SNJ.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 40, 100],
            coordinates: 'B19',
            color: '#010301',
          },
          {
            sym: 'NSB',
            name: 'Norges Statsbaner',
            type: 'major',
            logo: '18_scan/NSB',
            simple_logo: '18_scan/NSB.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 40, 100, 100],
            coordinates: 'D7',
            color: '#041848',
          },
          {
            sym: 'VR',
            name: 'Valtionraurariet',
            type: 'major',
            logo: '18_scan/VR',
            simple_logo: '18_scan/VR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 40, 100, 100],
            coordinates: 'G14',
            color: '#2157B2',
          },
          {
            sym: 'SJ',
            name: 'Statens Järnvägar',
            logo: '18_scan/SJ',
            simple_logo: '18_scan/SJ.alt',
            type: 'national',
            float_percent: 50,
            floatable: false,
            tokens: [0, 100, 100, 100, 100, 100],
            color: '#3561AE',
          },
        ].freeze
      end
    end
  end
end
