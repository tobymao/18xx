# frozen_string_literal: true

module Engine
  module Game
    module G1836Jr56
      module Entities
        COMPANIES = [
          {
            name: 'Amsterdam Canal Company',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D6 while owned by player.',
            sym: 'ACC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D6'] }],
            color: nil,
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
            color: nil,
          },
          {
            name: 'Charbonnages du Hainaut',
            value: 50,
            revenue: 10,
            desc: 'Owning corporation may place a tile and station token in the CdH hex J8 for only the F60 cost of'\
                  ' the mountain. The track is not required to be connected to existing track of this corporation (or any'\
                  " corporation), and can be used as a teleport. This counts as the corporation's track lay for that turn."\
                  ' Blocks hex J8 while owned by player.',
            sym: 'CdH',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J8'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: %w[6 5 57],
                          hexes: ['J8'],
                        }],
            color: nil,
          },
          {
            # Rules questions
            # https://boardgamegeek.com/thread/2344775/regie-des-postes-private-company-clarification
            name: 'Régie des Postes',
            value: 70,
            revenue: 15,
            desc: 'Owning Corporation may place the +"20" token on any City or Town. The value of the location is '\
                  ' increased by F20 for each and every time that Corporation\'s trains visit it',
            sym: 'RdP',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A9 B8 B10 D6 E5 E11 F4 F10 G7 H2 H4 H6 H10 I3 I9 J6 J8 K11],
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
          {
            sym: 'MESS',
            logo: '1836_jr/DR',
            simple_logo: '1836_jr/DR.alt',
            name: 'Maatschappij tot Exploitie van de Staats-Spoorwegen',
            tokens: [],
            color: '#fff',
            text_color: '#000',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 99,
                description: '3 train limit',
              },
              {
                type: 'borrow_train',
                train_types: %w[8 D],
                description: 'May borrow a train when trainless*',
              },
            ],
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
