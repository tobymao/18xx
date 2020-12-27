# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G18CO
      class Stock < Stock
        def sold_out?(corporation)
          (corporation.num_market_shares + corporation.num_ipo_shares).zero?
        end
      end
    end
  end
end
