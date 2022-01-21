# frozen_string_literal: true

module Engine
  module Game
    module G18MO
      module Entities
        COMPANIES = [
             {
               name: 'Michigan Southern',
               value: 60,
               discount: -80,
               revenue: 0,
               desc: 'Starts with $60 in treasury, a 2 train, and a token in Detroit (C15). In ORs, '\
                     'this is the first minor to operate. Splits revenue evenly with owner. Buyer '\
                     'pays an extra $80 ("debt").',
               sym: 'MS',
               color: nil,
             },
             {
               name: 'Big 4',
               value: 40,
               discount: -60,
               revenue: 0,
               desc: 'Starts with $40 in treasury, a 2 train, and a token in Indianapolis (G9). In '\
                     'ORs, this is the second minor to operate. Splits revenue evenly with owner. '\
                     'Buyer pays an extra $60 ("debt").',
               sym: 'BIG4',
               color: nil,
             },
             {
               name: 'Mail Contract',
               value: 80,
               revenue: 0,
               desc: 'Adds $10 per location visited by any one train of the owning corporation. Never '\
                     'closes once purchased by a corporation.',
               sym: 'MAIL',
               abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
               color: nil,
             },
             {
               name: 'Misc Token',
               value: 60,
               revenue: 20,
               desc: 'None.',
               sym: 'TOK',
               abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
               color: nil,
             },
             {
               name: 'Tunnel Blasting Company',
               value: 60,
               revenue: 20,
               desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles and '\
                     'tunnel/pass hexsides by $20.',
               sym: 'TBC',
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
               name: 'Steamboat Company',
               value: 40,
               revenue: 10,
               desc: 'At the beginning of each Operating Round, the owning player may assign the '\
                     'Steamboat Company to a corporation/minor and to a port location (J4, J8). '\
                     'Once per Operating Round, the owning corporation may assign the '\
                     'Steamboat Company to a port location. Add $20 per port symbol to all routes run '\
                     'to the assigned location by the owning/assigned corporation/minor.',
               sym: 'SC',
               abilities: [
                 {
                   type: 'assign_hexes',
                   hexes: %w[J4 J8],
                   count_per_or: 1,
                   when: 'or_start',
                   owner_type: 'player',
                 },
                 {
                   type: 'assign_corporation',
                   count_per_or: 1,
                   when: 'or_start',
                   owner_type: 'player',
                 },
                 {
                   type: 'assign_hexes',
                   when: 'owning_corp_or_turn',
                   hexes: %w[J4 J8],
                   count_per_or: 1,
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
               name: 'Misc Bonus Token A',
               value: 40,
               revenue: 15,
               desc: 'None.',
               sym: 'TKNA',
               color: nil,
             },
             {
               name: 'Misc Bonus Token B',
               value: 40,
               revenue: 15,
               desc: 'None.',
               sym: 'TKNB',
               color: nil,
             },
             {
               name: 'Misc Track A',
               value: 40,
               revenue: 15,
               desc: 'None.',
               sym: 'TKA',
               color: nil,
             },
             {
               name: 'Misc Track B',
               value: 40,
               revenue: 15,
               desc: 'None.',
               sym: 'TKB',
               color: nil,
             },
             {
               name: 'Misc Track C',
               value: 40,
               revenue: 15,
               desc: 'None.',
               sym: 'TKC',
               color: nil,
             },
             {
               name: 'Misc Track D',
               value: 40,
               revenue: 15,
               desc: 'None.',
               sym: 'TKD',
               color: nil,

             },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'ATSF',
            name: 'Atchison, Topeka and Santa Fe Railway',
            logo: '18_mo/ATSF',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Quincy (H4) token',
                desc_detail: 'May place token in Quincy (H4) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['H12'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'H4',
                remove: 'IV',
              },
            ],
            coordinates: 'A7',
            color: :blue,
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'CBQ',
            name: 'Chicago, Burlington and Quincy Railroad',
            logo: '18_mo/CBQ',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Kansas City (C7) token',
                desc_detail: 'May place token in Kansas City (C7) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['C7'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'C7',
                remove: 'IV',
              },
            ],
            coordinates: 'J4',
            color: :gray,
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MKT',
            name: 'Missouri–Kansas–Texas Railroad',
            logo: '18_mo/MKT',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Sedalia (E9) token',
                desc_detail: 'May place token in Sedalia (E9) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['E9'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'E9',
                remove: 'IV',
              },
            ],
            coordinates: 'B14',
            color: :green,
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MP',
            name: 'Missouri Pacific Railroad',
            logo: '18_mo/MP',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Pleasant Hill (D8) token',
                desc_detail: 'May place token in Pleasant Hill (D8) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['D8'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'D8',
                remove: 'IV',
              },
            ],
            coordinates: 'J8',
            city: 2,
            color: :purple,
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'RI',
            name: 'Chicago, Rock Island & Pacific Railroad',
            logo: '18_mo/RI',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Kansas City (C7) token',
                desc_detail: 'May place token in Kansas City (C7) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['C7'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'C7',
                remove: 'IV',
              },
            ],
            coordinates: 'K5',
            color: :brown,
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SLSF',
            name: 'St. Louis–San Francisco Railway',
            logo: '18_mo/SLSF',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Springfield (E13) token',
                desc_detail: 'May place token in Springfield (E13) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['E13'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'E13',
                remove: 'IV',
              },
            ],
            coordinates: 'J8',
            city: 1,
            color: :red,
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SSW',
            name: 'St. Louis Southwestern Railway',
            logo: '18_mo/SSW',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 St. Louis (J8) token',
                desc_detail: 'May place token in St. Louis (J8) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['J8'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'J8',
                remove: 'IV',
              },
            ],
            coordinates: 'J14',
            city: 0,
            color: :darkblue,
            always_market_price: true,
            reservation_color: nil,

          },
        ].freeze

        MINORS = [
          {
            sym: 'MS',
            name: 'Michigan Southern',
            logo: '1846/MS',
            simple_logo: '1846/MS.alt',
            tokens: [0],
            coordinates: 'F4',
            color: :pink,
            text_color: 'black',
          },
          {
            sym: 'BIG4',
            name: 'Big 4',
            logo: '1846/B4',
            simple_logo: '1846/B4.alt',
            tokens: [0],
            coordinates: 'F12',
            color: :cyan,
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
