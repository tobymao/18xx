# frozen_string_literal: true

module Engine
  module Game
    module G1846
      module Entities
        COMPANIES = [
          {
            name: 'Michigan Southern (Minor)',
            value: 60,
            discount: -80,
            revenue: 0,
            desc: 'Starts with $60, a 2 train, and a token in Detroit (C15). Always operates first. Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                  'but cannot run this 2 train in the same OR in which the MS operated. ',
            sym: 'MS',
            color: nil,
          },
          {
            name: 'Big 4 (Minor)',
            value: 40,
            discount: -60,
            revenue: 0,
            desc: 'Starts with $40, a 2 train, and a token in Indianapolis (G9). '\
                  'Always operates after the MS and before other corporations. '\
                  'Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                  'but cannot run this 2 train in the same OR in which the BIG4 operated. ',
            sym: 'BIG4',
            color: nil,
          },
          {
            name: 'Chicago and Western Indiana',
            value: 60,
            revenue: 10,
            desc: 'Reserves a token slot in the southeast entrance to Chicago (D6) next to E7. Owning '\
                  'corporation may place an extra token there for free (no connection required). '\
                  'Reservation is removed once this company is purchased by a corporation or closed.',
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
            desc: 'Adds a $10 bonus for each city visited by a single train of the owning corporation. '\
                  'Never closes once purchased by a corporation. Closes on Phase III if owned by a player',
            sym: 'MAIL',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Tunnel Blasting Company',
            value: 60,
            revenue: 20,
            desc: 'Reduces the cost of laying tiles on mountains (hexes with a brown triangle) and '\
                  'connecting hexes with tunnels (brown hex edges) by $20 for the owning corporation.',
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
            desc: 'Adds a $30 bonus to either St. Louis (I1) or Chicago (D6) for the owning corporation. '\
                  'Bonus must be assigned after being purchased by a corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
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
            desc: 'Add a bonus to the value of one port city, either a $40 bonus to Wheeling (G19) / Holland (B8) '\
                  'or a $20 bonus to Chicago Conn. (C5) / Toledo (D14) / St. Louis (I1). '\
                  'At the beginning of each OR, this company\'s owner may reassign this bonus '\
                  'to a different port city and/or train company (including minors). '\
                  'Once purchased by a corporation, it becomes permanently assigned to that corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
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
            desc: 'Owning corporation may make an extra free green tile upgrade of either '\
                  'Cleveland (E17) or Toledo (D14).',
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
            desc: 'Owning corporation may lay up to two extra free yellow tiles '\
                  'in reserved hexes B10 and B12. '\
                  'If both tiles are laid, they must connect to each other. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
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
            desc: 'Owning corporation may lay up to two extra free yellow tiles '\
                  'in reserved hexes F14 and F16. '\
                  'If both tiles are laid, they must connect to each other. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
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
            desc: 'Adds a $20 bonus to Cincinnati (H12) for the owning corporation. '\
                  'Bonus must be assigned after being purchased by a corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
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
            desc: 'If no track connects Cincinnati (H12) to Dayton (G13), the '\
                  'owning corporation may lay and/or upgrade an extra free tile in each hex to connect them. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
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
              description: 'Reserved $40 token/$60 teleport on E11',
              desc_detail: 'May place token in Ft. Wayne (E11) for $40 if connected, $60 '\
                           'otherwise. This token slot is reserved until Phase IV.',
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
                description: 'Reserved $40 token/$100 teleport on H12',
                desc_detail: 'May place token in Cincinnati (H12) for $40 if connected, $100 '\
                             'otherwise. This token slot is reserved until Phase IV.',
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
                description: 'Reserved $40 token in Erie (D20)',
                desc_detail: 'May place $40 token in Erie (D20) if connected. This token slot is '\
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
                type: 'base',
                description: 'Receives an initial subsidy of 1x par value',
                desc_detail: 'When floated IC receives a one-time subsidy equal to its par price into its treasury.',
                remove: 'par',
              },
              {
                type: 'tile_lay',
                discount: 20,
                description: 'Free yellow tile lays on "IC" hexes',
                desc_detail: 'IC lays yellow tiles for free on hexes marked with an IC icon (E5, '\
                             'F6, G5, H6 and J4).',
                passive: true,
                when: 'track_and_token',
                hexes: %w[E5 F6 G5 H6 J4],
                tiles: %w[7 8 9],
              },

              {
                type: 'token',
                description: 'Reserved $40 Centralia (I5) token',
                desc_detail: 'May place $40 token in Centralia (I5) if connected. This token slot is reserved until '\
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

            ],
            coordinates: 'K3',
            color: '#32763f',
            always_market_price: true,
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
