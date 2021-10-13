# frozen_string_literal: true

module Engine
  module Game
    module G18Tokaido
      module Entities
        COMPANIES = [
          {
            name: 'Kyoto-tetsudo',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D10 while owned by a player.',
            sym: 'KT',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D10'] }],
            color: nil,
          },
          {
            name: 'Osakayama Tunnel',
            value: 40,
            revenue: 10,
            desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles by ¥20.',
            sym: 'OT',
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
            desc: 'The owning corporation may assign the Fish Market to any port location (C15, E5, F12, G3, or J12) ' \
                  'to add ¥20 to all routes it runs to this location until the end of the game. Pays no other revenue to ' \
                  'a corporation.',
            sym: 'FM',
            abilities: [
              { type: 'close', on_phase: 'never', owner_type: 'corporation' },
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C15 E5 F12 G3 J12],
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
            desc: 'Provides an additional free station marker (that costs ¥0 to place) to corporation that buys this private ' \
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
            revenue: 0,
            desc: 'Adds ¥10 per city (not town, port, or connection) visited by any one train of the owning ' \
                  'corporation. Never closes once purchased by a corporation.',
            sym: 'ST',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Inoue Masaru',
            value: 100,
            revenue: 0,
            desc: 'Purchasing player immediately takes a 10% share of the JGR. This does not close the private ' \
                  'company. This private company has no other special ability.',
            sym: 'IM',
            abilities: [{ type: 'shares', shares: 'JGR_1' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'SRC',
            name: "San'yo-tetsudo",
            logo: '18_tokaido/SRC',
            simple_logo: '18_tokaido/SRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'B14',
            color: '#ef8f2f',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'KRC',
            name: 'Kansai-tetsudo',
            logo: '18_tokaido/KRC',
            simple_logo: '18_tokaido/KRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'C13',
            city: 1,
            color: '#2f7f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'ARC',
            name: 'Aichi-tetsudo',
            logo: '18_tokaido/ARC',
            simple_logo: '18_tokaido/ARC.alt',
            tokens: [0, 40],
            coordinates: 'F10',
            color: '#2f2f9f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'JGR',
            name: 'Tetsudo-sho',
            logo: '18_tokaido/JGR',
            simple_logo: '18_tokaido/JGR.alt',
            tokens: [0, 40],
            coordinates: 'I11',
            color: '#ef2f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'NRC',
            name: 'Nippon-tetsudo',
            logo: '18_tokaido/NRC',
            simple_logo: '18_tokaido/NRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'J10',
            city: 1,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SR',
            name: 'Shinano-tetsudo',
            logo: '18_tokaido/SR',
            simple_logo: '18_tokaido/SR.alt',
            tokens: [0, 40, 60],
            coordinates: 'J4',
            color: '#efef4f',
            text_color: 'black',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
