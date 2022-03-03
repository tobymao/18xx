# frozen_string_literal: true

module Engine
  module Game
    module G18JPT
      module Entities
        COMPANIES = [
          {
            name: 'Tokyo Horsecar',
            sym: 'TH',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
            color: nil,
          },
          {
            name: 'Teito Electric Railway',
            sym: 'TER',
            value: 40,
            revenue: 10,
            desc: 'The corporation owning the TER may place a green tile on Shimokitazawa (E87) in addition to its normal tile '\
                  'placement during its turn. A route to Shimokitazawa is not required. Blocks E87 while owned by player.',
            abilities: [
              { type: 'blocks_hexes', owner_type: 'player', hexes: ['E87'] },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                hexes: ['E87'],
                tiles: %w[14 611],
                when: 'owning_corp_or_turn',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Tokyo Metropolitan Government Bureau of Transportation',
            sym: 'TMGBT',
            value: 70,
            revenue: 15,
            desc: 'The corporation owning the TMGBT gets a subsidy of 50 yen from the bank to its treasury every time '\
                  'after it places green "T" tiles.',
            color: nil,
          },
          {
            name: 'Railway Regiments Exercise Line',
            sym: 'RRET',
            value: 110,
            revenue: 20,
            desc: 'The initial purchaser of the RRET immediately receives a 10% share of Keisei (Pink) without further payment.',
            abilities: [{ type: 'shares', shares: 'KER_1' }],
            color: nil,
          },
          {
            name: 'Kawagoe Railway',
            sym: 'KR',
            value: 160,
            revenue: 25,
            desc: 'The initial purchaser of the KR immediately receives a 10% share of Seibu (Yellow) without further payment. '\
                  'Tiles may not be placed on B82 and C83 if KR is owned by a player.',
            abilities: [
              { type: 'blocks_hexes', owner_type: 'player', hexes: %w[B82 C83] },
              { type: 'shares', shares: 'SER_1' },
            ],
            color: nil,
          },
          {
            name: 'Tojo Railway',
            sym: 'TR',
            value: 220,
            desc: 'The initial purchaser of the TR private company immediately exchanges it for '\
                  "President's certificate and a 10% share of the TR corporation without further payment.",
            abilities: [
              { type: 'close', when: 'par', corporation: 'TR' },
              { type: 'shares', shares: %w[TR_0 TR_1] },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'TR', # 東武
            name: 'Tobu Railway',
            logo: '18_jpt/TR',
            simple_logo: '18_jpt/TR.alt',
            tokens: [0, 0, 40, 100, 100],
            coordinates: 'A77',
            color: :grey,
            reservation_color: nil,
            abilities: [
              {
                type: 'assign_hexes',
                count: 1,
                hexes: ['H84'],
                description: 'Double tile lay if H84 was tokened',
                desc_detail: 'If Tobu places a token in Asakusa (H84), it may lay or upgrade a tile twice '\
                             'in each subsequent operating round. The same hex may be upgraded twice.',
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'SER', # 西武
            name: 'Seibu Railway',
            logo: '18_jpt/SER',
            simple_logo: '18_jpt/SER.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'F84',
            city: 0,
            color: :yellow,
            text_color: 'black',
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Tokorozawa (A81)',
                hexes: ['A81'],
              },
              {
                type: 'description',
                description: '¥100 subsidy after laying town tiles',
                desc_detail: 'Gets a subsidy of ¥100 from the bank to treasury whenever it places a tile with a town',
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'OER', # 小田急
            name: 'Odakyu Electric Railway',
            logo: '18_jpt/OER',
            simple_logo: '18_jpt/OER.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'F86',
            city: 0,
            color: :darkgreen,
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Odawara (A91)',
                hexes: ['A91'],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'KC', # 京王
            name: 'Keio Corporation',
            logo: '18_jpt/KC',
            simple_logo: '18_jpt/KC.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'F86',
            city: 0,
            color: :purple,
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Hachioji (A87)',
                hexes: ['A87'],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'TC', # 東急
            name: 'Tokyu Corporation',
            logo: '18_jpt/TC',
            simple_logo: '18_jpt/TC.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'F88',
            city: 0,
            color: :lightBlue,
            text_color: 'black',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Additional tile lays after laying town tiles',
                desc_detail: 'For each town tile it places, Tokyu may lay or upgrade one extra tile '\
                             'in the current operating round. Only one extra tile is received for a double town.',
              },
              {
                type: 'assign_hexes',
                count: 1,
                hexes: ['A93'],
                description: 'Buy trains at 20% discount if A93 tokened',
                desc_detail: 'If Tokyu places a token in Nagatsuda (A93), it may purchase trains from the bank '\
                             'or open market at a 20% discount.',
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'KEER', # 京急
            name: 'Keihin Electric Express Railway',
            logo: '18_jpt/KEER',
            simple_logo: '18_jpt/KEER.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'G89',
            city: 1,
            color: :red,
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from D98 and H92',
                desc_detail: 'Double income from Yokosuka (D98) and Haneda airport (H92)',
                hexes: %w[D98 H92],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'KER', # 京成
            name: 'Keisei Electric Railway',
            logo: '18_jpt/KER',
            simple_logo: '18_jpt/KER.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'H84',
            city: 1,
            color: :pink,
            text_color: 'black',
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Narita (L84)',
                hexes: ['L84'],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'TM', # 地下鉄
            name: 'Tokyo Metro',
            logo: '18_jpt/TM',
            simple_logo: '18_jpt/TM.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'G87',
            city: 0,
            color: :brown,
            reservation_color: nil,
            abilities: [
              {
                type: 'tile_discount',
                description: 'Place "T" tiles for free',
                desc_detail: 'Place green and brown "T" tiles without terrain costs',
                hexes: %w[F84 F86 F88 G85 G87 G89 H84],
                discount: 80,
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'SAR', # 相鉄
            name: 'Sagami Railway',
            logo: '18_jpt/SAR',
            simple_logo: '18_jpt/SAR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'D96',
            city: 0,
            color: :lightGreen,
            text_color: 'black',
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Yamato (A95)',
                hexes: ['A95'],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'TX',
            name: 'Tsukuba eXpress',
            logo: '18_jpt/TX',
            simple_logo: '18_jpt/TX.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'J78',
            color: :orange,
            text_color: 'black',
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Tsukuba (L76)',
                hexes: ['L76'],
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'HR', # 北総
            name: 'Hokuso Railway',
            logo: '18_jpt/HR',
            simple_logo: '18_jpt/HR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'I83',
            color: :darkBlue,
            reservation_color: nil,
            abilities: [
              {
                type: 'hex_bonus',
                amount: 0,
                description: 'Double income from Shiroi (L80)',
                hexes: ['L80'],
              },
            ],
          },
        ].freeze
      end
    end
  end
end
