# frozen_string_literal: true

module Engine
  module Game
    module G1849
      module Entities
        COMPANIES = [
          {
            name: 'Società Corriere Etnee',
            value: 20,
            revenue: 5,
            desc: 'Blocks Acireale (G13) while owned by a player.',
            sym: 'SCE',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['G13'] }],
            color: nil,
          },
          {
            name: 'Studio di Ingegneria Giuseppe Incorpora',
            value: 45,
            revenue: 10,
            desc: 'During its operating turn, the owning corporation can lay or '\
                  'upgrade standard gauge track on mountain, hill or rough hexes '\
                  'at half cost. Narrow gauge track is still at normal cost.',
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
                hexes: %w[A5 a12 L14 N8],
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
                  'this private company in lieu of performing both its tile and '\
                  'token placement steps. Performing this action allows the '\
                  'corporation to select any coastal city hex (all cities '\
                  'except Caltanisetta and Ragusa), optionally lay or upgrade '\
                  'a tile there, and optionally place a station token there. '\
                  'This power may be used even if the corporation is unable to '\
                  'trace a route to that city, but all other normal tile '\
                  'placement and station token placement rules apply.',
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
            sym: 'AFG',
            name: 'Azienda Ferroviaria Garibaldi',
            logo: '1849/AFG',
            simple_logo: '1849/AFG.alt',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            always_market_price: true,
            color: '#ff0000',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'ATA',
            name: 'Azienda Trasporti Archimede',
            logo: '1849/ATA',
            simple_logo: '1849/ATA.alt',
            token_fee: 30,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'M13',
            always_market_price: true,
            color: :green,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'CTL',
            name: 'Compagnia Trasporti Lilibeo',
            logo: '1849/CTL',
            simple_logo: '1849/CTL.alt',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'E1',
            always_market_price: true,
            color: '#f9b231',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'IFT',
            name: 'Impresa Ferroviaria Trinacria',
            logo: '1849/IFT',
            simple_logo: '1849/IFT.alt',
            token_fee: 90,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'H12',
            always_market_price: true,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'RCS',
            name: 'Rete Centrale Sicula',
            logo: '1849/RCS',
            simple_logo: '1849/RCS.alt',
            token_fee: 130,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'C5',
            always_market_price: true,
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SFA',
            name: 'Società Ferroviaria Akragas',
            logo: '1849/SFA',
            simple_logo: '1849/SFA.alt',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'J6',
            always_market_price: true,
            color: :pink,
            text_color: 'black',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
