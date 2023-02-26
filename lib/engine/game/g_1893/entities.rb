# frozen_string_literal: true

module Engine
  module Game
    module G1893
      module Entities
        CORPORATIONS = [
          {
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            name: 'Dürener Eisenbahn',
            sym: 'DE',
            tokens: [0, 40, 100],
            type: 'corporation',
            logo: '1893/DE',
            simple_logo: '1893/DE.alt',
            color: :blue,
            coordinates: 'O2',
            reservation_color: nil,
          },
          {
            name: 'Rhein-Sieg Eisenbahn',
            sym: 'RSE',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            tokens: [0, 40, 100],
            type: 'corporation',
            logo: '1893/RSE',
            simple_logo: '1893/RSE.alt',
            color: :pink,
            text_color: 'black',
            coordinates: 'R7',
            reservation_color: nil,
          },
          {
            name: 'Rheinbahn AG',
            sym: 'RAG',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            tokens: [0, 40, 100],
            type: 'corporation',
            color: '#B3B3B3',
            logo: '1893/RAG',
            simple_logo: '1893/RAG.alt',
            text_color: 'black',
            coordinates: 'D5',
            reservation_color: nil,
          },
          {
            name: 'AG für Verkehrswesen',
            sym: 'AGV',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            floatable: false,
            tokens: [0, 0, 0, 100, 100],
            type: 'corporation',
            shares: [20, 10, 20, 10, 10, 10, 10, 10],
            logo: '1893/AGV',
            simple_logo: '1893/AGV.alt',
            color: :green,
            text_color: 'black',
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 4',
                desc_detail: 'During phase 4 it is possible to buy its shares from the market for 120M. '\
                             'During each MR in phase 4 the share holders and owners of minor 1 (20%), 3 (10%) and 5 (20%), '\
                             'will vote if AGV should form. If 50% vote yes, AGV will float, otherwise voting is repeated each '\
                             'MR until Phase 5 when AGV float automatically during the first MR.',
              },
            ],
            reservation_color: nil,
          },
          {
            name: 'Häfen und Güterverkehr Köln AG',
            sym: 'HGK',
            float_percent: 50,
            float_excludes_market: true,
            always_market_price: true,
            floatable: false,
            tokens: [0, 0, 0, 100, 100],
            type: 'corporation',
            shares: [20, 10, 20, 10, 10, 10, 10, 10],
            logo: '1893/HGK',
            simple_logo: '1893/HGK.alt',
            color: :red,
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 5',
                desc_detail: 'During phase 5 it is possible to buy its shares from the market for 120M. '\
                             'During each MR in phase 4 the share holders and owners of minor 2 (20%), 4 (20%) and '\
                             'HdSK (10%), will vote if HGK should form. If 50% vote yes, HGK will float, otherwise '\
                             'voting is repeated each MR until Phase 6 when HGK float automatically during the first MR.',
              },
            ],
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
            {
              sym: 'EKB',
              name: '1 Euskirchener Kreisbahn',
              type: 'minor',
              tokens: [0],
              logo: '1893/EKB',
              coordinates: 'T3',
              city: 0,
              color: :green,
              abilities: [
                {
                  type: 'base',
                  description: 'Becomes AGV\'s president certificate',
                  desc_detail: 'During merge rounds in phase 4 this minor gives 20 votes on AGV formation. '\
                               'When AGV form this minor is exchanged for a 20% president certificate in AGV, '\
                               'while the treasury, token and train(s) of the minor are merged into AGV.',
                },
              ],
            },
            {
              sym: 'KFBE',
              name: '2 Köln-Frechen-Benzelrather E',
              type: 'minor',
              tokens: [0],
              logo: '1893/KFBE',
              coordinates: 'L3',
              city: 0,
              color: :red,
            },
            {
              sym: 'KSZ',
              name: '3 Kleinbahn Siegburg-Zündorf',
              type: 'minor',
              tokens: [0],
              logo: '1893/KSZ',
              coordinates: 'P7',
              city: 0,
              color: :green,
            },
            {
              sym: 'KBE',
              name: '4 Köln-Bonner Eisenbahn',
              type: 'minor',
              tokens: [0],
              logo: '1893/KBE',
              coordinates: 'O4',
              city: 0,
              color: :red,
            },
            {
              sym: 'BKB',
              name: '5 Bergheimer Kreisbahn',
              type: 'minor',
              tokens: [0],
              logo: '1893/BKB',
              coordinates: 'I2',
              city: 0,
              color: :green,
            },
          ].freeze

        COMPANIES = [
          {
            sym: 'FdSD',
            name: 'Fond der Stadt Düsseldorf',
            value: 180,
            revenue: 20,
            desc: 'May be exchanged against 20% shares of the Rheinbahn AG in an SR (except the first one). '\
                  'If less than 20% remains in the market the exchange will be what remains. May also be exchanged '\
                  'to par RAG in which case the private is exchanged for the 20% presidency share. '\
                  'FdSD is closed either due to the exchange or if FdSD has not been exchanged to do an exchange '\
                  'after the first SR of phase 5. An exchange is handled as a Buy action. This private '\
                  'cannot be sold.',
            abilities: [
              {
                type: 'no_buy',
                owner_type: 'player',
              },
              {
                type: 'exchange',
                corporations: ['RAG'],
                owner_type: 'player',
                when: 'owning_player_sr_turn',
                from: %w[market],
              },
            ],
          },
          {
            sym: 'EVA',
            name: 'EVA (Eisenbahnverkehrsmittel Aktiengesellschaft)',
            value: 150,
            revenue: 30,
            desc: 'Leaves the game after the purchase of the first 6-train. This private cannot be sold to '\
                  'any corporation.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'HdSK',
            name: 'Häfen der Stadt Köln',
            value: 100,
            revenue: 10,
            desc: 'Exchange against 10% certificate of HGK. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'EKB',
            name: 'Minor 1 Euskirchener Kreisbahn',
            value: 210,
            revenue: 0,
            desc: "Owner controls Minor 1 (EKB), and the price paid makes up the Minor's starting treasury. "\
                  "The EKB private company and Minor are exchanged into the 20% president's certificate of AGV "\
                  'when AGV is formed. The EKB private company and Minor corporation cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'KFBE',
            name: 'Minor 2 Köln-Frechen-Benzelrather Eisenbahn',
            value: 200,
            desc: "Owner controls Minor 2 (KFBE), and the price paid makes up the Minor's starting treasury. "\
                  'The KFBE private company Minor and are exchanged into the 20% certificate of HGK '\
                  'when HGK is formed. The KFBE private company and Minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'KSZ',
            name: 'Minor 3 Kleinbahn Siegburg-Zündorf',
            value: 100,
            desc: "Owner controls Minor 3 (KSZ), and the price paid makes up the Minor's starting treasury. "\
                  'The KSZ private company and Minor are exchanged into a 10% certificate of AGV '\
                  'when AGV is formed. The KSZ private company and Minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'KBE',
            name: 'Minor 4 Köln-Bonner Eisenbahn',
            value: 220,
            desc: "Owner controls Minor 4 (KBE), and the price paid makes up the Minor's starting treasury. "\
                  "The KBE private company and Minor are exchanged into the 20% president's certificate of HGK "\
                  'when HGK is formed. The KBE private company and Minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'BKB',
            name: 'Minor 5 Bergheimer Kreisbahn',
            value: 180,
            desc: "Owner controls Minor 5 (BKB), and the price paid makes up the Minor's starting treasury. "\
                  'The BKB private company and Minor are exchanged into a 20% certificate of AGV '\
                  'when AGV is formed. The BKB private company and Minor cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
        ].freeze
      end
    end
  end
end
