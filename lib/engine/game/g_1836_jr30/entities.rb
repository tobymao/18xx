# frozen_string_literal: true

module Engine
  module Game
    module G1836Jr30
      module Entities
        COMPANIES = [
          {
            name: 'Amsterdam Canal Company',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D6 while owned by player.',
            sym: 'ACC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D6'] }],
          },
          {
            name: 'Enkhuizen-Stavoren Ferry',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may place a free tile on the E-SF hex B8 (the IJsselmeer Causeway) free of cost'\
                  ', in addition to its own tile placement. Blocks hex B8 while owned by player.',
            sym: 'E-SF',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B8'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['B8'],
                          tiles: %w[2 56],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
          },
          {
            name: 'Charbonnages du Hainaut',
            value: 70,
            revenue: 15,
            desc: 'Owning corporation may place a tile and station token in the CdH hex J8 for only the F60 cost of'\
                  ' the mountain. The track is not required to be connected to existing track of this corporation (or any'\
                  " corporation), and can be used as a teleport. This counts as the corporation's track lay for that turn."\
                  ' Blocks hex J8 while owned by player.',
            sym: 'CdH',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J8'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: ['57'],
                          hexes: ['J8'],
                        }],
          },
          {
            name: 'Grand Central Belge',
            value: 110,
            revenue: 20,
            desc: 'Owning player may exchange the GCB for a 10% certificate of the Chemins de Fer de L’Etat Belge (B)'\
                  ' from the bank or the bank pool, subject to normal certificate limits. This closes the private company.'\
                  ' The exchange may be made a) in a stock round, during the player’s turn or between the turns of other'\
                  ' players, or b) in an operating round, between the turns of corporations. Blocks hexes G7, G9, & H10'\
                  ' while owned by player.',
            sym: 'GCB',
            abilities: [
              {
                type: 'exchange',
                corporations: ['B'],
                owner_type: 'player',
                from: %w[ipo market],
              },
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: %w[G7 G9 H10],
              },
            ],
          },
          {
            name: 'Chemins de Fer Luxembourgeois',
            value: 160,
            revenue: 25,
            desc: 'Upon purchase, the owning player receives a 10% certificate of the Grande Compagnie du Luxembourg'\
                  ' (GCL). This certificate may only be sold once the GCL President’s Certificate has been purchased and a'\
                  ' par price set, subject to standard rules. Blocks hexes K11 & J12 while owned by player.',
            sym: 'CFL',
            abilities: [{ type: 'shares', shares: 'GCL_1' },
                        {
                          type: 'blocks_hexes',
                          owner_type: 'player',
                          hexes: %w[K11 J12],
                        }],
          },
          {
            name: 'Chemin de Fer de Lille à Valenciennes',
            value: 220,
            revenue: 30,
            desc: 'Upon purchase, the owning player receives the President’s Certificate of the Chemin de Fer du Nord'\
                  ' (Nord) and must immediately set the par price. This private company may not be bought by a corporation,'\
                  ' and closes when the Nord buys its first train. Blocks hexes I3 & J4 while owned by player.',
            sym: 'CFLV',
            abilities: [{ type: 'shares', shares: 'Nord_0' },
                        { type: 'close', when: 'bought_train', corporation: 'Nord' },
                        { type: 'no_buy' },
                        {
                          type: 'blocks_hexes',
                          owner_type: 'player',
                          hexes: %w[I3 J4],
                        }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'B',
            name: "Chemins de Fer de L'État Belge",
            logo: '1836_jr/B',
            simple_logo: '1836_jr/B.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H6',
            color: 'black',
          },
          {
            sym: 'GCL',
            name: 'Grande Compagnie du Luxembourg',
            logo: '1836_jr/GCL',
            simple_logo: '1836_jr/GCL.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'I9',
            color: 'green',
          },
          {
            sym: 'Nord',
            name: 'Chemin de Fer du Nord',
            logo: '1836_jr/Nord',
            simple_logo: '1836_jr/Nord.alt',
            tokens: [0, 40, 100],
            coordinates: 'I3',
            color: 'darkblue',
          },
          {
            sym: 'NBDS',
            name: 'Noord-Brabantsch-Duitsche Spoorweg-Maatschappij',
            logo: '1836_jr/NBDS',
            simple_logo: '1836_jr/NBDS.alt',
            tokens: [0, 40, 100],
            coordinates: 'E11',
            color: '#ffcd05',
            text_color: 'black',
          },
          {
            sym: 'HSM',
            name: 'Hollandsche IJzeren Spoorweg Maatschappij',
            logo: '1836_jr/HSM',
            simple_logo: '1836_jr/HSM.alt',
            tokens: [0, 40],
            coordinates: 'D6',
            color: '#f26722',
          },
          {
            sym: 'NFL',
            name: 'Noord-Friesche Locaal',
            logo: '1836_jr/NFL',
            simple_logo: '1836_jr/NFL.alt',
            tokens: [0, 40],
            coordinates: 'A9',
            color: '#90ee90',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
