# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Companies
        COMPANIES = [
          {
            name: 'Merchants and Co.',
            value: 40,
            revenue: 5,
            desc: 'May be exchanged for an exchange share of the Shortline during the stock round. ' \
                  'Player may still sell and buy stock on this turn.',
            sym: 'MC',
            color: nil,
            abilities: [{
              type: 'exchange',
              corporations: 'shortline',
              owner_type: 'player',
              when: 'owning_player_sr_turn',
              from: %w[reserved],
            }, { type: 'no_buy' }],
          },
          {
            name: 'Vernon River Bridge Company',
            value: 40,
            revenue: 5,
            desc: 'Blocks: N18 (player choice). ' \
                  'Unblocks when exchanged. ' \
                  'May be exchanged for an exchange share of the Shortline. ' \
                  'Player may still sell and buy stock on this turn.',
            sym: 'VR',
            color: nil,
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['N18'] },
                        {
                          type: 'exchange',
                          corporations: 'shortline',
                          owner_type: 'player',
                          when: 'owning_player_sr_turn',
                          from: %w[reserved],
                        }, { type: 'no_buy' }],
          },
          {
            name: 'Ice Boat Shipping',
            value: 40,
            revenue: 5,
            min_players: 4,
            desc: 'May be exchanged for a share from the market of any corporation that isn\'t Mainline or Shortline. ' \
                  'Player may still sell and buy stock on this turn.',
            sym: 'IB',
            color: nil,
            abilities: [{ type: 'no_buy' }],
          },
          {
            name: 'Royal Agricultural Society',
            value: 110,
            revenue: 10,
            desc: 'Comes with a Mainline share.',
            sym: 'RA',
            color: nil,
            abilities: [{ type: 'shares', shares: 'mainline_1' }, { type: 'no_buy' }],
          },
          {
            name: 'Railcar Ferry: the Prince Edward Island',
            value: 120,
            revenue: 15,
            desc: 'Comes with a Mainline Share.',
            sym: 'RF',
            color: nil,
            abilities: [{ type: 'shares', shares: 'mainline_2' }, { type: 'no_buy' }],
          },
          {
            name: 'Shipbuilding',
            value: 90,
            revenue: 15,
            desc: 'May be exchanged for an exchange share of the Shortline during the stock round. ' \
                  'Player may still sell and buy stock on this turn.',
            sym: 'SB',
            color: nil,
            abilities: [{
              type: 'exchange',
              corporations: 'shortline',
              owner_type: 'player',
              when: 'owning_player_sr_turn',
              from: %w[reserved],
            }, { type: 'no_buy' }],
          },
          {
            name: 'Hunslet Steam Engine',
            value: 110,
            revenue: 20,
            min_price: 1,
            max_price: 200,
            desc: 'May be sold to a corporation for $1 to $200. ' \
                  'May not be sold to the PEIR. ' \
                  'The owning corporation may close this to buy a train from the supply anytime during its operation.',
            sym: 'HSE',
            color: nil,
            abilities: [{
              type: 'purchase_train',
              owner_type: 'corporation',
              when: 'owning_corp_or_turn',
            }],
          },
          {
            name: 'Mainline Concession',
            value: 160,
            revenue: 20,
            desc: 'Comes with the (20%) president\'s certificate of the Mainline corporation. ' \
                  'Closes when the Mainline operates. ' \
                  'The Mainline may operate as soon as this item is sold.',
            sym: 'ML',
            color: nil,
            abilities: [{ type: 'shares', shares: 'mainline_0' },
                        { type: 'close', when: 'operated', corporation: 'mainline' }, { type: 'no_buy' }],
          },
          {
            name: 'Schreiber and Burpee Construction',
            value: 100,
            revenue: 30,
            desc: 'Comes with yellow straight tile. ' \
                  'Placement counts as normal tile lay. ' \
                  'Must follow all normal track laying rules.',
            sym: 'SBC',
            color: nil,
            abilities: [{ type: 'no_buy' }],
          },
          {
            name: 'Short Line Concession',
            value: 160,
            revenue: 30,
            desc: 'Comes with the (20%) president\'s certificate of the Shortline. Closes when the Shortline operates.',
            sym: 'SL',
            color: nil,
            abilities: [{ type: 'shares', shares: 'shortline_0' },
                        { type: 'close', when: 'operated', corporation: 'shortline' }, { type: 'no_buy' }],

          },
          {
            name: 'Union Bank',
            value: 120,
            revenue: 0,
            desc: 'Comes with one Mainline share and one Random share. ' \
                  'Does not close. ' \
                  'Owning player may buy 1 share per stock round for the Bank combining the bank\'s treasury with their own.',
            sym: 'UB',
            color: nil,
            abilities: [{ type: 'close', on_phase: 'never' }, { type: 'no_buy' }],
          },
          {
            name: 'The King\'s Mail',
            value: 0,
            revenue: 80,
            desc: 'Always assigned to the PEIR corporation. The PEIR starts with $200 in its treasury. ' \
                  'Closes with other privates on the 4+.',
            sym: 'KM',
            color: nil,
            abilities: [{ type: 'no_buy' }],
          },
        ].freeze
      end
    end
  end
end
