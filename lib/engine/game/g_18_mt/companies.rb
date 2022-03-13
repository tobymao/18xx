# frozen_string_literal: true

module Engine
  module Game
    module G18MT
      module Companies
        COMPANIES = [
          {
            sym: 'GP',
            name: 'Gilmore & Pittsburgh Railroad',
            value: 20,
            revenue: 5,
            desc: 'Blocks hexes “G5” and “G7” while owned by a player. Closes on purchase of “5” train.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[G5 G7] },
                        { type: 'close', on_phase: '5' }],
            color: nil,
          },
          {
            sym: 'GV',
            name: 'Gallatin Valley Railway',
            value: 30,
            revenue: 10,
            desc: 'An owning Corporation receives a $20 discount on the cost of tile lays. '\
                  'Blocks hex “F20” while owned by a player. Closes on purchase of “5” train.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F20'] },
                        { type: 'close', on_phase: '5' },
                        { type: 'tile_discount', discount: 20 }],
            color: nil,
          },
          {
            sym: 'MW',
            name: 'Montana Western Railway',
            value: 40,
            revenue: 10,
            desc: 'An owning Corporation may upgrade any green plain track tile to the '\
                  'mts tile in addition to its normal tile lay. This tile connects all routes. '\
                  'Blocks hex “B6” while owned by a player. Revenue decreases to $0 on purchase of “5” train. '\
                  'Closes on purchase of “5” train if owned by a player, otherwise after laying the mts tile.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B6'] },
                        { type: 'revenue_change', revenue: 0, on_phase: '5' },
                        { type: 'close', owner_type: 'player', on_phase: '5' },
                        {
                          type: 'tile_lay',
                          free: false,
                          special: true,
                          reachable: true,
                          owner_type: 'corporation',
                          when: 'track',
                          count: 1,
                          closed_when_used_up: true,
                          hexes: %w[B4 B6 B8 B10 B12 B14 B18 C5 C13 C15 C17 D8 D10 D12 D16 D20 E3 E13 E19 F6 F14],
                          tiles: ['mts'],
                        }],
            color: nil,
          },
          {
            sym: 'WSS',
            name: 'White Sulpur Springs & Yellowstone Park',
            value: 50,
            revenue: 15,
            desc: 'The purchasing player immediately receives one share of a railroad '\
                  '(MC, MWS, MR or BAP). Closes on purchase of “5” train.',
            abilities: [{ type: 'close', on_phase: '5' },
                        { type: 'shares', shares: 'random_share', corporations: %w[MC MWS MR BAP] }],
            color: nil,
          },
          {
            sym: 'YPR',
            name: 'Yellowstone Park Railroad',
            value: 60,
            revenue: 15,
            desc: 'Owning corporation may purchase one “3”, “4”, or “5” train from the bank '\
                  'with a discount of 50%. Action closes the company or closes on purchase of “5” train.',
            abilities: [{ type: 'close', on_phase: '5' },
                        {
                          type: 'train_discount',
                          discount: 0.5,
                          owner_type: 'corporation',
                          trains: %w[3 4 5],
                          count: 1,
                          closed_when_used_up: true,
                          when: 'buying_train',
                        }],
            color: nil,
          },
          {
            sym: 'SOO',
            name: 'Soo Line Railroad',
            value: 140,
            revenue: 20,
            desc: 'The purchasing player immediately receives the Presidency of Milwaukee Road. '\
                  'Blocks hex “A19”. Closes on MILW purchasing a train or purchase of “5” train. '\
                  'Cannot be purchased by a corporation. Does not count towards net worth.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['A19'] },
                        { type: 'close', when: 'bought_train', corporation: 'MILW' },
                        { type: 'close', on_phase: '5' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'MILW_0' }],
            color: nil,
          },
        ].freeze
      end
    end
  end
end
