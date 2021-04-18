# frozen_string_literal: true

module Engine
  module Game
    module G1849Boot
      module Entities
        COMPANIES = [
          {
            name: 'Società Corriere',
            value: 20,
            revenue: 5,
            desc: 'Blocks Caserta (F8) while owned by a player.',
            sym: 'SCE',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F8'] }],
            color: nil,
          },
          {
            name: 'Studio di Ingegneria Giuseppe Incorpora',
            value: 45,
            revenue: 10,
            desc: 'During its operating turn, the owning corporation can lay '\
                  'or upgrade standard gauge track on mountain, hill or rough '\
                  'hexes at half cost. Narrow gauge track is still at normal cost.',
            sym: 'SIGI',
            abilities: [
              {
                type: 'tile_discount',
                discount: 'half',
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Compagnia Navale Mediterranea',
            value: 75,
            revenue: 15,
            desc: 'During its operating turn, the owning corporation may close '\
                  'this company to place the +L. 20 token on any port. The '\
                  'corporation that placed the token adds L. 20 to the revenue '\
                  'of the port for the rest of the game.',
            sym: 'CNM',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[B16 G5 J20 L16],
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
          {
            name: 'Società Marittima Siciliana',
            value: 110,
            revenue: 20,
            desc: 'During its operating turn, the owning corporation may close '\
                  'this private company in lieu of performing both its tile '\
                  'and token placement steps. Performing this action allows '\
                  'the corporation to select any coastal city hex (all cities '\
                  'except Foggia, Campobasso, and Potenza), optionally lay or '\
                  'upgrade a tile there, and optionally place a station token '\
                  'there. This power may be used even if the corporation is '\
                  'unable to trace a route to that city, but all other normal '\
                  'tile placement and station token placement rules apply.',
            sym: 'SMS',
            abilities: [
              {
                type: 'description',
                description: 'Lay/upgrade and/or teleport on any coastal city',
              },
            ],
            color: nil,
          },
          {
            name: "Reale Società d'Affari",
            value: 150,
            revenue: 25,
            desc: 'Cannot be bought by a corporation. This private closes when '\
                  'the associated corporation buys its first train. If the '\
                  'associated corporation closes before buying a train, this '\
                  'private remains open until all private companies are closed '\
                  'at the start of Phase 12.',
            sym: 'RSA',
            abilities: [{ type: 'shares', shares: 'first_president' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'SFR',
            name: 'Società per le Strade Ferrate Romane',
            logo: '1849_boot/SFR',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            always_market_price: true,
            color: '#ff0000',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SFCS',
            name: 'Società per le Strade Ferrate Calabro-Sicule',
            logo: '1849_boot/SFCS',
            token_fee: 30,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'O9',
            always_market_price: true,
            color: :green,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'AL',
            name: 'Società Adami e Lemmi',
            logo: '1849_boot/AL',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'N20',
            always_market_price: true,
            color: '#f9b231',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SFM',
            name: 'Società Italiana per le Strade Ferrate Meridionali',
            logo: '1849_boot/SFM',
            token_fee: 90,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'B14',
            always_market_price: true,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'IFP',
            name: 'Impresa Ferroviaria di Pietrarsa',
            logo: '1849_boot/IFP',
            token_fee: 130,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'G7',
            always_market_price: true,
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PL',
            name: 'Società Anonima Pia Latina',
            logo: '1849_boot/PL',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'G15',
            always_market_price: true,
            color: :pink,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'FCU',
            name: 'Ferrovia Centrale Umbra',
            logo: '1849_boot/FCU',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'A9',
            always_market_price: true,
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'M&C',
            name: 'Società in Commandita E. Melisurgo & C.',
            logo: '1849_boot/MC',
            token_fee: 90,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'L18',
            always_market_price: true,
            color: '#000',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
