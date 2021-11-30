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
            name: 'Lehigh Coal Mine Co.',
            value: 30,
            revenue: 0,
            desc: 'Comes with one coal mine marker. When placing a yellow '\
                  'tile in a coal hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P1',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: %w[7coal 8coal 9coal],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: 'white',
          },
          # P2
          # TODO: Make it work as a combo with P27
          {
            name: 'Fox Bridge Works',
            value: 40,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city, regardless of connectivity.  Allows owning corp to '\
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
                hexes: BRIDGE_CITY_HEXES + BRIDGE_TILE_HEXES,
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: 'white',
          },
          # P3
          {
            name: 'Reece Oil and Gas',
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
                tiles: %w[7oil 8oil 9oil],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: 'white',
          },
          # P4
          {
            name: 'Hendrickson Iron',
            value: 40,
            revenue: 0,
            desc: 'Comes with one ore marker. When placing a yellow '\
                  'tile in a mining hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  A tile lay action may be used to increase the revenue bonus to $20 in phase 3. '\
                  '  May not start or end a route at an iron mine.',
            sym: 'P4',
            abilities: [
              {
                type: 'tile_lay',
                hexes: IRON_HEXES,
                tiles: %w[7iron10 8iron10 9iron10],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: 'white',
          },
          # P5
          {
            name: 'Nobel\'s Blasting Powder',
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
            color: 'blue',
          },
          # P7
          {
            name: 'Track Engineers',
            value: 40,
            revenue: 0,
            desc: 'May lay two extra yellow tiles instead of one when paying $20.',
            sym: 'P7',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'cyan',
          },
          # P9
          {
            name: 'Boomtown',
            value: 40,
            revenue: 0,
            desc: "Discard during the owning corporation's lay or upgrade track step to upgrade a yellow non-metropolis city "\
                  'to green. This does not count as a normal track laying action. The corporation must have a legal route to '\
                  'the city being upgraded.',
            sym: 'P9',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                when: 'track',
                owner_type: 'corporation',
                closed_when_used_up: true,
                count: 1,
                hexes: [],
                tiles: %w[14 15 619],
              },
            ],
          },
          # P10
          {
            name: 'Carnegie Steel Company',
            value: 40,
            revenue: 0,
            desc: 'If this company starts in an unselected and unimproved metropolis, that city becomes a metropolis. '\
                  'All potential metropolises for this private are: '\
                  'Atlanta, Chicago, Denver, Dallas-Fort Worth, Los Angeles, and New Orleans. ' \
                  'Implementation limitation: Cannot be combined with Boomtown subsidy',

            sym: 'P10',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'cyan',
          },
          # P11
          {
            name: 'Pettibone & Mulliken',
            value: 40,
            revenue: 0,
            desc: 'May upgrade non-city track one color higher than currently allowed. '\
                  ' May make an extra non-city track upgrade (instead of yellow tile lay) per OR when paying $20',
            sym: 'P11',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'cyan',
          },
          # P12
          {
            name: 'Standard Oil Co.',
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
                tiles: %w[7oil 8oil 9oil],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
            color: 'green',
          },
          # P14
          {
            name: 'Pyramid Scheme',
            value: 60,
            revenue: 0,
            desc: 'Does nothing. Min bid of $5',
            sym: 'P14',
            abilities: [],
            color: 'green',
          },
          # P16 Regional Headquarters
          {
            name: 'Regional Headquarters',
            value: 60,
            revenue: 0,
            desc: 'May upgrade a non-metropolis green or brown city to the RHQ tile after phase 5 starts',
            sym: 'P16',
            abilities: [
              # Simply owning this company is the ability
            ],
            color: 'green',
          },
          # P17
          {
            name: 'Great Northern Railway',
            value: 60,
            revenue: 0,
            desc: 'One extra yellow lay per turn on the hexes marked with railroad track icons on the map '\
                  '(near the northern US border), ignoring terrain fees. +$30 revenue bonus per train that runs Fargo - Helena. '\
                  '+$60 revenue bonus per train that runs Seattle-Fargo-Helena-Chicago',
            sym: 'P17',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'green',
          },
          # P18
          {
            name: 'Peabody Coal Company',
            value: 60,
            revenue: 0,
            desc: 'Comes with two coal mine markers. When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P18',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: %w[7coal 8coal 9coal],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 2,
              },
            ],
            color: 'green',
          },
          # P19
          {
            name: 'Union Switch & Signal',
            value: 80,
            revenue: 0,
            desc: 'One train per turn may attach the Switcher to skip over a city (even a blocked city)',
            sym: 'P19',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'yellow',
          },
          # P21
          # TODO: Make it work as a combo with P27
          {
            name: 'Keystone Bridge Co.',
            value: 80,
            revenue: 0,
            desc: 'Comes with one $10 bridge token that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city, regardless of connectivity.  Allows owning corp to '\
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
                hexes: BRIDGE_CITY_HEXES + BRIDGE_TILE_HEXES,
                count: 1,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
              {
                type: 'tile_lay',
                hexes: COAL_HEXES + IRON_HEXES,
                tiles: %w[7coal 8coal 9coal 7iron10 8iron10 9iron10],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: 'yellow',
          },
          # P22
          {
            name: 'American Bridge Company',
            value: 80,
            revenue: 0,
            desc: 'Comes with two $10 bridge tokens that may be placed by the owning '\
                  'corp in a city with $10 water cost, max one token '\
                  'per city, regardless of connectivity..  Allows owning corp to '\
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
                hexes: BRIDGE_CITY_HEXES + BRIDGE_TILE_HEXES,
                count: 2,
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
              },
            ],
            color: 'yellow',
          },
          # P23
          {
            name: 'Bailey Yard',
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
            color: 'yellow',
          },
          # P24
          {
            name: 'Anaconda Copper',
            value: 90,
            revenue: 0,
            desc: 'Comes with two ore markers. When placing a yellow '\
                  'tile in a mining hex pointing to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  A tile lay action may be used to increase the revenue bonus to $20 in phase 3. '\
                  '  May not start or end a route at an iron mine.',
            sym: 'P24',
            abilities: [
              {
                type: 'tile_lay',
                hexes: IRON_HEXES,
                tiles: %w[7iron10 8iron10 9iron10],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 1,
              },
            ],
            color: 'orange',
          },
          # P26
          {
            name: 'Rural Junction',
            value: 90,
            revenue: 0,
            desc: 'Comes with three rural junction tiles. Rural junctions can be placed in empty city hexes and fulfill the '\
                  'revenue center requirement for coal, iron, and oil markers and can receive bridge tokens. Rural junctions '\
                  'are not towns and do not count against the number of stops for a train and furthermore they may not be the '\
                  'start or end of a route. Rural junctions may never be upgraded; a train may not run through the same rural '\
                  'junction twice',
            sym: 'P26',
            abilities: [
              {
                type: 'tile_lay',
                hexes: CITY_HEXES,
                tiles: %w[RuralX RuralY RuralK],
                free: false,
                reachable: true,
                when: 'track',
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
            color: 'orange',
          },
          # P27
          {
            name: 'Company Town',
            value: 90,
            revenue: 0,
            desc: 'Comes with 3 company town tiles, only one of which may be played. The owning corporation may place one '\
                  'Company Town tile on any empty hex not adjacent to a metropolis. When placed, the owning corporation '\
                  'receives one bonus station marker which must be placed on the Company Town tile. No other corporations may '\
                  'place a token on the Company Town hex and receive $10 less for the city than the company with the station '\
                  'marker in the city. The Company Town can be placed on any hex, city circle or not, as long as it is not '\
                  'adjacent to a metropolis and has no track or station marker in it. If the Company Town tile is placed on a '\
                  '$10 river hex, a bridge token may be used. Coal / Oil / Iron markers may not be used with the Company Town. '\
                  'If the station marker in the Company Town hex is ever removed, no token may ever replace it',
            sym: 'P27',
            abilities: [],
            color: 'orange',
          },
          # P28
          {
            name: 'Consolidation Coal Co.',
            value: 90,
            revenue: 0,
            desc: 'Comes with three coal mine markers. When placing a yellow '\
                  'tile in a mountain hex next to a revenue location, can place '\
                  'token to avoid $15 terrain fee.  Marked yellow hexes cannot be '\
                  'upgraded.  Hexes pay $10 extra revenue and do not count as a '\
                  'stop.  May not start or end a route at a coal mine.',
            sym: 'P28',
            abilities: [
              {
                type: 'tile_lay',
                hexes: COAL_HEXES,
                tiles: %w[7coal 8coal 9coal],
                free: false,
                when: 'track',
                discount: 15,
                consume_tile_lay: true,
                closed_when_used_up: true,
                owner_type: 'corporation',
                count: 3,
              },
            ],
            color: 'orange',
          },
          # P29
          {
            name: 'Bankrupt Railroad',
            value: 120,
            revenue: 0,
            desc: 'If this company starts in a city with a No Subsidy tile it immediately takes a free 2-train which it may '\
                  'run in its first OR',
            sym: 'P29',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'red',
          },
          # P30
          {
            name: 'Double Heading',
            value: 120,
            revenue: 0,
            desc: 'Each turn one non-permanent train may attach the Extender to run to one extra city',
            sym: 'P30',
            abilities: [
              # Owning the private is the ability
            ],
            color: 'red',
          },
        ].freeze

        SUBSIDIES = [
          # Temporarily commenting out the first two subsidies to guarantee all "interesting" subsidies
          # come out during randomization during pre-alpha development
          # {
          # icon: 'subsidy_none',
          # abilities: [],
          # id: 'S1',
          # name: 'No Subsidy',
          # desc: 'No effect',
          # value: nil,
          # },
          # {
          # icon: 'subsidy_none',
          # abilities: [],
          # id: 'S2',
          # name: 'No Subsidy'
          # desc: 'No effect',
          # value: nil,
          # },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S3',
            name: 'No Subsidy',
            desc: 'No effect',
            value: nil,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S4',
            name: 'No Subsidy',
            desc: 'No effect',
            value: nil,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S5',
            name: 'No Subsidy',
            desc: 'No effect',
            value: nil,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S6',
            name: 'No Subsidy',
            desc: 'No effect',
            value: nil,
          },
          {
            icon: 'subsidy_none',
            abilities: [],
            id: 'S7',
            name: 'No Subsidy',
            desc: 'No effect',
            value: nil,
          },
          {
            icon: 'subsidy_boomtown',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
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
            name: 'Boomtown',
            desc: 'On it\'s first operating turn, this corporation may upgrade its home to green as a free action. This does '\
                  'not count as an additional track placement and does not incur any cost for doing so',
            value: nil,
          },
          {
            icon: 'subsidy_free_station',
            abilities: [],
            id: 'S9',
            name: 'Free Station',
            desc: 'The free station is a special token (which counts toward the 8 token limit) that can be placed in any city '\
                  'the corporation can trace a legal route to, even if no open station circle is currently available in the '\
                  'city. If a open station circle becomes available later, the token will immediately fill the opening',
            value: nil,
          },
          {
            icon: 'subsidy_plus_ten',
            abilities: [],
            id: 'S10',
            name: '+10',
            desc: 'This corporation\'s home city is worth $10 for the rest of the game',
            value: nil,
          },
          {
            icon: 'subsidy_plus_ten_twenty',
            abilities: [],
            id: 'S11',
            name: '+10 / +20',
            desc: 'This corporation\'s home city is worth $10 until phase 5, after which it is worth '\
                  ' $20 more for the rest of the game',
            value: nil,
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
            abilities: [],
            id: 'S16',
            name: 'Resource Subsidy',
            desc: 'PLACEHOLDER DESCRIPTION',
            value: nil,
          },
        ].freeze

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
