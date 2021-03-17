# frozen_string_literal: true

module Engine
  module Game
    module G18Neb
      module Config
        module CompanyConfig
          COMPANIES = [
            {
              name: 'Denver Pacific Railroad',
              value: 20,
              revenue: 5,
              desc: 'Once per game, allows Corporation owner to lay or upgrade a tile in B8',
              sym: 'DPR',
              abilities: [
                {
                  type: 'blocks_hexes',
                  owner_type: 'player',
                  remove: 3, # No tile may be placed on C7 until phase 3.
                  hexes: ['B8'],
                },
                {
                  type: 'tile_lay',
                  owner_type: 'corporation',
                  hexes: ['B8'],
                  tiles: %w[3 4 5 80 81 82 83],
                  count: 1,
                  on_phase: 3,
                },
              ],
              color: nil,
            },
            {
              name: 'Morison Bridging Company',
              value: 40,
              revenue: 10,
              desc: 'Corporation owner gets two bridge discount tokens',
              sym: 'P2',
              abilities: [
                {
                  type: 'tile_discount',
                  discount: 60,
                  terrain: 'water',
                  owner_type: 'corporation',
                  hexes: %w[K3 K5 K7 J8 L8 L10],
                  count: 2,
                  remove: 5,
                },
              ],
              color: nil,
            },
            {
              name: 'Armour and Company',
              value: 70,
              revenue: 15,
              desc: 'An owning Corporation may place a cattle token in any Town or City',
              sym: 'P3',
              abilities: [
                {
                  type: 'assign_hexes',
                  hexes: %w[B6 C3 C7 C9 E7 F6 G7 G11 H8 H10 I3 I5 J8 J12 K3 K7 L10],
                  count: 1,
                  when: 'TrackAndToken',
                  owner_type: 'corporation',
                },
                { type: 'hex_bonus', owner_type: 'corporation', amount: 20, hexes: [] },
              ],
              color: nil,
            },
            {
              name: 'Central Pacific Railroad',
              value: 100,
              revenue: 15,
              desc: 'May exchange for share in Colorado & Southern Railroad',
              sym: 'P4',
              abilities: [
                  {
                    type: 'exchange',
                    corporations: ['C&S'],
                    owner_type: 'player',
                    when: 'owning_player_stock_round',
                    from: %w[ipo market],
                  },
                  {
                    type: 'blocks_hexes',
                    owner_type: 'player',
                    hexes: ['C7'],
                    # on_phase: 3,
                    remove: 3, # No tile may be placed on C7 until phase 3.
                  },
                ],
              color: nil,
            },
            {
              name: 'Crédit Mobilier',
              value: 130,
              revenue: 5,
              desc: '$5 revenue each time ANY tile is laid or upgraded.',
              sym: 'P5',
              abilities: [
                {
                  type: 'tile_income',
                  income: 5,
                },
              ],
              color: nil,
            },
            {
              name: 'Union Pacific Railroad',
              value: 175,
              revenue: 25,
              desc: 'Comes with President\'s Certificate of the Union Pacific Railroad',
              sym: 'P6',
              abilities: [
                { type: 'shares', shares: 'UP_0' },
                { type: 'close', when: 'bought_train', corporation: 'UP' },
                { type: 'no_buy' },
              ],
              color: nil,
            },
          ].freeze
        end
      end
    end
  end
end
