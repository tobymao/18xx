# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module KingdomOfRomania
        HEXES = {
          red: {
            ['G9'] => 'city=revenue:yellow_20|green_30|brown_50|gray_70;path=a:4,b:_0,terminal:1;'\
                      'path=a:5,b:_0,terminal:1;path=a:0,b:_0,terminal:1',
            ['B16'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0,terminal:1;'\
                       'path=a:4,b:_0,terminal:1',
          },
          white: {
            ['H8'] => 'town=revenue:0;town=revenue:0;city=revenue:0;city=revenue:0',
            ['I7'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
          },
        }.freeze

        LOCATION_NAMES = {
          'B16' => 'Cluj-Napoca',
          'G9' => 'Viena / Budapešta',
        }.freeze

        COMPANIES = %w[P1 P4 P5 P6 P7].freeze

        CORPORATIONS = %w[Bess CFR DR GWR LCR LWR MR VRL].freeze

        MINORS = %w[1 2 3 6].freeze

        MINOR_COORDINATES = { '1' => 'G9' }.freeze

        TRAIN_COUNTS = {
          '2' => 8,
          '2+2' => 4,
          '3' => 4,
          '3+3' => 4,
          '4' => 4,
          '4+4' => 4,
          '6' => 2,
          '6E' => 1,
          '8' => 1,
        }.freeze

        STARTING_CASH = { 2 => 700, 3 => 500 }.freeze

        CERT_LIMIT = { 2 => 22, 3 => 18 }.freeze
      end
    end
  end
end
