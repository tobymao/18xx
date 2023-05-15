# frozen_string_literal: true

module Engine
  module Game
    module G1817
      module Entities
        COMPANIES = [
          {
            name: 'P4 - Pittsburgh Steel Mill',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place a special yellow tile (#X00) on Pittsburgh (F13) during '\
                  'tile-laying, regardless of connectivity.  The hex is not '\
                  'reserved, and the power is lost if another corp builds there first.',
            sym: 'PSM',
            abilities: [
            {
              type: 'tile_lay',
              hexes: ['F13'],
              tiles: ['X00'],
              when: 'track',
              owner_type: 'corporation',
              count: 1,
              consume_tile_lay: true,
              closed_when_used_up: true,
              special: true,
            },
          ],
            color: nil,
          },
          {
            name: 'P3 - Mountain Engineers',
            value: 40,
            revenue: 0,
            desc: 'Owning corp receives $20 after laying a yellow tile in a '\
                  'mountain hex.  Any fees must be paid first.',
            sym: 'ME',
            abilities: [
              {
                type: 'tile_income',
                income: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
                owner_only: true,
              },
            ],
            color: nil,
          },
          {
            name: 'P2 - Ohio Bridge Company',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the '\
                  'owning corp in Louisville, Cincinnati, or Charleston, max one '\
                  'token per city, regardless of connectivity.  Allows owning '\
                  'corp to skip $10 river fee when placing yellow tiles.',
            sym: 'OBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: %w[H3 G6 H9],
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'P8 - Union Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge token that may be placed by the '\
                  'owning corp in Louisville, Cincinnati, or Charleston, max '\
                  'one token per city, regardless of connectivity.  Allows '\
                  'owning corp to skip $10 river fee when placing yellow tiles.',
            sym: 'UBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: %w[H3 G6 H9],
                count: 2,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'P7 - Train Station',
            value: 80,
            revenue: 0,
            desc: 'Provides an additional station marker for the owning corp, awarded at time of purchase',
            sym: 'TS',
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
            name: 'P1 - Minor Coal Mine',
            value: 30,
            revenue: 0,
            desc: 'Comes with ONE coal mine marker. Owning corporation may place a marker to build a yellow "coal mine" tile '\
                  'on a mountain hex next to any revenue center (a city or offboard hex). '\
                  'Placing this tile ignores the $15 mountain terrain cost. '\
                  'This yellow tile must either connect to the adjacent revenue center directly or be placed in such a way that '\
                  'an adjacent city tile could conceivably be upgraded to connect to it. '\
                  'Coal mines add a $10 bonus to any route passing through it. '\
                  'Train routes may not start or end at a coal mine.',

            sym: 'MINC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B25
                          C20
                          C24
                          E18
                          F15
                          G12
                          G14
                          H11
                          H13
                          H15
                          I8
                          I10],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'P5 - Coal Mine',
            value: 60,
            revenue: 0,
            desc: 'Comes with TWO coal mine markers. Owning corporation may place a marker to build a yellow "coal mine" tile '\
                  'on a mountain hex next to any revenue center (a city or offboard hex). '\
                  'Placing this tile ignores the $15 mountain terrain cost. '\
                  'This yellow tile must either connect to the adjacent revenue center directly or be placed in such a way that '\
                  'an adjacent city tile could conceivably be upgraded to connect to it. '\
                  'Coal mines add a $10 bonus to any route passing through it. '\
                  'Train routes may not start or end at a coal mine.',
            sym: 'CM',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B25
                          C20
                          C24
                          E18
                          F15
                          G12
                          G14
                          H11
                          H13
                          H15
                          I8
                          I10],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
            color: nil,
          },
          {
            name: 'P10 - Major Coal Mine',
            value: 90,
            revenue: 0,
            desc: 'Comes with THREE coal mine markers. Owning corporation may place a marker to build a yellow "coal mine" tile '\
                  'on a mountain hex next to any revenue center (a city or offboard hex). '\
                  'Placing this tile ignores the $15 mountain terrain cost. '\
                  'This yellow tile must either connect to the adjacent revenue center directly or be placed in such a way that '\
                  'an adjacent city tile could conceivably be upgraded to connect to it. '\
                  'Coal mines add a $10 bonus to any route passing through it. '\
                  'Train routes may not start or end at a coal mine.',
            sym: 'MAJC',
            abilities: [
              {
                type: 'tile_lay',
                hexes: %w[B25
                          C20
                          C24
                          E18
                          F15
                          G12
                          G14
                          H11
                          H13
                          H15
                          I8
                          I10],
                tiles: %w[7 8 9],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
            color: nil,
          },
          {
            name: 'P6 - Minor Mail Contract',
            value: 60,
            revenue: 0,
            desc: 'Pays owning corp $10 at the start of each operating round, '\
                  'as long as the corp has at least one train.',
            sym: 'MINM',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 10,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'P9 - Mail Contract',
            value: 90,
            revenue: 0,
            desc: 'Pays owning corp $15 at the start of each operating round, '\
                  'as long as the corp has at least one train.',
            sym: 'MAIL',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 15,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'P11 - Major Mail Contract',
            value: 120,
            revenue: 0,
            desc: 'Pays owning corp $20 at the start of each operating round, '\
                  'as long as the corp has at least one train.',
            sym: 'MAJM',
            abilities: [
              {
                type: 'revenue_change',
                revenue: 20,
                when: 'has_train',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
        ].freeze

        RANCH_HEXES = %w[B3 B11 B15 B19 B21 B23 C4 C16 C18 D5 D13 D15 D17 E4
                         E6 E8 E10 E12 E14 F5 F7 F11 G2 G4 G8 G10 H5 H7 I2 I4].freeze

        VOLATILITY_COMPANIES = [
          {
            name: 'P12 - Loan Shark',
            value: 60,
            revenue: 0,
            desc: 'Owning corp receives $60 along with this private company. The owning '\
                  'corp must pay $10 during the "Pay Loan Interest" phase of each '\
                  'operating round. Failure to pay the $10 results in liquidation. '\
                  'The loan shark remains in force for the entire game, unless the '\
                  "bank purchases the owning corp's assets through liquidation.",
            sym: 'P12',
            color: nil,
          },
          {
            name: 'P13 - Ponzi Scheme',
            value: 100,
            revenue: 0,
            desc: 'This private company does nothing.',
            sym: 'P13',
            color: nil,
          },
          {
            name: 'P14 - Inventor',
            value: 70,
            revenue: 0,
            desc: 'The bank pays the owning corp when the first type of each train '\
                  'is purchased or exported (2: $20, 2+: $0, 3: $30, 4: $40, '\
                  '5: $50, 6: $60, 7: $70, 8: $80).',
            sym: 'P14',
            color: nil,
          },
          {
            name: 'P15 - Scrapper',
            value: 40,
            revenue: 0,
            desc: 'Owning corp receives compensation for each train it owns that become '\
                  'obsolete and are eliminated (2: $30, 2+: $30, 3: $75, 4: $150).',
            sym: 'P15',
            abilities: [
              {
                type: 'train_scrapper',
                scrap_values: { '2' => 30, '2+' => 30, '3' => 75, '4' => 150 },
              },
            ],
            color: nil,
          },
          {
            name: 'P16 - Buffalo Rail Center',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place a special yellow tile (#X00) on Buffalo (C14) during '\
                  'tile-laying, regardless of connectivity.  The hex is not '\
                  'reserved, and the power is lost if another corp builds there first.',
            sym: 'P16',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ['C14'],
                tiles: ['X00'],
                when: 'track',
                owner_type: 'corporation',
                count: 1,
                consume_tile_lay: true,
                closed_when_used_up: true,
                special: true,
              },
            ],
            color: nil,
          },
          {
            name: 'P17 - Toledo Industry',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place a special yellow tile (#X00) on Toledo (D7) during '\
                  'tile-laying, regardless of connectivity.  The hex is not '\
                  'reserved, and the power is lost if another corp builds there first.',
            sym: 'P17',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ['D7'],
                tiles: ['X00'],
                when: 'track',
                owner_type: 'corporation',
                count: 1,
                consume_tile_lay: true,
                closed_when_used_up: true,
                special: true,
              },
            ],
            color: nil,
          },
          {
            name: 'P18 - Express Track',
            value: 30,
            revenue: 0,
            desc: 'Owning corp must pay $10 to perform the first tile operation each '\
                  'operating round. The corp may perform a second tile operation for '\
                  'free. The corp may skip all tile operations to avoid the $10 fee. '\
                  'If combined with Efficient Track (P19), both first and second track '\
                  'operations are free.',
            sym: 'P18',
            color: nil,
          },
          {
            name: 'P19 - Efficient Track',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may perform a second tile operation for $10, instead of '\
                  'the normal $20. If combined with Express Track (P18), both first and '\
                  'second track operations are free.',
            sym: 'P19',
            color: nil,
          },
          {
            name: 'P20 - Golden Parachute',
            value: 100,
            revenue: 0,
            desc: 'The President of the corp owning this private company is paid $100 from the '\
                  'bank when the Golden Parachute ownership is transferred to a corp '\
                  'with a different player as president, or discarded to the bank.',
            sym: 'P20',
            color: nil,
          },
          {
            name: 'P21 - Station Subsidy',
            value: 70,
            revenue: 0,
            desc: 'Owning corp receives $50 every time it converts (not merges) to a '\
                  '5-share or 10-share corp.',
            sym: 'P21',
            color: nil,
          },
          {
            name: 'P22 - Country Ranch',
            value: 30,
            revenue: 0,
            desc: 'Comes with one ranch token. When placing a yellow '\
                  'track tile towards an adjacent revenue center, a ranch '\
                  'token may also be placed, provided the tile is neither '\
                  'adjacent to a B-City or Chicago or Atlanta nor in or East '\
                  'of a mountain in that hex row. The ranch token increases the '\
                  'value of any route through the hex by $10. The yellow tile '\
                  'underlying the ranch token may not be upgraded. May not '\
                  'start or end a route at a ranch token.',
            sym: 'P22',
            abilities: [
              {
                type: 'tile_lay',
                hexes: RANCH_HEXES,
                tiles: %w[7 8 9],
                when: 'track',
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'P23 - Rural Ranch',
            value: 60,
            revenue: 0,
            desc: 'Comes with two ranch tokens. When placing a yellow '\
                  'track tile towards an adjacent revenue center, a ranch '\
                  'token may also be placed, provided the tile is neither '\
                  'adjacent to a B-City or Chicago or Atlanta nor in or East '\
                  'of a mountain in that hex row. The ranch token increases the '\
                  'value of any route through the hex by $10. The yellow tile '\
                  'underlying the ranch token may not be upgraded. May not '\
                  'start or end a route at a ranch token.',
            sym: 'P23',
            abilities: [
              {
                type: 'tile_lay',
                hexes: RANCH_HEXES,
                tiles: %w[7 8 9],
                when: 'track',
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
            color: nil,
          },
          {
            name: 'P24 - Indianapolis Market',
            value: 40,
            revenue: 0,
            desc: 'Owning corp may place a special (#X00) yellow tile on Indianapolis (F3) during '\
                  'tile-laying, regardless of connectivity.  The hex is not '\
                  'reserved, and the power is lost if another corp builds there first.',
            sym: 'P24',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ['F3'],
                tiles: ['X00'],
                when: 'track',
                owner_type: 'corporation',
                count: 1,
                consume_tile_lay: true,
                closed_when_used_up: true,
                special: true,
              },
            ],
            color: nil,
          },
        ].freeze

        MINE_COMPANIES = %w[MINC CM MAJC].freeze
        RANCH_COMPANIES = %w[P22 P23].freeze
        VOLATILITY_CITY_TILE_COMPANIES = %w[PSM P16 P17 P24].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'A&S',
            name: 'Alton & Southern Railway',
            logo: '1817/AS',
            simple_logo: '1817/AS.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ee3e80',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'A&A',
            name: 'Arcade and Attica',
            logo: '1817/AA',
            simple_logo: '1817/AA.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#904098',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'Belt',
            name: 'Belt Railway of Chicago',
            logo: '1817/Belt',
            simple_logo: '1817/Belt.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#f2a847',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'Bess',
            name: 'Bessemer and Lake Erie Railroad',
            logo: '1817/Bess',
            simple_logo: '1817/Bess.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#16190e',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'B&A',
            name: 'Boston and Albany Railroad',
            logo: '1817/BA',
            simple_logo: '1817/BA.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ef4223',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'DL&W',
            name: 'Delaware, Lackawanna and Western Railroad',
            logo: '1817/DLW',
            simple_logo: '1817/DLW.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#984573',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'J',
            name: 'Elgin, Joliet and Eastern Railway',
            logo: '1817/J',
            simple_logo: '1817/J.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#bedb86',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'GT',
            name: 'Grand Trunk Western Railroad',
            logo: '1817/GT',
            simple_logo: '1817/GT.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#e48329',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'H',
            name: 'Housatonic Railroad',
            logo: '1817/H',
            simple_logo: '1817/H.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#bedef3',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'ME',
            name: 'Morristown and Erie Railway',
            logo: '1817/ME',
            simple_logo: '1817/ME.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ffdea8',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'NYOW',
            name: 'New York, Ontario and Western Railway',
            logo: '1817/W',
            simple_logo: '1817/W.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#0095da',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'NYSW',
            name: 'New York, Susquehanna and Western Railway',
            logo: '1817/S',
            simple_logo: '1817/S.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#fff36b',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PSNR',
            name: 'Pittsburgh, Shawmut and Northern Railroad',
            logo: '1817/PSNR',
            simple_logo: '1817/PSNR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#0a884b',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '1817/PLE',
            simple_logo: '1817/PLE.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#00afad',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PW',
            name: 'Providence and Worcester Railroad',
            logo: '1817/PW',
            simple_logo: '1817/PW.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#bec8cc',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'R',
            name: 'Rutland Railroad',
            logo: '1817/R',
            simple_logo: '1817/R.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#165633',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SR',
            name: 'Strasburg Railroad',
            logo: '1817/SR',
            simple_logo: '1817/SR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#e31f21',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'UR',
            name: 'Union Railroad',
            logo: '1817/UR',
            simple_logo: '1817/UR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#003d84',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'WT',
            name: 'Warren & Trumbull Railroad',
            logo: '1817/WT',
            simple_logo: '1817/WT.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#e96f2c',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'WC',
            name: 'West Chester Railroad',
            logo: '1817/WC',
            simple_logo: '1817/WC.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#984d2d',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
