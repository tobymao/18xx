# frozen_string_literal: true

module Engine
  module Game
    module G18Tokaido
      module Entities
        COMPANIES = [
          {
            name: 'Kyoto Railway Company',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D8 while owned by a player.',
            sym: 'KRC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D8'] }],
            color: nil,
          },
          {
            name: 'Sasago Railway Tunnel',
            value: 40,
            revenue: 10,
            desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles by ¥20.',
            sym: 'SRT',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Fish Market',
            value: 60,
            revenue: 10,
            desc: 'The owning corporation may assign the Fish Market to any port location (C13, E3, F10, G1, or J10) ' \
                  'to add ¥10 to all routes it runs to this location until the end of the game. Pays no other revenue to ' \
                  'a corporation.',
            sym: 'FM',
            abilities: [
              { type: 'close', on_phase: 'never', owner_type: 'corporation' },
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C13 E3 F10 G1 J10],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'any',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Stationmaster Tama',
            value: 60,
            revenue: 10,
            desc: 'Provides an additional station marker (that costs ¥40 to place) to corporation that buys this private ' \
                  'from a player, awarded at time of purchase.  Closes when purchased by a corporation.',
            sym: 'SMT',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Sleeper Train',
            value: 80,
            revenue: 15,
            desc: 'Adds ¥10 per city (not town, port, or connection) visited by any one train of the owning ' \
                  'corporation. Pays no other revenue to a corporation. Never closes once purchased by a corporation.',
            sym: 'ST',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'YSL',
            name: 'Yokohama-Shinbashi Line',
            logo: '18_tokaido/YSL',
            simple_logo: '18_tokaido/YSL.alt',
            tokens: [0, 40],
            coordinates: 'I9',
            color: '#d81e3e',
            text_color: 'white',
          },
          {
            float_percent: 60,
            sym: 'SRC',
            name: "San'yo Railway Co.",
            logo: '18_tokaido/SRC',
            simple_logo: '18_tokaido/SRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'B12',
            color: '#7b352a',
            text_color: 'white',
          },
          {
            float_percent: 60,
            sym: 'KAN',
            name: 'Kansai Railway Co.',
            logo: '18_tokaido/KRC',
            simple_logo: '18_tokaido/KRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'C11',
            city: 1,
            color: '#237333',
            text_color: 'white',
          },
          {
            float_percent: 60,
            sym: 'ARC',
            name: 'Aichi Railway Co.',
            logo: '18_tokaido/ARC',
            simple_logo: '18_tokaido/ARC.alt',
            tokens: [0, 40],
            coordinates: 'F8',
            color: '#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'NRC',
            name: 'Nippon Railway Co.',
            logo: '18_tokaido/NRC',
            simple_logo: '18_tokaido/NRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'J8',
            city: 1,
            color: 'black',
            text_color: 'white',
          },
          {
            float_percent: 60,
            sym: 'SHI',
            name: 'Shinano Railway Co.',
            logo: '18_tokaido/SHI',
            simple_logo: '18_tokaido/SHI.alt',
            tokens: [0, 40, 60],
            coordinates: 'J2',
            color: '#0189d1',
            text_color: 'white',
          },
          {
            float_percent: 60,
            sym: 'NAN',
            name: 'Nanao Railway Co.',
            logo: '18_tokaido/NAN',
            simple_logo: '18_tokaido/NAN.alt',
            tokens: [0, 40, 60],
            coordinates: 'F4',
            color: '#a2dced',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
