# frozen_string_literal: true

require_relative '../g_1861/entities'

module Engine
  module Game
    module G1864
      module Entities
        COMPANIES = [
          {
            name: 'Corporate Lobbyists',
            sym: 'CL1',
            value: 0,
            revenue: 0,
            desc: 'The company may exceed the current train limit by one train.',
            abilities: [{ type: 'train_limit', increase: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Corporate Lobbyists',
            sym: 'CL2',
            value: 0,
            revenue: 0,
            desc: 'The company may exceed the current train limit by one train.',
            abilities: [{ type: 'train_limit', increase: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'U.S. Government Subsidy',
            sym: 'GS1',
            value: 0,
            revenue: 20,
            desc: 'At the start of each Operating Round, the Bank pays $20 to the treasury of the company.',
            color: nil,
          },
          {
            name: 'U.S. Government Subsidy',
            sym: 'GS2',
            value: 0,
            revenue: 20,
            desc: 'At the start of each Operating Round, the Bank pays $20 to the treasury of the company.',
            color: nil,
          },
          {
            name: 'Track Builder',
            sym: 'TB1',
            value: 0,
            revenue: 0,
            desc: 'The additional tile placement costs nothing. The Bank pays the $20 to Credit Mobilier.',
            color: nil,
          },
          {
            name: 'Track Builder',
            sym: 'TB2',
            value: 0,
            revenue: 0,
            desc: 'The additional tile placement costs nothing. The Bank pays the $20 to Credit Mobilier.',
            color: nil,
          },
          {
            name: 'Local Contract',
            sym: 'LC1',
            value: 0,
            revenue: 0,
            desc: 'Place a +$10 marker on one station of this company; that city pays $10 more '\
                  '(doubled for 2+2 and 5+5E trains).',
            abilities: [{ type: 'assign_hexes', hexes: [], count: 1, owner_type: 'corporation', when: 'owning_corp_or_turn' }],
            color: nil,
          },
          {
            name: 'Local Contract',
            sym: 'LC2',
            value: 0,
            revenue: 0,
            desc: 'Place a +$10 marker on one station of this company; that city pays $10 more '\
                  '(doubled for 2+2 and 5+5E trains).',
            abilities: [{ type: 'assign_hexes', hexes: [], count: 1, owner_type: 'corporation', when: 'owning_corp_or_turn' }],
            color: nil,
          },
          {
            name: 'Angel Investors',
            sym: 'AI1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with an additional $60 in its treasury.',
            color: nil,
          },
          {
            name: 'Angel Investors',
            sym: 'AI2',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with an additional $60 in its treasury.',
            color: nil,
          },
          {
            name: 'Union Station',
            sym: 'US1',
            value: 0,
            revenue: 0,
            desc: 'An additional station token which may be placed for $10 per hexagon. It is removed at Phase 6.',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                hexes: [],
                price: 10,
                connected: true,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Central Station',
            sym: 'CS1',
            value: 0,
            revenue: 0,
            desc: 'An additional station token which may be placed for $10 per hexagon. It is removed at Phase 6.',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                hexes: [],
                price: 10,
                connected: true,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Early Adopter',
            sym: 'EA1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with a 2-train and pays $100 for it when it floats.',
            color: nil,
          },
          {
            name: 'Civil Engineering Firm',
            sym: 'CE1',
            value: 0,
            revenue: 0,
            desc: 'Terrain costs are free. The Bank pays the full terrain cost to Credit Mobilier.',
            color: nil,
          },
          {
            name: 'Double Tracks',
            sym: 'DT1',
            value: 0,
            revenue: 0,
            desc: 'Two trains of this company may share some or all track on their routes.',
            color: nil,
          },
          {
            name: 'Pullman Car',
            sym: 'PC1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with the Pullman, which lets one train serve an additional two small '\
                  'stations without counting them as stops. It may be bought by another company for a minimum of $1.',
            color: nil,
          },
        ].freeze

        MINOR_HOMES = {
          'RO' => { coordinates: 'C18' },                # Billings
          'KB' => { coordinates: 'B23' },                # Bismarck
          'OK' => { coordinates: 'J25' },                # Oklahoma City
          'KK' => { coordinates: 'G20', city: 2 },       # Denver
          'SPW' => { coordinates: 'G2' },                # San Francisco
          'MB' => { coordinates: 'K12' },                # Phoenix
          'KR' => { coordinates: 'G14', city: 1 },       # Salt Lake City
          'N' => { coordinates: 'F27' },                 # Omaha
          'Y' => { coordinates: 'D11', city: 0 },        # Boise
          'M-K' => { coordinates: 'G20', city: 0 },      # Denver
          'MNN' => { coordinates: 'G14', city: 0 },      # Salt Lake City
          'MV' => { coordinates: 'J19' },                # Santa Fe
          'V' => { coordinates: 'B5' },                  # Seattle
          'TR' => { coordinates: 'G20', city: 1 },       # Denver
          'SV' => { coordinates: 'J5' },                 # Los Angeles
          'E' => { coordinates: 'D5' },                  # Eugene
        }.freeze

        MINORS = [
          {
            sym: 'CM',
            name: 'Crédit Mobilier',
            logo: '1864/CM',
            simple_logo: '1864/CM',
            tokens: [],
            color: '#5b4636',
            text_color: 'white',
            abilities: [
              {
                type: 'description',
                description: 'Collects extra-tile and terrain costs',
                desc_detail: 'Every $20 extra yellow tile cost and every terrain cost is paid here; the Bank pays any '\
                             'amount waived by a Minor Company Ability. Immediately before each Merger Round the '\
                             'money is divided equally among the players, with any remainder staying here. Closes at '\
                             'Phase 4, returning its money to the Bank.',
              },
            ],
          },
        ].freeze

        UNION_PACIFIC = {
          sym: 'UP',
          coordinates: 'F27',
          name: 'Union Pacific Railroad',
          logo: '1864/UP',
          simple_logo: '1864/UP.alt',
          tokens: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
          max_ownership_percent: 60,
          always_market_price: true,
          type: 'national',
          color: '#c8102e',
          text_color: 'white',
        }.freeze

        CORPORATIONS =
          (G1861::Entities::CORPORATIONS.reject { |c| c[:sym] == 'RSR' }.map do |corporation|
             home = MINOR_HOMES[corporation[:sym]]
             next corporation unless home

             corporation
               .except(:city)
               .merge(home)
               .merge(reservation_color: corporation[:reservation_color] || :yellow)
           end + [UNION_PACIFIC]).freeze
      end
    end
  end
end
