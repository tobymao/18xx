# frozen_string_literal: true

module Engine
  module Game
    module G18GA
      module Entities
        COMPANIES = [
          {
            name: 'Lexington Terminal RR',
            value: 20,
            revenue: 5,
            desc: 'No special ability.',
            sym: 'LTR',
          },
          {
            name: 'Midland Railroad Co.',
            value: 40,
            revenue: 10,
            desc: 'Blocks hex F12 while owned by a player. A corporation that owns the Midland may '\
                  'lay a tile in the Midland\'s hex for free, once. The tile need not be connected '\
                  'to an existing station of the corporation. The corporation need not pay the $40 '\
                  'cost of the swamp. And it does not count as the corporation\'s one tile lay per '\
                  'turn. (But it still must be laid during the tile-laying step of the corporation\'s '\
                  'turn, and it must not dead-end into a blank side of a red or gray hex, or off the '\
                  'map.) This action does not close the Midland.',
            sym: 'MRC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F12'] },
                        {
                          type: 'tile_lay',
                          free: true,
                          count: 1,
                          owner_type: 'corporation',
                          hexes: ['F12'],
                          tiles: %w[7 8 9],
                          when: 'track',
                        }],
          },
          {
            name: 'Waycross & Southern RR',
            value: 70,
            revenue: 15,
            desc: 'A corporation that owns the Waycross & Southern may place a station token in '\
                  'Waycross at no cost, if there is room. The corporation need not connect to Waycross '\
                  'to use this special ability. However, it can only be done during the token-placement '\
                  'step of the corporation\'s turn, and only if the corporation has a token left, and it '\
                  'counts as the corporation\'s one station placement allowed per turn (excluding the home '\
                  'station). This action does not close the Waycross & Southern. As an exception to rule '\
                  '4.2.1(k), any corporation is free to lay tiles in the Waycross hex even if the Waycross '\
                  '& Southern is still owned by a player. ',
            sym: 'W&SR',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                hexes: ['I9'],
                price: 0,
                teleport_price: 0,
                count: 1,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Ocilla Southern RR',
            value: 100,
            revenue: 20,
            desc: 'Block hex G7 while owned by a player. When a Corporation purchases the Ocilla '\
                  'Southern, the corporation immediately gets the 2 Train marked Free (unless a 4 Train '\
                  'has been purchased or the corporation already has four trains, in which case the free '\
                  'train is removed from play). This acquisition is not considered a train purchase '\
                  '(so it does not prevent the corporation from also purchasing a train on the same turn), '\
                  'and does not close the Ocilla Southern. The free train cannot be sold to another '\
                  'corporation. In all other respects it is a normal 2 Train. ',
            sym: 'OSR',
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['G7'],
              },
            ],
          },
          {
            name: 'Macon & Birmingham RR',
            value: 150,
            revenue: 25,
            desc: 'Block hex F4 while owned by a player. Purchasing player immediately takes a 10% '\
                  'share of the Central of Georgia. This does not close the private company. This private '\
                  'company has no other special ability. ',
            sym: 'M&BR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F4'] },
                        { type: 'shares', shares: 'CoG_1' }],
          },
        ].freeze

        def game_corporations
          [
            {
              float_percent: 60,
              sym: 'ACL',
              name: 'Atlantic Coast Line',
              logo: '18_ga/ACL',
              simple_logo: '18_ga/ACL.alt',
              tokens: [0, 40, 100, 100],
              coordinates: 'J12',
              color: 'black',
            },
            {
              float_percent: 60,
              sym: 'CoG',
              name: 'Central of Georgia Railroad',
              logo: '18_ga/CoG',
              simple_logo: '18_ga/CoG.alt',
              tokens: [0, 40, 100, 100],
              coordinates: 'F6',
              color: 'red',
            },
            {
              float_percent: 60,
              sym: 'G&F',
              name: 'Georgia and Florida Railroad',
              logo: '18_ga/GF',
              simple_logo: '18_ga/GF.alt',
              tokens: [0, 40],
              coordinates: @optional_rules&.include?(:new_georgia_florida_home) ? 'G3' : 'H4',
              color: 'deepskyblue',
              text_color: 'black',
            },
            {
              float_percent: 60,
              sym: 'GA',
              name: 'Georgia Railroad',
              logo: '18_ga/GA',
              simple_logo: '18_ga/GA.alt',
              tokens: [0, 40, 100, 100],
              coordinates: 'D10',
              city: 0,
              color: 'green',
            },
            {
              float_percent: 60,
              sym: 'W&A',
              name: 'Western and Atlantic Railroad',
              logo: '18_ga/WA',
              simple_logo: '18_ga/WA.alt',
              tokens: [0, 40],
              coordinates: 'D4',
              color: 'purple',
            },
            {
              float_percent: 60,
              sym: 'SAL',
              name: 'Seaboard Air Line',
              logo: '18_ga/SAL',
              simple_logo: '18_ga/SAL.alt',
              tokens: [0, 40, 100],
              coordinates: 'G13',
              color: 'gold',
              text_color: 'black',
            },
          ]
        end
      end
    end
  end
end
