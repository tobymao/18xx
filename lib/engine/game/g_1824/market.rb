# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module Market
        MARKET = [
          %w[100 110 120 130 140 155 170 190 210 235 260 290 320 350],
          %w[90 100 110 120 130 145 160 180 200 225 250 280 310 340],
          %w[80 90 100p 110 120 135 150 170 190 215 240 270 300 330],
          %w[70 80 90p 100 110 125 140 160 180 200 220],
          %w[60 70 80p 90 100 115 130 150 170],
          %w[50 60 70p 80 90 105 120],
          %w[40 50 60p 70 80],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Regional Railways Par')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :pink).freeze
      end
    end
  end
end
