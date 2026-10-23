# frozen_string_literal: true

module Engine
  module Game
    module GFrost1831
      module Entities
        COMPANIES = [
          {
            name: 'Diggers',
            value: 20,
            revenue: 5,
            desc: 'Blocks I4 while owned by player. When purchased by a Corporation, it must immediately '\
                  'place an additional yellow tile on I4, at no cost and without connection requirement.',
            sym: 'PDI',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I4'] },
                        {
                          type: 'tile_lay',
                          hexes: ['I4'],
                          tiles: %w[7 8 9],
                          when: 'sold',
                          owner_type: 'corporation',
                          free: true,
                          special: true,
                        }],
            color: nil,
          },
          {
            name: 'Explorers',
            value: 40,
            revenue: 10,
            desc: 'Blocks I10, J7 and K10 while owned by player. When purchased by a Corporation, it must '\
                  'immediately place an additional yellow tile on I10, J7 or K10, at no cost and without '\
                  'connection requirement.',
            sym: 'PEX',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[I10 J7 K10] },
                        {
                          type: 'tile_lay',
                          hexes: %w[I10 J7 K10],
                          tiles: %w[7 8 9],
                          when: 'sold',
                          owner_type: 'corporation',
                          free: true,
                          special: true,
                        }],
            color: nil,
          },
          {
            name: 'Convoy',
            value: 60,
            revenue: 15,
            desc: 'The player gains 1 Influence and may, at any point during the game, allocate it to a '\
                  'Corporation or Faction where the player is President, without moving the Government Marker.',
            sym: 'PCO',
            abilities: [],
            color: nil,
          },
          {
            name: 'Affiliate',
            value: 80,
            revenue: 20,
            desc: 'May be exchanged, during a Stock Round, for a Faction certificate of the player\'s choice. '\
                  'The exchange counts as an extra action, respecting certificate limits and the Opposition Rule.',
            sym: 'PAF',
            abilities: [
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'stock_round',
                choices: %w[exchange_faction],
              },
            ],
            color: nil,
          },
          {
            name: 'Old Guard',
            value: 90,
            revenue: 20,
            desc: 'Grants 1 certificate of Old England Corp. '\
                  'Blocks C6 and E6 while owned by player.',
            sym: 'POG',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[C6 E6] },
                        { type: 'shares', shares: 'OE_1' }],
            color: nil,
          },
          {
            name: 'Grand Junction',
            value: 0,
            revenue: 10,
            desc: 'Grants the President\'s certificate of New Grand Junction. '\
                  'Set and pay the Initial Offering value immediately. '\
                  'This Private Company cannot be purchased by a Corporation.',
            sym: 'PGJ',
            abilities: [{ type: 'shares', shares: 'GJ_0' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'CM',
            name: 'Southern Coal Mine',
            logo: 'frost_1831/CM',
            simple_logo: 'frost_1831/CM.alt',
            tokens: [0, 40, 100],
            coordinates: 'G14',
            color: '#3f3b39',
          },
          {
            float_percent: 50,
            sym: 'DL',
            name: 'Dead Lake Venture',
            logo: 'frost_1831/DL',
            simple_logo: 'frost_1831/DL.alt',
            tokens: [0, 40, 100],
            coordinates: 'F9',
            color: '#4582c0',
          },
          {
            float_percent: 50,
            sym: 'EC',
            name: 'East County Railroad',
            logo: 'frost_1831/EC',
            simple_logo: 'frost_1831/EC.alt',
            tokens: [0, 40, 100],
            coordinates: 'M10',
            color: '#1e493d',
          },
          {
            float_percent: 50,
            sym: 'GJ',
            name: 'New Grand Junction',
            logo: 'frost_1831/GJ',
            simple_logo: 'frost_1831/GJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'M6',
            color: '#7c72ad',
          },
          {
            float_percent: 50,
            sym: 'HF',
            name: 'Hunting & Farming Company',
            logo: 'frost_1831/HF',
            simple_logo: 'frost_1831/HF.alt',
            tokens: [0, 40, 100],
            coordinates: 'L15',
            color: '#6e903d',
          },
          {
            float_percent: 50,
            sym: 'OE',
            name: 'Old England Corp',
            logo: 'frost_1831/OE',
            simple_logo: 'frost_1831/OE.alt',
            tokens: [0, 40, 100],
            coordinates: 'D3',
            color: '#284861',
          },
          {
            float_percent: 50,
            sym: 'SP',
            name: "Snow Pilgrims' Railway",
            logo: 'frost_1831/SP',
            simple_logo: 'frost_1831/SP.alt',
            tokens: [0, 40, 100],
            coordinates: 'D15',
            color: '#918d8b',
          },
          {
            float_percent: 50,
            sym: 'TV',
            name: 'Twin Villages Guild',
            logo: 'frost_1831/TV',
            simple_logo: 'frost_1831/TV.alt',
            tokens: [0, 40, 100],
            coordinates: 'I12',
            color: '#914b76',
          },

        ].freeze
      end
    end
  end
end
