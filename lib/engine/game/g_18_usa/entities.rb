# frozen_string_literal: true

require_relative 'map'

module Engine
  module Game
    module G18USA
      module Entities
        include G18USA::Map

        COMPANIES = [
          # P1
          {
            name: 'P1 - Lehigh Coal Mine Co.',
            value: 30,
            revenue: 0,
            desc: 'Comes with one coal mine marker. When placing a yellow '\
                  'tile in a coal hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes can be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P1',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: [RESOURCE_LABELS[:coal]],
                when: 'track',
                reachable: true,
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
          },
          # P2
          {
            name: 'P2 - Fox Bridge Works',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city.  Allows owning corp to '\
                  'skip $10 river fee when placing track.',
            sym: 'P2',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: RIVER_HEXES,
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
          },
          # P3
          {
            name: 'P3 - Reece Oil and Gas',
            value: 30,
            revenue: 0,
            desc: 'Comes with one oil marker. When placing a yellow '\
                  'tile in an oilfield hex pointing to a revenue location, can place '\
                  'token.  Marked yellow hexes *can* be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  Hexes revenue bonus is upgraded automatically to $20 in phase 5. '\
                  'May not start or end a route at an oilfield.',
            sym: 'P3',
            abilities: [
              {
                type: 'tile_lay',
                hexes: OIL_HEXES,
                tiles: [RESOURCE_LABELS[:oil]],
                when: 'track',
                reachable: true,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
          },
          # P4
          {
            name: 'P4 - Hendrickson Iron',
            value: 40,
            revenue: 0,
            desc: 'Comes with one ore marker. When placing a yellow '\
                  'tile in a mining hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee. Marked yellow hexes cannot be '\
                  'upgraded. Hexes pay $10 extra revenue and do not count as a '\
                  'stop. A tile upgrade action may be used to increase the revenue bonus to $20 in phase 3. '\
                  ' May not start or end a route at an ore mine.',
            sym: 'P4',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ORE_HEXES,
                tiles: [RESOURCE_LABELS[:ore]],
                when: 'track',
                reachable: true,
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
          },
          # P5
          {
            name: 'P5 - Nobel\'s Blasting Powder',
            value: 30,
            revenue: 0,
            desc: '$15 discount on mountains. No money is refunded if combined with the ability of another private that also '\
                  'negates the cost of difficult terrain',
            sym: 'P5',
            abilities: [
              {
                type: 'tile_discount',
                discount: 15,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
          },
          # P6
          {
            name: 'P6 - Import/Export Hub',
            value: 30,
            revenue: 0,
            desc: 'Discard during a corporation\'s lay or upgrade track step to replace one red area value token with the ' \
                  '30/40/50/80 value token. The corporation must be able to trace a legal route to reach the red area.',
            sym: 'P6',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'track',
                owner_type: 'corporation',
                hexes: [], # Connected offboards
              },
            ],
          },
          # P7
          {
            name: 'P7 - Track Engineers',
            value: 40,
            revenue: 0,
            desc: 'May lay two extra yellow tiles instead of one when paying $20.',
            sym: 'P7',
            abilities: [
              # Built into game class
            ],
          },
          # P8
          {
            name: 'P8 - Express Freight Service',
            value: 40,
            revenue: 0,
            desc: 'Place an extra station marker from the owning company in one red area. The company receives +10 ' \
                  'revenue for each train which runs to that red area for the remainder of the game. The station ' \
                  'marker in the red area is not a normal station. It is only an indicator of which area the ' \
                  'company receives the +10 revenue bonus. During a merger or acquisition, the station marker in ' \
                  'the red area must be replaced by a station from the acquiring company if one is available. If ' \
                  'during a merger or acquisition, the new company has more than 8 station markers (counting the ' \
                  'station marker in the red area), the new company may choose to either keep or remove the station ' \
                  'marker from the red area. If the station marker is removed during a M&A action the Express ' \
                  'Freight Service private company is discarded.',
            sym: 'P8',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'track',
                owner_type: 'corporation',
                hexes: [], # Connected offboards
              },
            ],
          },
          # P9
          {
            name: 'P9 - Boomtown',
            value: 40,
            revenue: 0,
            desc: "Discard during the owning corporation's lay or upgrade track step to upgrade a yellow non-metropolis city "\
                  'to green. This does not count as a normal track laying action. The corporation must have a legal route to '\
                  'the city being upgraded.',
            sym: 'P9',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                closed_when_used_up: true,
                count: 1,
                hexes: CITY_HEXES,
                tiles: %w[14 15 619],
              },
            ],
          },
          # P10
          {
            name: 'P10 - Carnegie Steel Company',
            value: 40,
            revenue: 0,
            desc: 'If this company starts in an unselected and unimproved metropolis, that city becomes a metropolis. '\
                  'All potential metropolises for this private are: '\
                  'Atlanta, Chicago, Denver, Dallas-Fort Worth, Los Angeles, and New Orleans.',
            sym: 'P10',
            abilities: [
              # Owning the private is the ability
            ],
          },
          # P11
          {
            name: 'P11 - Pettibone & Mulliken',
            value: 40,
            revenue: 0,
            desc: 'The corporation may upgrade two track tiles when paying $20 to perform two track operations. ' \
                  'Only one upgrade may be a city. The corporation may upgrade non-city track to a color one higher ' \
                  'than the current phase normally allows',
            sym: 'P11',
            abilities: [
              # Built into track class
            ],
          },
          # P12
          {
            name: 'P12 - Standard Oil Co.',
            value: 60,
            revenue: 0,
            desc: 'Comes with two oil markers. When placing a yellow '\
                  'tile in an oilfield hex pointing to a revenue location, can place '\
                  'token.  Marked yellow hexes *can* be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  Hexes revenue bonus is upgraded automatically to $20 in phase 5. '\
                  'May not start or end a route at an oilfield.',
            sym: 'P12',
            abilities: [
              {
                type: 'tile_lay',
                hexes: OIL_HEXES,
                tiles: [RESOURCE_LABELS[:oil]],
                when: 'track',
                reachable: true,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
          },
          # P13
          {
            name: 'P13 - Pennsy Boneyard',
            value: 60,
            revenue: 0,
            desc: 'Discard when the first 4, 6, or 8-train is purchased or exported to prevent one train from ' \
                  'rusting. The train is instead treated as an obsolete train and will be discarded at the end ' \
                  'of the corporation’s next Run Trains step. Obsolete trains may not be sold to another company ' \
                  'and do not count against the company’s train limit. This ability may only be used on a train ' \
                  'which is owned by the same company that owns Pennsy Boneyard. May not be used on 2+, 3+, or 4+ ' \
                  'trains.',
            sym: 'P13',
            abilities: [], # Implemented in game class and a custom step
          },
          # P14
          {
            name: 'P14 - Pyramid Scheme',
            value: 60,
            revenue: 0,
            desc: 'This company has no special ability.',
            sym: 'P14',
            abilities: [],
          },
          # P15
          {
            name: 'P15 - Western Land Grant',
            value: 60,
            revenue: 0,
            desc: 'The owning corporation may take one extra loan at a fixed $5 per round interest rate. ' \
                  'All other rules regarding loans are followed as normal.',
            sym: 'P15',
            abilities: [], # Implemented in game class
          },
          # P16 Regional Headquarters
          {
            name: 'P16 - Regional Headquarters',
            value: 60,
            revenue: 0,
            desc: 'Regional Headquarters may be used to upgrade a green or brown non-metropolis city after phase 5 begins. ' \
                  'May be placed on any existing normal city. Three of the track segments are optional and can be placed ' \
                  'pointing toward water or other off map areas.',
            sym: 'P16',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                consume_tile_lay: true,
                hexes: CITY_HEXES,
                tiles: ['X23'],
                count: 1,
                closed_when_used_up: true,
              },
            ],
          },
          # P17
          {
            name: 'P17 - Great Northern Railway',
            value: 60,
            revenue: 0,
            desc: 'One extra yellow lay per turn on the hexes marked with railroad track icons on the map '\
                  '(near the northern US border), ignoring terrain fees. One train can receive a +$30 revenue '\
                  'bonus for running Fargo-Helena or a +$60 revenue bonus for running Seattle-Fargo-Helena-Chicago.',
            sym: 'P17',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                hexes: %w[B4 B6 B8 B10 B12 B14 B16 B18 C19 D20],
                tiles: YELLOW_PLAIN_TRACK_TILES + PLAIN_YELLOW_CITY_TILES,
                free: true,
                special: false,
                count_per_or: 1,
              },
            ],
          },
          # P18
          {
            name: 'P18 - Peabody Coal Company',
            value: 60,
            revenue: 0,
            desc: 'Comes with two coal mine markers. When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes can be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P18',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: [RESOURCE_LABELS[:coal]],
                when: 'track',
                reachable: true,
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
          },
          # P19
          {
            name: 'P19 - Union Switch & Signal',
            value: 80,
            revenue: 0,
            desc: 'One train per turn may attach the Switcher to skip over a city (even a blocked city)',
            sym: 'P19',
            abilities: [
              # Owning the private is the ability
            ],
          },
          # P20
          {
            name: 'P20 - Suem & Wynn Law Firm',
            value: 80,
            revenue: 0,
            desc: 'Discard during the lay or upgrade track step to place an available station token into any city ' \
                  'which currently has no available open station circles. The station token will immediately fill ' \
                  'a station circle in the city if one becomes available later. This is an extra station token ' \
                  'placement. A company may use this to place two station tokens in the same round.',
            sym: 'P20',
            abilities: [
              type: 'token',
              when: 'track',
              hexes: [], # Determined in special_token step
              price: 0,
              extra_action: true,
              from_owner: true,
              special_only: true,
              cheater: true,
            ],
          },
          # P21
          {
            name: 'P21 - Keystone Bridge Co.',
            value: 80,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city.  Allows owning corp to '\
                  'skip $10 river fee when placing track. '\
                  'Also comes with one coal token and one ore token. (see rules on coal and ore) '\
                  'You can only ever use one of these two; using one means you forfeit the other',
            sym: 'P21',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: RIVER_HEXES,
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
              {
                type: 'tile_lay',
                hexes: (COAL_HEXES + ORE_HEXES).uniq,
                tiles: [RESOURCE_LABELS[:coal], RESOURCE_LABELS[:ore]],
                when: 'track',
                reachable: true,
                discount: 15,
                consume_tile_lay: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
          },
          # P22
          {
            name: 'P22 - American Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge tokens that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city.  Allows owning corp to '\
                  'skip $10 river fee when placing track.',
            sym: 'P22',
            abilities: [
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'water',
                owner_type: 'corporation',
              },
              {
                type: 'assign_hexes',
                hexes: RIVER_HEXES,
                count: 2,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
          },
          # P23
          {
            name: 'P23 - Bailey Yard',
            value: 80,
            revenue: 0,
            desc: 'Provides an additional station marker for the owning corp, awarded at time of purchase',
            sym: 'P23',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
          },
          # P24
          {
            name: 'P24 - Anaconda Copper',
            value: 90,
            revenue: 0,
            desc: 'Comes with two ore markers. When placing a yellow '\
                  'tile in a mining hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee. Marked yellow hexes cannot be '\
                  'upgraded. Hexes pay $10 extra revenue and do not count as a '\
                  'stop. A tile upgrade action may be used to increase the revenue bonus to $20 in phase 3. '\
                  ' May not start or end a route at an ore mine.',
            sym: 'P24',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ORE_HEXES,
                tiles: [RESOURCE_LABELS[:ore]],
                when: 'track',
                reachable: true,
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
          },
          # P25
          {
            name: 'P25 - American Locomotive Co.',
            value: 90,
            revenue: 0,
            desc: 'The owning corporation receives a 10% discount on all trains from the bank. During the owning company’s ' \
                  'turn, this company may be discarded prior to the Run Trains step to buy a train from the bank at a 10% ' \
                  'discount. This company is discarded when the first 6-train is purchased.',
            sym: 'P25',
            abilities: [
              {
                type: 'train_discount',
                when: 'owning_corp_or_turn',
                discount: 0.1,
                trains: %w[2 2+ 3 3+ 4 4+ 5 6],
              },
              {
                type: 'close',
                on_phase: '6',
              },
            ],
          },
          # P26
          {
            name: 'P26 - Rural Junction',
            value: 90,
            revenue: 0,
            desc: 'Comes with three rural junction tiles. Rural junctions can be placed in empty city hexes and fulfill the '\
                  'revenue center requirement for coal, ore, and oil markers and can receive bridge tokens. Rural junctions '\
                  'are not towns and do not count against the number of stops for a train and furthermore they may not be the '\
                  'start or end of a route. Rural junctions may never be upgraded; a train may not run through the same rural '\
                  'junction twice. Rural junctions may not be placed next to each other.',
            sym: 'P26',
            abilities: [
              {
                type: 'tile_lay',
                hexes: CITY_HEXES,
                tiles: RURAL_TILES,
                reachable: true,
                when: 'track',
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
          },
          # P27
          {
            name: 'P27 - Company Town',
            value: 90,
            revenue: 0,
            desc: 'Comes with 3 company town tiles, only one of which may be played. The owning corporation may place one '\
                  'Company Town tile on any empty hex not adjacent to a metropolis. When placed, the owning corporation '\
                  'receives one bonus station marker which must be placed on the Company Town tile. No other corporations may '\
                  'place a token on the Company Town hex and receive $10 less for the city than the company with the station '\
                  'marker in the city. The Company Town can be placed on any hex, city circle or not, as long as it is not '\
                  'adjacent to a metropolis and has no track or station marker in it. If the Company Town tile is placed on a '\
                  '$10 river hex, a bridge token may be used. Coal / Oil / Ore markers may not be used with the Company Town. '\
                  'If the station marker in the Company Town hex is ever removed, no token may ever replace it',
            sym: 'P27',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                consume_tile_lay: true,
                hexes: [],
                tiles: COMPANY_TOWN_TILES,
              },
            ],
          },
          # P28
          {
            name: 'P28 - Consolidation Coal Co.',
            value: 90,
            revenue: 0,
            desc: 'Comes with three coal mine markers. When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes can be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P28',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: [RESOURCE_LABELS[:coal]],
                when: 'track',
                reachable: true,
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
          },
          # P29
          {
            name: 'P29 - Bankrupt Railroad',
            value: 120,
            revenue: 0,
            desc: 'If this company starts in a city with a No Subsidy tile it immediately takes a free 2-train which it may '\
                  'run in its first OR',
            sym: 'P29',
            abilities: [
              # Owning the private is the ability
            ],
          },
          # P30
          {
            name: 'P30 - Double Heading',
            value: 120,
            revenue: 0,
            desc: 'Each turn one non-permanent train may attach the Extender to run to one extra city',
            sym: 'P30',
            abilities: [
              # Owning the private is the ability
            ],
          },
        ].freeze

        NO_SUBSIDIES = %w[S1 S2 S3 S4 S5 S6 S7].freeze
        CASH_SUBSIDIES = %w[S12 S13 S14 S15].freeze

        SUBSIDIES = [
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S1',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S2',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S3',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S4',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S5',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S6',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S7',
            name: 'No Subsidy',
            desc: 'No effect',
            value: 0,
          },
          {
            icon: 'subsidy_boomtown',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                closed_when_used_up: true,
                count: 1,
                hexes: [], # assigned when claimed
                tiles: %w[14 15 619],
              },
              {
                type: 'close',
                when: 'operated',
                corporation: nil, # assigned when claimed
              },
            ],
            id: 'S8',
            name: 'Boomtown Subsidy',
            desc: 'On it\'s first operating turn, this corporation may upgrade its home to green as a free action. This does '\
                  'not count as an additional track placement and does not incur any cost for doing so',
            value: 0,
          },
          {
            icon: 'subsidy_free_station',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                price: 0,
                count: 1,
                from_owner: false,
                cheater: true,
                special_only: true,
                hexes: [], # Determined in special_token step
              },
            ],
            id: 'S9',
            name: 'Free Station',
            desc: 'The free station is a special token (which counts toward the 8 token limit) that can be placed in any city '\
                  'the corporation can trace a legal route to, even if no open station circle is currently available in the '\
                  'city. If a open station circle becomes available later, the token will immediately fill the opening',
            value: 0,
          },
          {
            icon: 'subsidy_plus_ten',
            abilities: [],
            id: 'S10',
            name: '+10',
            desc: 'This corporation\'s home city is worth $10 for the rest of the game',
            value: 0,
          },
          {
            icon: 'subsidy_plus_ten_twenty',
            abilities: [],
            id: 'S11',
            name: '+10 / +20',
            desc: 'This corporation\'s home city is worth $10 until phase 5, after which it is worth '\
                  ' $20 more for the rest of the game',
            value: 0,
          },
          {
            icon: 'subsidy_thirty',
            abilities: [],
            id: 'S12',
            name: '$30 Subsidy',
            desc: 'The bank will contribute $30 towards the bid for this corporation',
            value: 30,
          },
          {
            icon: 'subsidy_thirty',
            abilities: [],
            id: 'S13',
            name: '$30 Subsidy',
            desc: 'The bank will contribute $30 towards the bid for this corporation',
            value: 30,
          },
          {
            icon: 'subsidy_forty',
            abilities: [],
            id: 'S14',
            name: '$40 Subsidy',
            desc: 'The bank will contribute $40 towards the bid for this corporation',
            value: 40,
          },
          {
            icon: 'subsidy_fifty',
            abilities: [],
            id: 'S15',
            name: '$50 Subsidy',
            desc: 'The bank will contribute $50 towards the bid for this corporation',
            value: 50,
          },
          {
            icon: 'subsidy_resource',
            abilities: [
              {
                type: 'tile_lay',
                hexes: [], # Added during setup
                tiles: [], # Added during setup
                when: 'track',
                reachable: true,
                consume_tile_lay: false,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            id: 'S16',
            name: 'Resource Subsidy',
            desc: '', # Added during setup
            value: 0,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'ATSF',
            name: 'Atchison, Topeka, and Santa Fe',
            logo: '18_usa/ATSF',
            simple_logo: '18_usa/ATSF.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#7090c9',
            text_color: 'White',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'B&O',
            name: 'Baltimore and Ohio Railroad',
            logo: '18_usa/BO',
            simple_logo: '18_usa/BO.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#025aaa',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'C&O',
            name: 'Chesapeake and Ohio',
            logo: '18_usa/CO',
            simple_logo: '18_usa/CO.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#ADD8E6',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'DRG',
            name: 'Denver and Rio Grande',
            logo: '18_usa/DRG',
            simple_logo: '18_usa/DRG.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Sienna',
            text_color: 'White',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'GN',
            name: 'Great Northern Railway',
            logo: '18_usa/GN',
            simple_logo: '18_usa/GR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'LightSkyBlue',
            text_color: 'Black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_usa/IC',
            simple_logo: '18_usa/IC.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#32763f',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'KCS',
            name: 'Kansas City Southern Railroad',
            logo: '18_usa/KCS',
            simple_logo: '18_usa/KCS.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Red',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MILW',
            name: 'Milwaukee Road',
            logo: '18_usa/MILW',
            simple_logo: '18_usa/MILW.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Gray',
            text_color: 'White',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MKT',
            name: 'Missouri-Kansas-Texas Railroad',
            logo: '18_usa/MKT',
            simple_logo: '18_usa/MKT.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#018471',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MP',
            name: 'Missouri Pacific Railroad',
            logo: '18_usa/MP',
            simple_logo: '18_usa/MP.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Indigo',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'NYC',
            name: 'New York Central Railroad',
            logo: '18_usa/NYC',
            simple_logo: '18_usa/NYC.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#110a0c',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'N&W',
            name: 'Norfolk and Western Railway',
            logo: '18_usa/NW',
            simple_logo: '18_usa/NW.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'DarkRed',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'NP',
            name: 'Northern Pacific Railway',
            logo: '18_usa/NP',
            simple_logo: '18_usa/NP.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_usa/PRR',
            simple_logo: '18_usa/PRR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'YellowGreen',
            text_color: 'Black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SP',
            name: 'Southern Pacific Railroad',
            logo: '18_usa/SP',
            simple_logo: '18_usa/SP.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_usa/SR',
            simple_logo: '18_usa/SR.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'ForestGreen',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SLSF',
            name: 'St. Louis-San Francisco Railway',
            logo: '18_usa/SLSF',
            simple_logo: '18_usa/SLSF.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: '#d02020',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'TP',
            name: 'Texas and Pacific Railway',
            logo: '18_usa/TP',
            simple_logo: '18_usa/TP.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Purple',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'UP',
            name: 'Union Pacific Railroad',
            logo: '18_usa/UP',
            simple_logo: '18_usa/UP.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Gold',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'WP',
            name: 'Western Pacific Railroad',
            logo: '18_usa/WP',
            simple_logo: '18_usa/WP.alt',
            shares: [100],
            max_ownership_percent: 100,
            tokens: [0],
            always_market_price: true,
            color: 'Brown',
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
