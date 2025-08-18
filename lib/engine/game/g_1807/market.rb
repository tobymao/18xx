# frozen_string_literal: true

module Engine
  module Game
    module G1807
      module Market
        CURRENCY_FORMAT_STR = '£%d'
        BANK_CASH = 20_000
        STARTING_CASH = { 3 => 630, 4 => 470, 5 => 375 }.freeze
        CERT_LIMIT = { 3 => 32, 4 => 24, 5 => 19 }.freeze
        CERT_LIMIT_PHASE7 = { 3 => 21, 4 => 16, 5 => 13 }.freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          close: 'Company closes',
          par_1: 'Minor company par prices',
          par_2: 'Public company par prices',
          par: 'Minor/public company par prices',
          convert_range: 'Price range to convert minor to public company',
          max_price: 'Maximum price for a minor company'
        ).freeze

        COLUMN_MARKET = [
          %w[
            0c
            40
            45
            50x
            55x
            60x
            65x
            70p
            80p
            90p
            100pC
            110pC
            120pC
            135pC
            150zC
            165mzC
            180z
            200z
            220
            245
            270
            300
            330
            360
            400
            440
            490
            540
            500
            660
            720
            800
          ],
        ].freeze
      end
    end
  end
end
