# frozen_string_literal: true

module Engine
  module Game
    module G18NL
      module Entities
        COMPANIES = [
          # {
          #   name: 'Amsterdamsche Omnibus-Maatschappij',
          #   sym: 'P1',
          #   value: 20,
          #   revenue: 0,
          #   desc: 'Company may build an extra tile on F5 with a ƒ40 discount. Blocks F5 while owned by a player.',
          #   abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F5'] }],
          #   color: nil,
          # },
          {
            name: 'Geldersch-Overijsselsche Lokaalspoorweg-Maatschappij',
            sym: 'P2',
            value: 40,
            revenue: 5,
            desc: 'May lay a free token on a hex without track, no connection needed. Blocks hexes F17 and G16',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F17 G16] },
                        {
                          type: 'token',
                          owner_type: 'corporation',
                          price: 0,
                          teleport_price: 0,
                          special_only: true,
                          count: 1,
                          hexes: %w[E4 F9 F15 F19 H13 I4 I10 J5 K10],
                        }],
            color: nil,
          },
          # {
          #   name: 'De Veluwe',
          #   sym: 'P3',
          #   value: 70,
          #   revenue: 10,
          #   desc: 'A player owning this company may exchange it for a 10% share of the DV if they do not already hold 60%'\
          #         'of the DV and there is DV stock available in the Bank or the Pool. The exchange may be made during'\
          #         " the player's turn of a stock round or between the turns of other players or corporations in either "\
          #         'stock or operating rounds. This action closes the private. Blocks F9 while owned by a player.',
          #   abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F9'] },
          #               {
          #                 type: 'exchange',
          #                 corporations: ['DV'],
          #                 owner_type: 'player',
          #                 when: 'any',
          #                 from: %w[ipo market],
          #               }],
          #   color: nil,
          # },
          # {
          #   name: 'De Twentsche Electrische Tramweg-Maatschappij',
          #   sym: 'P4',
          #   value: 110,
          #   revenue: 10,
          #   desc: 'The initial purchaser of this company immediately receives a 10% share of NCS stock without further'\
          #         ' payment. This action does not close the NCS. The corporation will not be running at this point,'\
          #         ' but the stock may be retained or sold subject to the ordinary rules of the game.'\
          #         ' Blocks F19 while owned by a player.',
          #   abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F19'] },
          #               { type: 'shares', shares: 'NCS_1' }],
          #   color: nil,
          # },
          # {
          #   name: 'Hollandsche Ijzeren Spoorweg-Maatschappij',
          #   sym: 'P5',
          #   value: 160,
          #   revenue: 10,
          #   desc: "The owner of the HIS immediately receives the President's 20% certificate of the"\
          #         ' HIS without further payment and immediately sets its par price. The private company may not be sold to any'\
          #         ' corporation, and does not exchange hands if the owning player loses the Presidency of the HIS.'\
          #         ' When the HIS purchases its first train the private company is closed.'\
          #         ' Blocks E4 & E6 while owned by a player.',
          #   abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[E4 E6] },
          #               { type: 'close', when: 'bought_train', corporation: 'HIS' },
          #               { type: 'no_buy' },
          #               { type: 'shares', shares: 'HIS_0' }],
          #   color: nil,
          # },
          # {
          #   name: 'Spoorweg-Maatschappij Zuid Beveland',
          #   sym: 'P6',
          #   value: 200,
          #   revenue: 15,
          #   desc: "The owner of the Antwerpen-Rotterdamsche immediately receives the President's 30% certificate of the"\
          #         ' NFL without further payment and immediately sets its par price. The private company may not be sold to any'\
          #         ' corporation, and does not exchange hands if the owning player loses the Presidency of the NFL.'\
          #         ' When the NFL purchases its first train the private company is closed.'\
          #         ' Blocks E4 & E6 while owned by a player.',
          #   abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[J3 K2] },
          #               { type: 'close', when: 'bought_train', corporation: 'NFL' },
          #               { type: 'no_buy' },
          #               { type: 'shares', shares: 'NFL_0' }],
          #   color: nil,
          # },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'AS',
            name: 'Almelo-Salzbergen',
            logo: '18_nl/AS',
            tokens: [0, 40, 100, 100],
            coordinates: 'E16',
            color: 'red',
          },
          {
            float_percent: 60,
            sym: 'HIS',
            name: 'Hollandsche Ijzeren Spoorweg',
            logo: '18_nl/HIS',
            tokens: [0, 40, 100],
            coordinates: 'E6',
            city: 0,
            color: 'blue',
          },
          {
            float_percent: 60,
            sym: 'NCS',
            name: 'Nederlandsche Centraal',
            logo: '18_nl/NCS',
            tokens: [0, 40, 100, 100],
            coordinates: 'F13',
            color: 'green',
          },
          {
            float_percent: 20,
            sym: 'DV',
            name: 'De Vuluwe',
            logo: '18_nl/DV',
            tokens: [0, 40, 100, 100],
            coordinates: 'G8',
            color: 'black',
          },
          {
            float_percent: 60,
            sym: 'NFL',
            name: 'Noord Friesche Lokaal',
            logo: '18_nl/NFL',
            tokens: [0, 40],
            coordinates: 'B15',
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            text_color: 'black',
            color: 'magenta',
          },
          {
            float_percent: 60,
            sym: 'NRS',
            name: 'Nederlansche Rhijnspoorweg-Maatschappij',
            logo: '18_nl/NRS',
            tokens: [0, 40],
            coordinates: 'E6',
            city: 1,
            text_color: 'black',
            color: 'orange',
          },
          {
            float_percent: 60,
            sym: 'NZO',
            name: 'Nederlansche Zuid-Ooster',
            logo: '18_nl/NZO',
            tokens: [0, 40, 100],
            coordinates: 'H13',
            city: 0,
            text_color: 'black',
            color: 'yellow',
          },
          {
            float_percent: 60,
            sym: 'MES',
            name: 'Maatschappij tot Exploitatie van Staatsspoorwegen',
            logo: '18_nl/MES',
            tokens: [0, 40, 100],
            coordinates: 'J7',
            text_color: 'black',
            color: 'lightBlue',
          },
          {
            float_percent: 60,
            sym: 'ZHE',
            name: '	Zuid-Hollandsche Electrische Spoorweg-Maatschappij',
            logo: '18_nl/ZHE',
            tokens: [0, 40],
            coordinates: 'G2',
            city: 1,
            color: 'purple',
          },
        ].freeze
      end
    end
  end
end
