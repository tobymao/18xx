# frozen_string_literal: true

module Engine
  module Game
    module G1846
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
            name: 'Chicago and Western Indiana',
            value: 60,
            revenue: 10,
            desc: 'Reserves a token slot in Chicago (D6), in the city next to E7. The owning '\
                  'corporation may place an extra token there at no cost, with no connection '\
                  'needed. Once this company is purchased by a corporation, the slot that was '\
                  'reserved may be used by other corporations.',
            sym: 'C&WI',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                hexes: ['D6'],
                city: 3,
                price: 0,
                teleport_price: 0,
                count: 1,
                extra_action: true,
              },
              { type: 'reservation', remove: 'sold', hex: 'D6', city: 3 },
            ],
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
            name: 'Meat Packing Company',
            value: 60,
            revenue: 15,
            desc: 'The owning corporation may assign the Meat Packing Company to either St. Louis ('\
                  'I1) or Chicago (D6), to add $30 to all routes it runs to this location.',
            sym: 'MPC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[I1 D6],
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
            name: 'Steamboat Company',
            value: 40,
            revenue: 10,
            desc: 'At the beginning of each Operating Round, the owning player may assign the '\
                  'Steamboat Company to a corporation/minor and to a port location (B8, C5, D14, '\
                  'G19, I1). Once per Operating Round, the owning corporation may assign the '\
                  'Steamboat Company to a port location. Add $20 per port symbol to all routes run '\
                  'to the assigned location by the owning/assigned corporation/minor.',
            sym: 'SC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[B8 C5 D14 I1 G19],
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
                when: %w[track_and_token route],
                hexes: %w[B8 C5 D14 I1 G19],
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
            name: 'Lake Shore Line',
            value: 40,
            revenue: 15,
            desc: 'The owning corporation may make an extra $0 cost tile upgrade of either '\
                  'Cleveland (E17) or Toledo (D14), but not both.',
            sym: 'LSL',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                free: true,
                hexes: %w[D14 E17],
                tiles: %w[14 15 619 294 295 296],
                special: false,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Michigan Central',
            value: 40,
            revenue: 15,
            desc: "The owning corporation may lay up to two extra $0 cost yellow tiles in the MC's "\
                  'reserved hexes (B10, B12). The owning corporation does not need to be connected to those hexes. '\
                  'If two tiles are laid, they must connect to each other.',
            sym: 'MC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[B10 B12] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          must_lay_together: true,
                          hexes: %w[B10 B12],
                          tiles: %w[7 8 9],
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Ohio & Indiana',
            value: 40,
            revenue: 15,
            desc: "The owning corporation may lay up to two extra $0 cost yellow tiles in the O&I's "\
                  'reserved hexes (F14, F16). The owning corporation does not need to be connected to those hexes. '\
                  'If two tiles are laid, they must connect to each other.',
            sym: 'O&I',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F14 F16] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          must_lay_together: true,
                          hexes: %w[F14 F16],
                          tiles: %w[7 8 9],
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Boomtown',
            sym: 'BT',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may place a $20 marker in Cincinnati (H12), to '\
                  'add $20 to all of its routes run to this location.',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[H12],
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
            name: 'Little Miami',
            sym: 'LM',
            value: 40,
            revenue: 15,
            desc: 'If no track exists from Cincinnati (H12) to Dayton (G13), the '\
                  'owning corporation may lay/upgrade one extra $0 cost tile in '\
                  'each of these hexes that adds connecting track.',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                discount: 20,
                must_lay_together: true,
                hexes: %w[H12 G13],
                tiles: %w[5 6 57 14 15 619 291 292 293 294 295 296],
                count: 2,
                special: false,
                connect: false,
                reachable: false,
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
            {
              type: 'token',
              description: 'Reserved $40/$60 Ft. Wayne (E11) token',
              desc_detail: 'May place token in Ft. Wayne (E11) for $40 if connected, $60 '\
                           'otherwise. Token slot is reserved until Phase IV.',
              hexes: ['E11'],
              price: 40,
              teleport_price: 60,
            },
            {
              type: 'reservation',
              hex: 'E11',
              remove: 'IV',
            },
          ],
            coordinates: 'F20',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'NYC',
            name: 'New York Central Railroad',
            logo: '1846/NYC',
            simple_logo: '1846/NYC.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'D20',
            color: '#110a0c',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '1846/BO',
            simple_logo: '1846/BO.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40/$100 Cincinnati (H12) token',
                desc_detail: 'May place token in Cincinnati (H12) for $40 if connected, $100 '\
                             'otherwise. Token slot is reserved until Phase IV.',
                hexes: ['H12'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'H12',
                remove: 'IV',
              },
            ],
            coordinates: 'G19',
            color: '#025aaa',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '1846/CO',
            simple_logo: '1846/CO.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'I15',
            color: :'#ADD8E6',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'ERIE',
            name: 'Erie Railroad',
            logo: '1846/ERIE',
            simple_logo: '1846/ERIE.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 Erie (D20) token',
                desc_detail: 'May place $40 token in Erie (D20) if connected. Token slot is '\
                             'reserved until Phase IV.',
                hexes: ['D20'],
                count: 1,
                price: 40,
              },
              {
                type: 'reservation',
                hex: 'D20',
                slot: 1,
                remove: 'IV',
              },
            ],
            coordinates: 'E21',
            color: :'#FFF500',
            text_color: 'black',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'GT',
            name: 'Grand Trunk Railway',
            logo: '1846/GT',
            simple_logo: '1846/GT.alt',
            tokens: [0, 80, 80],
            coordinates: 'B16',
            color: '#f58121',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '1846/IC',
            simple_logo: '1846/IC.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'tile_lay',
                discount: 20,
                description: 'Free yellow tile lays on hexes E5, F6, G5, H6, J4',
                desc_detail: 'May lay yellow tiles for free on hexes marked with an IC-icon (E5, '\
                             'F6, G5, H6 and J4).',
                passive: true,
                when: 'track_and_token',
                hexes: %w[E5 F6 G5 H6 J4],
                tiles: %w[7 8 9],
              },
              {
                type: 'token',
                description: 'Reserved $40 Centralia (I5) token',
                desc_detail: 'May place $40 token in Centralia (I5) if connected. Token slot is reserved until '\
                             'Phase IV.',
                hexes: ['I5'],
                count: 1,
                price: 40,
              },
              {
                type: 'reservation',
                hex: 'I5',
                remove: 'IV',
              },
              {
                type: 'base',
                description: 'Receives subsidy equal to its par price',
                desc_detail: 'Upon being launched IC receives a subsidy equal to its par price '\
                             'paid by the bank into its treasury.',
                remove: 'par',
              },
            ],
            coordinates: 'K3',
            color: '#32763f',
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
            coordinates: 'C15',
            color: :pink,
            text_color: 'black',
          },
          {
            sym: 'BIG4',
            name: 'Big 4',
            logo: '1846/B4',
            simple_logo: '1846/B4.alt',
            tokens: [0],
            coordinates: 'G9',
            color: :cyan,
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
