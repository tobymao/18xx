# frozen_string_literal: true

module Engine
  module Game
    module G18India
      module Entities
        COMPANIES = [
          {
            name: 'Swedish EIC',
            sym: 'P1',
            value: 25,
            revenue: 5,
            desc: 'No special abilities.',
            color: nil,
            type: :private,
          },
          {
            name: 'Portuguese EIC',
            sym: 'P2',
            value: 35,
            revenue: 5,
            desc: 'One extra yellow tile placement. Close when used.',
            color: nil,
            type: :private,
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: %w[track special_track],
                lay_count: 1,
                upgrade_count: 0,
                reachable: true,
                special: false,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
              {
                type: 'tile_lay',
                owner_type: 'player',
                when: 'owning_player_or_turn',
                lay_count: 1,
                upgrade_count: 0,
                reachable: true,
                special: false,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
            ],
          },
          {
            name: 'Dutch EIC',
            sym: 'P3',
            value: 60,
            revenue: 10,
            desc: 'One extra track upgade. Close when used.',
            color: nil,
            type: :private,
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: %w[track special_track],
                count: 1,
                lay_count: 0,
                upgrade_count: 1,
                reachable: true,
                special: false,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
              {
                type: 'tile_lay',
                owner_type: 'player',
                when: 'owning_player_or_turn',
                count: 1,
                lay_count: 0,
                upgrade_count: 1,
                reachable: true,
                special: false,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
            ],
          },
          {
            name: 'French EIC',
            sym: 'P4',
            value: 75,
            revenue: 15,
            desc: 'A ₹40 discount on total terrain cost during an OR. Close when used.',
            color: nil,
            type: :private,
            abilities: [
              {
                type: 'choose_ability',
                owner_type: 'corporation',
                when: %w[track special_track],
                choices: { use: 'Use discount and close' },
                count: 1,
              },
              {
                type: 'choose_ability',
                owner_type: 'player',
                when: 'owning_player_track',
                choices: { use: 'Use discount and close' },
                count: 1,
              },
            ],
          },
          {
            name: 'Danish EIC',
            sym: 'P5',
            value: 115,
            revenue: 20,
            desc: 'One free station, even if full. Close when used.',
            color: nil,
            type: :private,
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                when: %w[token special_token],
                count: 1,
                extra_action: false,
                from_owner: true,
                cheater: 1,
                special_only: true,
                price: 0,
                discount: 100,
                teleport_price: 0,
                closed_when_used_up: true,
                hexes: [],
              },
              {
                type: 'token',
                owner_type: 'player',
                when: 'owning_player_token',
                count: 1,
                extra_action: false,
                from_owner: true,
                cheater: 1,
                special_only: true,
                price: 0,
                discount: 100,
                teleport_price: 0,
                closed_when_used_up: true,
                hexes: [],
              },
            ],
          },
          {
            name: 'British EIC',
            sym: 'P6',
            value: 150,
            revenue: 25,
            desc: 'Receives jewlery concession. Close when used.',
            color: nil,
            type: :private,
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_player_or_turn',
                hexes: [], # any hex w/o city or town
                count: 1,
                owner_type: 'player',
                closed_when_used_up: true,
              },
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: [], # any hex w/o city or town
                count: 1,
                owner_type: 'corporation',
                closed_when_used_up: true,
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            name: 'Great Indian Peninsula Railway',
            sym: 'GIPR',
            logo: '18_india/GIPR',
            simple_logo: '18_india/GIPR.alt',
            # No president cert / Pres cert is 10%
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100],
            # Add Exchange Tokens
            floatable: false, # Can not float / operate until phase II
            min_price: 112,
            float_percent: 30,
            max_ownership_percent: 200,
            # Can start in any open city
            color: 'white',
            text_color: 'black',
          },
          {
            name: 'Northwestern Railway',
            sym: 'NWR',
            logo: '18_india/NWR',
            simple_logo: '18_india/NWR.alt',
            tokens: [0, 40, 100, 100],
            min_price: 100,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'G8', # Delhi
            city: 0,
            color: '#48bc39', # green
          },
          {
            name: 'East India Railway',
            sym: 'EIR',
            logo: '18_india/EIR',
            simple_logo: '18_india/EIR.alt',
            tokens: [0, 40, 100],
            min_price: 100,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'P17', # Kolkata
            city: 0,
            color: '#f14324', # orange
          },
          {
            name: 'North Central Railway',
            sym: 'NCR',
            logo: '18_india/NCR',
            simple_logo: '18_india/NCR.alt',
            tokens: [0, 40, 100, 100],
            min_price: 90,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'K14', # Allahabad
            color: '#d8ba9e', # light brown / tan
          },
          {
            name: 'Madras Railway',
            sym: 'MR',
            logo: '18_india/MR',
            simple_logo: '18_india/MR.alt',
            tokens: [0, 40, 100],
            min_price: 90,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'K30', # Chennai
            color: '#fccd1c', # yellow
          },
          {
            name: 'South Indian Railway',
            sym: 'SIR',
            logo: '18_india/SIR',
            simple_logo: '18_india/SIR.alt',
            tokens: [0, 40, 100, 100],
            min_price: 82,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'G36', # Kochi
            color: '#702f2b', # dark red/brown
          },
          {
            name: 'Bengal Nagpur Railway',
            sym: 'BNR',
            logo: '18_india/BNR',
            simple_logo: '18_india/BNR.alt',
            tokens: [0, 40, 100, 100, 100],
            min_price: 82,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'I20', # Nagpur
            color: '#c4711c',
          },
          {
            name: 'Ceylon Government Railway',
            sym: 'CGR',
            logo: '18_india/CGR',
            simple_logo: '18_india/CGR.alt',
            tokens: [0, 40, 100],
            min_price: 76,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'K40', # Colombo
            color: '#967ac4', # Light Purple
          },
          {
            name: 'Punjab Northern State Railway',
            sym: 'PNS',
            logo: '18_india/PNS',
            simple_logo: '18_india/PNS.alt',
            tokens: [0, 40, 100],
            min_price: 76,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'D3', # Lahore
            color: '#9fc322', # light green
          },
          {
            name: 'West of India Portuguese Railway',
            sym: 'WIP',
            logo: '18_india/WIP',
            simple_logo: '18_india/WIP.alt',
            tokens: [0, 40, 100],
            min_price: 76,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'E24', # Pune
            color: '#f24780', # pink
          },
          {
            name: 'Eastern Bengal Railway',
            sym: 'EBR',
            logo: '18_india/EBR',
            simple_logo: '18_india/EBR.alt',
            tokens: [0, 40, 100],
            min_price: 76,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'P17', # Kolkata
            city: 1,
            color: '#72818e', # gray
          },
          {
            name: 'Bombay Railway',
            sym: 'BR',
            logo: '18_india/BR',
            simple_logo: '18_india/BR.alt',
            tokens: [0, 40, 100],
            min_price: 71,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'D23', # Mumbai
            color: '#6046a6',
          },
          {
            name: 'Nizam State Railway',
            sym: 'NSR',
            logo: '18_india/NSR',
            simple_logo: '18_india/NSR.alt',
            tokens: [0, 40, 100],
            min_price: 71,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'H25', # Hyderabad
            color: '#458dd3', # medium blue
          },
          {
            name: 'Tirhoot Railway',
            sym: 'TR',
            logo: '18_india/TR',
            simple_logo: '18_india/TR.alt',
            tokens: [0, 40],
            min_price: 71,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'M10', # Nepal
            color: '#100e0d', # black
          },
          {
            name: 'Sind Punjab & Delhi Railroad',
            sym: 'SPD',
            logo: '18_india/SPD',
            simple_logo: '18_india/SPD.alt',
            tokens: [0, 40],
            min_price: 67,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'G8', # Delhi
            city: 1,
            color: '#c3b07a', # tan
          },
          {
            name: 'Darjeeling-Himalayan Railway',
            sym: 'DHR',
            logo: '18_india/DHR',
            simple_logo: '18_india/DHR.alt',
            tokens: [0, 40],
            min_price: 67,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'Q10', # China
            color: '#2c8e48', # dark green
          },
          {
            name: 'Western Railway',
            sym: 'WR',
            logo: '18_india/WR',
            simple_logo: '18_india/WR.alt',
            tokens: [0, 40],
            min_price: 64,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'D17', # Ahmedabad
            color: '#3766ba', # dark blue
          },
          {
            name: 'Kolar Gold Fields Railways',
            sym: 'KGF',
            logo: '18_india/KGF',
            simple_logo: '18_india/KGF.alt',
            tokens: [0, 40],
            min_price: 64,
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'H31', # Bengaluru
            color: '#da193a', # red
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [
              { 'nodes' => ['city'], 'pay' => 2, 'visit' => 2 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            price: 180,
            salvage: 180,
            num: 6,
          },
          {
            name: '3',
            distance: [
              { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            price: 300,
            salvage: 300,
            num: 4,
          },
          {
            name: '4',
            distance: [
              { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            price: 450,
            salvage: 300,
            variants: [
              {
                name: '4E',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 4, 'visit' => 99 },
                  { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                ],
                price: 450,
                salvage: 300,
              },
            ],
            num: 3,
          },
          {
            name: '3x2',
            available_on: "III'",
            distance: [
              { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            multiplier: 2,
            price: 700,
            salvage: 500,
            num: 3,
          },
          {
            name: '3x3',
            available_on: "III'",
            distance: [
              { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            multiplier: 3,
            price: 900,
            salvage: 700,
            num: 3,
          },
          {
            name: '4x2',
            available_on: "III'",
            distance: [
              { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            multiplier: 2,
            price: 800,
            salvage: 650,
            variants: [
              {
                name: '4Ex2',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 4, 'visit' => 99 },
                  { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                ],
                multiplier: 2,
                price: 800,
                salvage: 650,
              },
            ],
            num: 3,
          },
          {
            name: '4x3',
            available_on: "III'",
            distance: [
              { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
            ],
            multiplier: 3,
            price: 1100,
            salvage: 0,
            variants: [
              {
                name: '4Ex3',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 4, 'visit' => 99 },
                  { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                ],
                multiplier: 3,
                price: 1100,
              },
            ],
            num: 3,
          },
        ].freeze
      end
    end
  end
end
