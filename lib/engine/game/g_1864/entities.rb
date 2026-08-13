# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module Entities
        CORPORATE_LOBBYISTS = 'Corporate Lobbyists'.freeze
        GOVERNMENT_SUBSIDY = 'U.S. Government Subsidy'.freeze
        TRACK_BUILDER = 'Track Builder'.freeze
        LOCAL_CONTRACT = 'Local Contract'.freeze
        ANGEL_INVESTORS = 'Angel Investors'.freeze
        UNION_STATION = 'Union Station'.freeze
        CENTRAL_STATION = 'Central Station'.freeze
        EARLY_ADOPTER = 'Early Adopter'.freeze
        CIVIL_ENGINEERING_FIRM = 'Civil Engineering Firm'.freeze
        DOUBLE_TRACKS = 'Double Tracks'.freeze
        PULLMAN_CAR = 'Pullman Car'.freeze
        EXTRA_STATION_CARDS = [UNION_STATION, CENTRAL_STATION].freeze
        EARLY_ADOPTER_MAX_INDEX = 10

        COMPANIES = [
          {
            name: CORPORATE_LOBBYISTS,
            sym: 'CL1',
            value: 0,
            revenue: 0,
            desc: 'The company may exceed the current train limit by one train.',
            abilities: [{ type: 'train_limit', increase: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: CORPORATE_LOBBYISTS,
            sym: 'CL2',
            value: 0,
            revenue: 0,
            desc: 'The company may exceed the current train limit by one train.',
            abilities: [{ type: 'train_limit', increase: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: GOVERNMENT_SUBSIDY,
            sym: 'GS1',
            value: 0,
            revenue: 0,
            desc: 'At the start of each Operating Round, the Bank pays $20 to the treasury of the company.',
            color: nil,
          },
          {
            name: GOVERNMENT_SUBSIDY,
            sym: 'GS2',
            value: 0,
            revenue: 0,
            desc: 'At the start of each Operating Round, the Bank pays $20 to the treasury of the company.',
            color: nil,
          },
          {
            name: TRACK_BUILDER,
            sym: 'TB1',
            value: 0,
            revenue: 0,
            desc: 'The additional yellow tile placement costs nothing. The Bank pays the $20 to Credit Mobilier.',
            color: nil,
          },
          {
            name: TRACK_BUILDER,
            sym: 'TB2',
            value: 0,
            revenue: 0,
            desc: 'The additional yellow tile placement costs nothing. The Bank pays the $20 to Credit Mobilier.',
            color: nil,
          },
          {
            name: LOCAL_CONTRACT,
            sym: 'LC1',
            value: 0,
            revenue: 0,
            desc: 'Place a +$10 marker on one station of this company; that city pays $10 more.',
            color: nil,
          },
          {
            name: LOCAL_CONTRACT,
            sym: 'LC2',
            value: 0,
            revenue: 0,
            desc: 'Place a +$10 marker on one station of this company; that city pays $10 more.',
            color: nil,
          },
          {
            name: ANGEL_INVESTORS,
            sym: 'AI1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with an additional $60 in its treasury.',
            color: nil,
          },
          {
            name: ANGEL_INVESTORS,
            sym: 'AI2',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with an additional $60 in its treasury.',
            color: nil,
          },
          {
            name: UNION_STATION,
            sym: 'US1',
            value: 0,
            revenue: 0,
            desc: 'An additional station token which may be placed for $10 per hexagon.',
            abilities: [{ type: 'additional_token', count: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: CENTRAL_STATION,
            sym: 'CS1',
            value: 0,
            revenue: 0,
            desc: 'An additional station token which may be placed for $10 per hexagon.',
            abilities: [{ type: 'additional_token', count: 1, owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: EARLY_ADOPTER,
            sym: 'EA1',
            value: 0,
            revenue: 0,
            desc: 'The company begins play with a 2-train and pays $100 for it when it floats.',
            color: nil,
          },
          {
            name: CIVIL_ENGINEERING_FIRM,
            sym: 'CE1',
            value: 0,
            revenue: 0,
            desc: 'Terrain costs are free. The Bank pays the full terrain cost to Credit Mobilier.',
            color: nil,
          },
          {
            name: DOUBLE_TRACKS,
            sym: 'DT1',
            value: 0,
            revenue: 0,
            desc: 'Two trains of this company may share some or all track on their routes.',
            color: nil,
          },
          {
            name: PULLMAN_CAR,
            sym: 'PC1',
            value: 0,
            revenue: 0,
            desc: 'One train may serve an additional two small stations without counting them as stops.',
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

        YELLOW_RESERVATION = '#ffe600'

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
          float_percent: 10,
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
               .merge(reservation_color: corporation[:reservation_color] || YELLOW_RESERVATION)
           end + [UNION_PACIFIC]).freeze
      end
    end
  end
end
