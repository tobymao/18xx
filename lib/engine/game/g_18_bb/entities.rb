# frozen_string_literal: true

require_relative '../g_18_bb/entities'
module Engine
  module Game
    module G18BB
      module Entities
        BASE_COMPANIES = G1846::Entities::COMPANIES.dup

        cwi = BASE_COMPANIES.find { |d| d[:sym] == 'C&WI' }
        cwi.update({
                     :desc => cwi[:desc] + ' The owning corporation may lay one extra phase appropriate yellow tile or '\
                                           'green tile/upgrade in either D6, E7, or F8 during their normal tile laying step. '\
                                           'The owning corporation must pay the normal $20 '\
                                           'cost to lay this extra tile/upgrade. Using this ability closes the C&WI.',
                     :abilities => cwi[:abilities].append({
                                                            type: 'tile_lay',
                                                            closed_when_used_up: true,
                                                            owner_type: 'corporation',
                                                            hexes: %w[D6 E7 F8],
                                                            tiles: %w[298 7 8 9 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31],
                                                            count: 1,
                                                          }),
                   })

        bt = BASE_COMPANIES.find { |d| d[:sym] == 'BT' }
        bt[:abilities].find { |a| a[:type] == 'assign_hexes' }[:hexes].append('J10')
        bt.update({
                    desc: 'Adds a $20 bonus to Cincinnati (H12) or Louisville (J10) for '\
                          'the owning corporation. Bonus must be assigned'\
                          ' after being purchased by a corporation. '\
                          'Bonus persists after this company closes in Phase III but is removed in Phase IV.',

                  })

        lsl = BASE_COMPANIES.find { |d| d[:sym] == 'LSL' }
        lsl.update({
                     :desc => cwi[:desc] + ' If both Cleveland (E17 ) AND Toledo (D14) have both already been upgraded to a '\
                                           'green tile and the private company’s ability has not yet been used, '\
                                           'the owning corporation may use the ability, plus pay an additional $40, to upgrade '\
                                           'either Cleveland or Toledo to a brown tile. Using the ability in this manner would '\
                                           'supercede entering the brown phase, as the company normally would '\
                                           '(and will be) removed from the game at the start of the brown phase. '\
                                           'Using the ability to place a brown tile closes this private company.',
                   })

        NEW_COMPANIES = [
            {
              name: 'Louisville, Cincinnati, and Lexington Railroad',
              value: 40,
              revenue: 15,
              desc: 'The owning corporation may lay up to two extra yellow tiles in the LCL’s reserved hexes (I3, J14, K13). '\
                    'The owning corporation receives a discount of $20 for each tile laid, '\
                    'which offsets some of the terrain cost. '\
                    'This ability can be combined with the abilities of other private companies to further offset the cost of '\
                    'terrain in these hexes. If two tiles are laid using this ability, the layed '\
                    'tiles have no requirement to connect to one another.',
              sym: 'LCL',
              abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[I13 J14 K13] },
                          {
                            type: 'tile_lay',
                            when: 'owning_corp_or_turn',
                            owner_type: 'corporation',
                            free: true,
                            discount: 20,
                            must_lay_together: true,
                            hexes: %w[I13 J14 K13],
                            tiles: %w[7 8 9],
                            count: 2,
                          }],
              color: nil,
            },
            {
              name: 'Southwestern Steamboat Company',
              sym: 'SSC',
              value: 40,
              revenue: 10,
              desc: 'Add a bonus to the value of one orange port city, either a $40 bonus to Evansville (J6) '\
                    'or a $20 bonus to St. Louis (I1) / Cairo (K4) / Nashivle (L8) / Charleston (I17). '\
                    'At the beginning of each OR, this company\'s owner may reassign this bonus '\
                    'to a different orange port city and/or train company (including minors). '\
                    'Once purchased by a corporation, it becomes permanently assigned to that corporation. '\
                    'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
              abilities: [
                      {
                        type: 'assign_hexes',
                        hexes: %w[I17 K3 L8 I1 J6],
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
                        hexes: %w[I17 K3 L8 I1 J6],
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
              name: 'Oil and Gas Company',
              sym: 'O&G',
              value: 40,
              revenue: 10,
              desc: 'Add a bonus to the value of oil and gas city of $20 to Salamanca (E21) '\
                    '/ Columbus (G15) / Indianapolis (G9). '\
                    'At the beginning of each OR, this company\'s owner may reassign this bonus '\
                    'to a different oil and gas city and/or train company (including minors). '\
                    'Once purchased by a corporation, it becomes permanently assigned to that corporation. '\
                    'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
              abilities: [
                      {
                        type: 'assign_hexes',
                        hexes: %w[E21 G15 G9],
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
                        hexes: %w[E21 G15 G9],
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
              name: 'Grain Mill Company',
              value: 70,
              revenue: 25,
              desc: 'The owning corporation may place a special green “Mill Town” tile on either Springfield (G3), '\
                    'South Bend (C9), or Lexington (J12), even in the yellow phase. This green tile lay counts as '\
                    'one of the corporation\'s two $20 tile actions for that operation (plus terrain costs if '\
                    'laying in Lexington J12), the other tile action (if used) may be a yellow tile or a '\
                    'phase-appropriate green tile upgrade. A track connection to the location where the tile '\
                    'is placed is not required. The owning corporation may place a $30 Mill '\
                    'Marker “Wheat/Corn Stalk” on the MT tile after the tile has been placed. This marker '\
                    'pays an additional $30 revenue to all routes run to this location by ALL COMPANIES. '\
                    'The “Mill Town” tile contains space for one token and that space is reserved for '\
                    'the owning corporation. The owning corporation may place an extra token on this space '\
                    'during its normal tile/token laying step. This special tile costs $80 as a teleport, '\
                    'or $60 if using an unblocked track connection from another of their token markers. '\
                    'The Grain Mill Company closes AND the Mill Marker is removed from the game immediately '\
                    'when the brown phase begins.',
              sym: 'GMC',
              color: nil,
              abilities: [
                {
                  type: 'tile_lay',
                  consume_tile_lay: true,
                  owner_type: 'corporation',
                  hexes: %w[G3 C9 J12],
                  tiles: %w[M1],
                  count: 1,
                },
                {
                  type: 'assign_hexes',
                  when: %w[track_and_token],
                  hexes: %w[G3 C9 J12],
                  tiles: %w[M1],
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
            },
            {
              name: 'Bridging Company',
              value: 50,
              revenue: 15,
              desc: 'Reduces, for the owning corporation, the cost of laying all water tiles and water/bridge hexides by $20. '\
                    'This ability can be combined with the abilities of other private companies '\
                    'to further offset the cost of terrain in various places.',
              sym: 'BC',
              abilities: [
                {
                  type: 'tile_discount',
                  discount: 20,
                  terrain: 'water',
                  owner_type: 'corporation',
                },
              ],
              color: nil,
            },
            {
              name: 'Nashville and Northwestern (Minor)',
              value: 40,
              discount: -60,
              revenue: 0,
              desc: 'Starts with $40, a 2 train, and a token in Nashville (L8). Its train may run in OR1. '\
                    'Additionally, this private company also receives a $20 discount on the cost '\
                    'of all water tiles and water/bridge hexides. This ability persists and is granted '\
                    'to the owning corporation once the private company is purchased '\
                    'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                    'but cannot run this 2 train in the same OR in which the NN operated. ',
              sym: 'N&N',
              abilities: [
                {
                  type: 'tile_discount',
                  discount: 20,
                  terrain: 'water',
                  owner_type: 'corporation',
                },
              ],
              color: nil,
            },
            {
              name: 'Virginia Coal Company (Minor)',
              value: 60,
              discount: -60,
              revenue: 0,
              desc: 'Starts with $60, a 2 train, and a token on H18. A special Coal mine tile is placed on H18. '\
                    'Its train may run in OR1. '\
                    'Additionally, this private company also receives a $20 discount on the cost of all '\
                    'mountain tiles and tunnel/pass hexides. This ability persists and is granted to the '\
                    'owning corporation once the private company is purchased '\
                    'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                    'but cannot run this 2 train in the same OR in which this minor operated. ',
              sym: 'VCC',
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
              name: 'Buffalo, Rochester and Pittsburgh (Minor)',
              value: 40,
              discount: -40,
              revenue: 0,
              desc: 'Starts with $20, a 2 train, and a token on Salamanca (C21). A special Salamanca tile is placed on C21. '\
                    'Its train may run in OR1. An addditonal 2 train is added to the train roster'\
                    'At the start of Operating Round 1.2, this company receives an additional $20 from the bank. '\
                    'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                    'but cannot run this 2 train in the same OR in which this minor operated. ',
              sym: 'BRP',
              color: nil,
              treasury: 20,
            },

            {
              name: 'Cleveland, Columbus and Cincinnati (Minor)',
              value: 40,
              discount: -20,
              revenue: 0,
              desc: 'starts with $21 in treasury, but no train and no token. '\
                    'This private company has special rules and restrictions surrounding it. Please consult the rulebook. ',
              sym: 'CCC',
              color: nil,
            },

        ].freeze

        COMPANIES = BASE_COMPANIES + NEW_COMPANIES

        COMPANIES.freeze

        BASE_CORPORATIONS = G1846::Entities::CORPORATIONS.dup
        ic = BASE_CORPORATIONS.find { |c| c[:sym] == 'IC' }
        ic[:coordinates] = 'I5'
        ic[:abilities].find { |a| a[:type] == 'reservation' }[:hex] = 'L8'
        ic[:abilities].delete_if { |a| a[:type] == 'token' }
        ic[:abilities] << {
          type: 'token',
          description: 'Reserved $60 Nashville (L8) token',
          desc_detail: 'May place $60 token in Centralia (I5). No connection required '\
                       'This token slot is reserved until Phase IV.',
          hexes: ['L8'],
          count: 1,
          price: 60,
          teleport_price: 60,
        }
        BASE_CORPORATIONS.freeze

        NEW_CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_ms/LN',
            simple_logo: '18_ms/LN.alt',
            tokens: [0, 80, 80],
            coordinates: 'J10',
            color: '#0d5ba5',
            always_market_price: true,
          },

        ].freeze

        CORPORATIONS = BASE_CORPORATIONS + NEW_CORPORATIONS
        CORPORATIONS.freeze

        NEW_MINORS = [
          {
            sym: 'N&N',
            name: 'Nashville and Northwestern',
            logo: '18_bb/NN',
            simple_logo: '18_bb/NN.alt',
            tokens: [0],
            coordinates: 'L8',
            color: '#4C9141',
            text_color: 'white',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'water',
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'VCC',
            name: 'Virginia Coal Company',
            logo: '18_bb/VCC',
            simple_logo: '18_bb/VCC.alt',
            tokens: [0],
            coordinates: 'H18',
            color: '#5E2129',
            text_color: 'white',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
          },

          {
            sym: 'BRP',
            name: 'Buffalo Rochester and Pittsburgh',
            logo: '18_bb/BRP',
            simple_logo: '18_bb/BRP.alt',
            tokens: [0],
            coordinates: 'E21',
            color: '#F3A505',
            text_color: 'white',
          },
          {
            sym: 'CCC',
            name: 'Cleveland Columbus and Cincinnati',
            logo: '18_bb/CCC',
            simple_logo: '18_bb/CCC.alt',
            tokens: [0],
            color: '#969992',
            text_color: 'white',
          },

        ].freeze
        MINORS = G1846::Entities::MINORS.dup + NEW_MINORS
        MINORS.freeze
      end
    end
  end
end
