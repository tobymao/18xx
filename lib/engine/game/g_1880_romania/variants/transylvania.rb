# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Transylvania
        HEXES = {
          red: {
            ['A17'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0,terminal:1',
            ['G11'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_50,hide:1,groups:Istanbul;'\
                       'path=a:3,b:_0,terminal:1;border=edge:4',
            ['G13'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_50,groups:Istanbul;'\
                       'path=a:2,b:_0,terminal:1;border=edge:1',
          },
          gray: {
            ['B16'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
            ['F16'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:2,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'G11' => 'Istanbul',
        }.freeze

        COMPANIES = %w[P1 P3 P5 P8].freeze

        CORPORATIONS = %w[BR CR SZ TR].freeze

        MINORS = %w[1 4 5].freeze

        MINOR_COORDINATES = {}.freeze

        TRAIN_COUNTS = {
          '2' => 6,
          '2+2' => 3,
          '3' => 3,
          '3+3' => 2,
          '4' => 2,
          '4+4' => 2,
          '6' => 2,
          '6E' => 1,
          '8' => 1,
        }.freeze

        STARTING_CASH = { 2 => 350 }.freeze

        CERT_LIMIT = { 2 => 11 }.freeze
      end
    end
  end
end
