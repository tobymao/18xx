# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18CO
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            (corporation.num_market_shares + corporation.num_ipo_shares).zero?
          end
        end
      end
    end
  end
end
