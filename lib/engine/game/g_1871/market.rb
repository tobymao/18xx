# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Market
        MARKET = [
          ['', '', '111', '122', '136', '152', '170', '190', '215', '240', '270', '300', '330', '360', '400o'],
          %w[88 92 100 110 121 133 146 160 180 200 225 250 280],
          %w[82 86 93 101 111 123 137 152 167 185 203],
          %w[78 80p 86 94 102 112 122],
          %w[71 74x 79 84 89 94],
          %w[60 65z 69 73 78],
          %w[55 58w 61 65],
        ].freeze

        # We use par, par_1, par_2, par_3 for our four par options. Use orange
        # as the 400+40 end square just cause...
        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Par value until 5H',
                                              par_1: 'Par value until 3+',
                                              par_2: 'Par value until 7',
                                              par_3: 'Par value',
                                              unlimited: 'Stock bumps increase run value by $40').freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow,
                                                            par_1: :green,
                                                            par_2: :blue,
                                                            par_3: :red).freeze
      end
    end
  end
end
