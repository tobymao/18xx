# frozen_string_literal: true

module Engine
  module Game
    module G1850Jr
      module Entities
        COMPANIES = [
          {
            name: 'Trenino Corleone-Monreale',
            sym: 'TCM',
            value: 40,
            revenue: 10,
            desc: 'A corporation owning the TCM may lay a tile on D4 without cost, even if this hex is not connected'\
                  " to the corporation's track. This free tile placement is in addition to the corporation's normal tile"\
                  ' placement. Blocks D4 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D4'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          hexes: ['D4'],
                          free: true,
                          tiles: %w[7 8 9],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Ferrovia Siracusana Marittima',
            sym: 'FSM',
            value: 110,
            revenue: 20,
            desc: 'A player owning the MH may exchange it for a 10% share of the SFA if they do not already hold 60%'\
                  ' of the SFA and there is SFA stock available in the Bank or the Pool. The exchange may be made during'\
                  " the player's turn of a stock round or between the turns of other players or corporations in either "\
                  'stock or operating rounds. This action closes the private company. Blocks G9 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['G9'] },
                        {
                          type: 'exchange',
                          corporations: ['SFA'],
                          owner_type: 'player',
                          when: 'any',
                          from: %w[ipo market],
                        }],
            color: nil,
          },
          {
            name: 'Strada di Ferro Trinacria',
            sym: 'SFT',
            value: 220,
            revenue: 30,
            desc: "The owner of this private company immediately receives the President's certificate of the"\
                  ' IFT without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the IFT.'\
                  ' When the IFT purchases its first train the private company is closed.'\
                  ' Blocks F6 & G5 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F6 G5] },
                        { type: 'close', when: 'bought_train', corporation: 'IFT' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'IFT_0' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'IFT',
            name: 'Impresa Ferroviaria Trinacria',
            logo: '1849/IFT',
            simple_logo: '1849/IFT.alt',
            tokens: [0, 40, 100],
            coordinates: 'G5',
            color: '#0189d1',
          },
          {
            float_percent: 60,
            sym: 'SFA',
            name: 'Società Ferroviaria Akragas',
            logo: '1849/SFA',
            simple_logo: '1849/SFA.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'D6',
            color: :pink,
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'CTL',
            name: 'Compagnia Transporti Lilibeo',
            logo: '1849/CTL',
            simple_logo: '1849/CTL.alt',
            tokens: [0, 40, 100],
            coordinates: 'B4',
            color: :'#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'RCS',
            name: 'Rete Centrale Sicula',
            logo: '1849/RCS',
            simple_logo: '1849/RCS.alt',
            tokens: [0, 40],
            coordinates: 'D2',
            city: 1,
            color: '#f48221',
          },
        ].freeze
      end
    end
  end
end
