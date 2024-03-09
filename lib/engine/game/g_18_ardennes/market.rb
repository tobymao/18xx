# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Market
        CURRENCY_FORMAT_STR = '%d F'
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 11, 4 => 8, 5 => 6 }.freeze
        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 420 }.freeze
        SOLD_OUT_INCREASE = false

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par_1: :red,
          par_2: :blue,
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par_1: 'Minor company starting values',
          par_2: 'Major company starting values',
          repar: 'Minor companies cannot merge'
        )
        MARKET = [%w[0r 50x 55x 60x 70x 80x 90x 100 110 120 140z 160z 180z 200z 220z 240 260 280 300 320 340 360 380 400]].freeze
      end
    end
  end
end
