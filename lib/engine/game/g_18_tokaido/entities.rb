# frozen_string_literal: true

module Engine
  module Game
    module G18Tokaido
      module Entities
        COMPANIES = [
          {
            name: 'Kyoto Railway Co.',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D8 while owned by a player.',
            sym: 'KT',
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
          {
            name: 'Inoue Masaru',
            value: 100,
            revenue: 0,
            desc: 'Purchasing player immediately takes a 10% share of the YSL. This does not close the private ' \
                  'company. This private company has no other special ability.',
            sym: 'IM',
            abilities: [{ type: 'shares', shares: 'YSL_1' }],
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
            color: '#ef2f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SRC',
            name: "San'yo Railway Co.",
            logo: '18_tokaido/SRC',
            simple_logo: '18_tokaido/SRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'B12',
            color: '#ef8f2f',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'KRC',
            name: 'Kansai Railway Co.',
            logo: '18_tokaido/KRC',
            simple_logo: '18_tokaido/KRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'C11',
            city: 1,
            color: '#2f7f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'ARC',
            name: 'Aichi Railway Co.',
            logo: '18_tokaido/ARC',
            simple_logo: '18_tokaido/ARC.alt',
            tokens: [0, 40],
            coordinates: 'F8',
            color: '#2f2f9f',
            text_color: 'white',
            reservation_color: nil,
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
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SHI',
            name: 'Shinano Railway Co.',
            logo: '18_tokaido/SHI',
            simple_logo: '18_tokaido/SHI.alt',
            tokens: [0, 40, 60],
            coordinates: 'J2',
            color: '#efef4f',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'NAN',
            name: 'Nanao Railway Co.',
            logo: '18_tokaido/NAN',
            simple_logo: '18_tokaido/NAN.alt',
            tokens: [0, 40, 60],
            coordinates: 'F4',
            color: '#7f9f9f',
            text_color: 'white',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
