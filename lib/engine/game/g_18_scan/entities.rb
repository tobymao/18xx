# frozen_string_literal: true

module Engine
  module Game
    module G18Scan
      module Entities

        COMPANIES = [
          {
            sym: 'Ferry',
            name: 'Stockholm-Åbo Ferry Company',
            value: 120,
            revenue: 20,
            desc: 'Comes with two +20 bonus tokens. Tokens may be purchased by a Corporation for K20 to gain a +20 bonus to runs across the ferry on L7.',
            abilities: [
              { type: 'shares', shares: 'VR_1' },
              { type: 'close', when: 'tokens_sold' },
            ],
          },
          {
            sym: 'Mine',
            name: 'Lapland Ore Mine',
            value: 150,
            revenue: 25,
            desc: 'Comes with one +50 token. Token may be purchased by a Corporation for K50 to increase the value of one run to Kiruna (T1) by 50.',
          },
          {
            sym: 'SJS',
            name: 'Sjaellandske Jerbaneselskab (Zeeland Railway Company)',
            value: 180,
            revenue: 30,
            desc: 'Lays COP (C6) for free',
            abilities: [
              {
                type: 'tile_lay',
                discount: 40,
                owner_type: 'corporation',
                tiles: %w[403 121],
                hexes: ['C6'],
                count: 1,
                when: 'track',
              },
              { type: 'close', when: 'bought_train', corporation: 'DSB' },
              { type: 'no_buy' },
              { type: 'shares', shares: 'DSB_0' },
            ],
          },
          {
            sym: '1',
            name: 'Södra Stambanan (Southern Mainline)',
            value: 260,
            revenue: 0,
            desc: 'Owner takes control of minor corporation 1. Begins in Malmö (D7). This private cannot be sold. Destination: Göteborg (F5). When Phase 5 begins, the minor corporation closes, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: '2',
            name: 'Nordvästra Stambanan (Northwestern Mainline)',
            value: 220,
            revenue: 0,
            desc: 'Owner takes control of minor corporation 2. Begins in Northern Stockholm (K6). This private cannot be sold. Destination: Trondheim (K2). When Phase 5 begins, the minor corporation closes, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: '3',
            name: 'Västra Stambanan (Western Mainline)',
            value: 200,
            revenue: 0,
            desc: 'Owner takes control of minor corporation 3. Begins in Southwestern Stockholm (K6). This private cannot be sold. Destination: Oslo (G4). When Phase 5 begins, the minor corporation closes, but its owner receives a 10% share in SJ.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'DSB',
            name: 'Danske Statsbaner',
            # logo: '18_mex/CHI',
            # simple_logo: '18_mex/CHI.alt',
            tokens: [0, 40, 100],
            coordinates: 'C6',
            color: '#FF7F40',
          },
          {
            sym: 'S&NJ',
            name: 'Sveriges & Norges Järnvägar',
            # logo: '18_mex/NdM',
            # simple_logo: '18_mex/NdM.alt',
            tokens: [0, 40, 100],
            coordinates: 'S2',
            color: '#6AA84F',
          },
          {
            sym: 'NSB',
            name: 'Norges Statsbaner',
            # logo: '18_mex/MC',
            # simple_logo: '18_mex/MC.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G4',
            color: '#FF0000',
          },
          {
            sym: 'VR',
            name: 'Valtionrautatiet',
            # logo: '18_mex/FCP',
            # simple_logo: '18_mex/FCP.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'B3',
            color: '#00FFFF',
            text_color: 'black',
          },
          {
            sym: 'SJ',
            name: 'Statens Järnvägar',
            # logo: '18_mex/TM',
            # simple_logo: '18_mex/TM.alt',
            tokens: [0, 40, 100, 100, 100, 100],
            coordinates: 'I12',
            color: '#1155CC',
          },
        ].freeze

        MINORS = [
          {
            sym: '1',
            name: 'Södra Stambanan (Southern Mainline)',
            # logo: '18_mex/A',
            # simple_logo: '18_mex/A.alt',
            tokens: [0, 40],
            coordinates: 'D7',
            color: '#A4C2F4',
          },
          {
            sym: '2',
            name: 'Nordvästra Stambanan (Northwestern Mainline)',
            # logo: '18_mex/B',
            # simple_logo: '18_mex/B.alt',
            tokens: [0, 40],
            coordinates: 'K6',
            color: '#A4C2F4',
          },
          {
            sym: '3',
            name: 'Västra Stambanan (Western Mainline)',
            # logo: '18_mex/C',
            # simple_logo: '18_mex/C.alt',
            tokens: [0, 40],
            coordinates: 'K6',
            color: '#A4C2F4',
          },
        ].freeze
      end
    end
  end
end
