# frozen_string_literal: true

module Engine
  module Game
    module G18EU
      module Market
        CURRENCY_FORMAT_STR = '£%d'
        BANK_CASH = 12_000
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = true
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 750, 3 => 450, 4 => 350, 5 => 300, 6 => 250 }.freeze

        MARKET = [
          %w[82
             90
             100
             110
             122
             135
             150
             165
             180
             200
             225
             245
             270
             300
             330
             360
             400],
          %w[75
             82
             90
             100
             110
             122
             135
             150
             165
             180
             200
             225
             245
             270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
        ].freeze
      end
    end
  end
end
