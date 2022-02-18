# frozen_string_literal: true

module Engine
  module Game
    module G18MO
      module Entities
        COMPANIES = [
         {
           name: 'Hannibal & St. Joseph Railroad',
           value: 60,
           discount: -80,
           revenue: 0,
           desc: 'Starts with $60 in treasury, a 2 train, and a token in Hannibal (H6). In ORs, '\
                 'this is the first minor to operate. Splits revenue evenly with owner. Buyer '\
                 'pays an extra $80 ("debt").',
           sym: 'HSJ',
           color: nil,
         },
         {
           name: 'St. Louis, Salem and Little Rock',
           value: 40,
           discount: -60,
           revenue: 0,
           desc: 'Starts with $40 in treasury, a 2 train, and a token in Salem (H12). In '\
                 'ORs, this is the second minor to operate. Splits revenue evenly with owner. '\
                 'Buyer pays an extra $60 ("debt").',
           sym: 'SSL',
           color: nil,
         },
         {
           name: 'Mail Contract',
           value: 60,
           revenue: 0,
           desc: 'Adds $10 per location visited by any one train of the owning corporation. Never '\
                 'closes once purchased by a corporation.',
           sym: 'MAIL',
           abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
           color: nil,
         },
         {
           name: 'Pool Share',
           value: 80,
           revenue: 10,
           desc: 'Player may exchange for a share in the bank pool.',
           sym: 'PS',
           abilities: [{
             type: 'exchange',
             corporations: 'any',
             owner_type: 'player',
             from: %w[market],
           }],
           color: nil,
         },
         {
           name: 'Extra Yellow Tile',
           value: 40,
           revenue: 15,
           desc: 'Lay an extra yellow tile for free one time.',
           sym: 'EXY',
           abilities: [{
             type: 'tile_lay',
             owner_type: 'corporation',
             count: 1,
             free: true,
             special: false,
             reachable: true,
             hexes: [],
             tiles: [],
             when: %w[track owning_corp_or_turn],
           }],
           color: nil,
         },
         {
           name: 'Extra Green Tile',
           value: 40,
           revenue: 15,
           desc: 'May lay an extra green tile on a connected (non-StL) city for free (including terrain) one time.',
           sym: 'EXG',
           color: nil,
           abilities: [{
             type: 'tile_lay',
             when: %w[track owning_corp_or_turn],
             owner_type: 'corporation',
             free: true,
             reachable: true,
             hexes: %w[],
             tiles: %w[14 15 619 294 295 296 298],
             special: false,
             count: 1,
           }],
         },
         {
           name: 'Revenue Change',
           value: 50,
           revenue: 5,
           desc: 'Revenue increases to 20 when owned by a corporation.',
           sym: 'RC',
           abilities: [{ type: 'revenue_change', revenue: 20, when: 'sold' }],
           color: nil,
         },
         {
           name: 'Half-Price Token',
           value: 40,
           revenue: 15,
           desc: 'Owning corporation may place a token for half price. (do not use this to teleport)',
           sym: 'HPTOK',
           color: nil,
           abilities: [{
             type: 'token',
             owner_type: 'corporation',
             hexes: [],
             discount: 0.5,
             count: 1,
             from_owner: true,
           }],
         },
         {
           name: 'Tunnel Blasting Company',
           value: 40,
           revenue: 10,
           desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles by $20.',
           sym: 'TBC',
           abilities: [{
             type: 'tile_discount',
             discount: 20,
             terrain: 'mountain',
             owner_type: 'corporation',
           }],
           color: nil,
         },
         {
           name: 'Ranch Tile',
           value: 50,
           revenue: 15,
           desc: 'May lay the X1 ranch tile on any empty plain hex adjacent to a Z lettered city.',
           sym: 'RT',
           abilities: [
          {
            type: 'tile_lay',
            when: %w[owning_corp_or_turn],
            hexes: %w[B6 B8 C9 D6 C9 D12 D14 E11 F8 F10 F12 F14 G11 H8],
            tiles: ['X1'],
            owner_type: 'corporation',
            count: 1,
          },
        ],
           color: nil,
         },
         {
           name: 'Train Discount',
           value: 40,
           revenue: 15,
           desc: 'Receive a $60 discount on a new train. Closes after use.',
           sym: 'TD',
           abilities: [
          {
            type: 'train_discount',
            discount: 60,
            owner_type: 'corporation',
            trains: %w[2Y 3Y 3G 4G 3E 5 6],
            count: 1,
            closed_when_used_up: true,
            when: 'buying_train',
          },
          ],
           color: nil,
         },
         {
           name: 'Mountain Construction Company',
           value: 60,
           revenue: 0,
           desc: 'Owner receives $20 whenever a tile is laid on a mountain hex. Never closes.',
           sym: 'MCC',
           abilities: [
                      { type: 'tile_income', income: 20, terrain: 'mountain' },
                      { type: 'close', on_phase: 'never', owner_type: 'corporation' },
        ],
           color: nil,

         },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'ATSF',
            name: 'Atchison, Topeka and Santa Fe Railway',
            logo: '18_mo/ATSF',
            simple_logo: '18_mo/ATSF.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Quincy (H4) token',
                desc_detail: 'May place token in Quincy (H4) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['H4'],
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
            color: 'blue',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'CBQ',
            name: 'Chicago, Burlington and Quincy Railroad',
            logo: '18_mo/CBQ',
            simple_logo: '18_mo/CBQ.alt',
            tokens: [0, 80, 80, 80],
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
            color: 'gray',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MKT',
            name: 'Missouri–Kansas–Texas Railroad',
            logo: '18_mo/MKT',
            simple_logo: '18_mo/MKT.alt',
            tokens: [0, 80, 80, 80],
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
            coordinates: 'C13',
            color: 'green',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MP',
            name: 'Missouri Pacific Railroad',
            logo: '18_mo/MP',
            simple_logo: '18_mo/MP.alt',
            tokens: [0, 80, 80, 80],
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
            color: 'purple',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'RI',
            name: 'Chicago, Rock Island & Pacific Railroad',
            logo: '18_mo/RI',
            simple_logo: '18_mo/RI.alt',
            tokens: [0, 80, 80, 80],
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
            color: 'brown',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SLSF',
            name: 'St. Louis–San Francisco Railway',
            logo: '18_mo/SLSF',
            simple_logo: '18_mo/SLSF.alt',
            tokens: [0, 80, 80, 80],
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
            color: 'red',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SSW',
            name: 'St. Louis Southwestern Railway',
            logo: '18_mo/SSW',
            simple_logo: '18_mo/SSW.alt',
            tokens: [0, 80, 80, 80],
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
            color: 'darkblue',
            always_market_price: true,
            reservation_color: nil,

          },
        ].freeze

        MINORS = [
          {
            sym: 'HSJ',
            name: 'Hannibal and St. Joseph Railroad',
            logo: '18_mo/HSJ',
            tokens: [0],
            coordinates: 'H6',
            color: 'pink',
            text_color: 'black',
          },
          {
            sym: 'SSL',
            name: 'St. Louis, Salem and Little Rock',
            logo: '18_mo/SSL',
            tokens: [0],
            coordinates: 'H12',
            color: 'cyan',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
