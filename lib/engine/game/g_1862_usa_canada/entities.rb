# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Entities
        # ---------------------------------------------------------------------------
        # Private Companies (P1–P8)
        # Auctioned in first stock round only; unsellable to corporations; no end value.
        # ---------------------------------------------------------------------------
        COMPANIES = [
          {
            name: 'Butterfield Overland Mail',
            sym: 'BOM',
            value: 20,
            revenue: 5,
            desc: 'No special abilities. Income only.',
            color: nil,
          },
          {
            name: 'Toronto Steamship Company',
            sym: 'TOR',
            value: 50,
            revenue: 10,
            desc: 'Blocks the Toronto hex while owned by a player. The owning corporation '\
                  'may place the special Toronto gray tile on the Toronto hex at any time '\
                  'when acting (free, no connection required). Closes when placed.',
            abilities: [
              { type: 'blocks_hexes', owner_type: 'player', hexes: ['E25'] },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                hexes: ['E25'],
                tiles: ['GS_TOR'],
                when: 'any',
                count: 1,
                free: true,
                closed_when_used_up: true,
              },
            ],
            color: nil,
          },
          {
            name: 'Bahnhoflizenz',
            sym: 'GHU',
            value: 75,
            revenue: 15,
            desc: 'The owning corporation\'s director may place a station token for $80 '\
                  'less than the normal cost (minimum $0).',
            abilities: [
              {
                type: 'tile_discount',
                discount: 80,
                terrain: 'station',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Rocky Mountain Company',
            sym: 'RMC',
            value: 100,
            revenue: 20,
            desc: 'The owning corporation may lay one additional yellow tile during its '\
                  'operating turn. This ability is one-time use and closes the company.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                hexes: [],
                tiles: [],
                when: 'owning_corp_or_turn',
                count: 1,
                closed_when_used_up: true,
                special: false,
                free: false,
              },
            ],
            color: nil,
          },
          {
            name: 'Pacific Steamship Company',
            sym: 'PSC',
            value: 140,
            revenue: 25,
            desc: 'The initial purchaser immediately receives a 10% share of WP. '\
                  'Closes when WP first pays a dividend.',
            abilities: [
              { type: 'shares', shares: 'WP_1' },
              # Custom close trigger: when WP pays first dividend — handled in game.rb
            ],
            color: nil,
          },
          {
            name: 'First New York Steamship Co.',
            sym: 'FNY',
            value: 180,
            revenue: 30,
            desc: 'The initial purchaser immediately receives a 10% share of NYC. '\
                  'Closes when NYC first pays a dividend.',
            abilities: [
              { type: 'shares', shares: 'NYC_1' },
              # Custom close trigger: when NYC pays first dividend — handled in game.rb
            ],
            color: nil,
          },
          {
            name: 'Sacramento-Omaha Company',
            sym: 'SOC',
            value: 220,
            revenue: 35,
            desc: 'The initial purchaser immediately receives a 10% share of CPR and '\
                  'a 10% share of UP. Closes when either CPR or UP floats. '\
                  'While open, reduces the UP/CPR Salt Lake City route bonus payout to $15.',
            abilities: [
              { type: 'shares', shares: %w[CPR_1 UP_1] },
              # Custom close trigger: when CPR or UP floats — handled in game.rb
            ],
            color: nil,
          },
          {
            name: 'New Haven Steamship Company',
            sym: 'NHSC',
            value: 270,
            revenue: 40,
            desc: "The initial purchaser immediately receives the 30% Director's "\
                  'certificate of NYH. NYH must be parred at exactly $100. '\
                  'Closes when NYH floats.',
            abilities: [
              { type: 'shares', shares: 'NYH_0' },
              { type: 'no_buy' },
              # Custom close trigger: when NYH floats — handled in game.rb
              # Custom par restriction: NYH par locked to $100 — handled in game.rb
            ],
            color: nil,
          },
        ].freeze

        # ---------------------------------------------------------------------------
        # Corporations — 3 groups, unlocked progressively:
        #   Group 1 (NYH, NYC, CP)  : available from game start
        #   Group 2 (CPR, UP, ATS, SP) : unlocked when ALL Group 1 companies float
        #   Group 3 (NP, CN, TP, ORN, WP, GMO) : unlocked when ALL Group 2 companies float
        #
        # Share structures:
        #   Group 1: 30% Director cert + 7 × 10% = 100%  (float at 60%)
        #   Group 2/3: 20% Director cert + 8 × 10% = 100% (float at 60%)
        #
        # FIXME: All hex coordinates are placeholders — update when map.rb is complete.
        # ---------------------------------------------------------------------------
        CORPORATIONS = [
          # -------------------------------------------------------------------------
          # Group 1 — 30% Director, float at 60%
          # -------------------------------------------------------------------------
          {
            sym: 'NYH',
            name: 'New York New Haven',
            logo: '1862_usa_canada/NYH',
            simple_logo: '1862_usa_canada/NYH.alt',
            float_percent: 60,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'F28',
            city: 1,
            color: '#d1232a',
            text_color: 'white',
          },
          {
            sym: 'NYC',
            name: 'New York Central',
            logo: '1862_usa_canada/NYC',
            simple_logo: '1862_usa_canada/NYC.alt',
            float_percent: 60,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'F28',
            city: 0,
            color: '#110a0c',
            text_color: 'white',
          },
          {
            sym: 'CP',
            name: 'Canadian Pacific',
            logo: '1862_usa_canada/CP',
            simple_logo: '1862_usa_canada/CP.alt',
            float_percent: 60,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'D28',
            color: '#d88e39',
            text_color: 'black',
          },

          # -------------------------------------------------------------------------
          # Group 2 — 20% Director, float at 60%
          # -------------------------------------------------------------------------
          {
            sym: 'CPR',
            name: 'Central Pacific Railroad',
            logo: '1862_usa_canada/CPR',
            simple_logo: '1862_usa_canada/CPR.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'G3',
            city: 0,
            color: '#f48221',
            text_color: 'black',
          },
          {
            sym: 'UP',
            name: 'Union Pacific',
            logo: '1862_usa_canada/UP',
            simple_logo: '1862_usa_canada/UP.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'F14',
            color: '#025aaa',
            text_color: 'white',
          },
          {
            sym: 'ATS',
            name: 'Atchison Topeka & Santa Fe',
            logo: '1862_usa_canada/ATS',
            simple_logo: '1862_usa_canada/ATS.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'F20',
            color: '#32763f',
            text_color: 'white',
          },
          {
            sym: 'SP',
            name: 'Southern Pacific',
            logo: '1862_usa_canada/SP',
            simple_logo: '1862_usa_canada/SP.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'K19',
            color: '#76a042',
            text_color: 'black',
          },

          # -------------------------------------------------------------------------
          # Group 3 — 20% Director, float at 60%
          # -------------------------------------------------------------------------
          {
            sym: 'NP',
            name: 'Northern Pacific',
            logo: '1862_usa_canada/NP',
            simple_logo: '1862_usa_canada/NP.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'D16',
            color: '#95c054',
            text_color: 'black',
          },
          {
            sym: 'CN',
            name: 'Canadian National',
            logo: '1862_usa_canada/CN',
            simple_logo: '1862_usa_canada/CN.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'B14',
            color: '#ADD8E6',
            text_color: 'black',
          },
          {
            sym: 'TP',
            name: 'Texas Pacific',
            logo: '1862_usa_canada/TP',
            simple_logo: '1862_usa_canada/TP.alt',
            float_percent: 60,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'J16',
            color: '#7b352a',
            text_color: 'white',
          },
          {
            sym: 'ORN',
            name: 'Oregon Railroad & Navigation',
            logo: '1862_usa_canada/ORN',
            simple_logo: '1862_usa_canada/ORN.alt',
            float_percent: 60,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'C3',
            color: '#FFF500',
            text_color: 'black',
          },
          {
            # WP co-homes in Sacramento (slot 1) alongside CPR (slot 0).
            # Both transcontinental roads originate from the Sacramento terminus.
            sym: 'WP',
            name: 'Western Pacific',
            logo: '1862_usa_canada/WP',
            simple_logo: '1862_usa_canada/WP.alt',
            float_percent: 60,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'G3',
            city: 1,
            color: '#8dd7f6',
            text_color: 'black',
          },
          {
            sym: 'GMO',
            name: 'Gulf Mobile & Ohio',
            logo: '1862_usa_canada/GMO',
            simple_logo: '1862_usa_canada/GMO.alt',
            float_percent: 60,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'J20',
            color: '#6ec037',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
