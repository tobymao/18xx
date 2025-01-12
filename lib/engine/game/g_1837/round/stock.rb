# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1837
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            corporation.percent_ipo_buyable.zero? && corporation.num_market_shares.zero?
          end
        end
      end
    end
  end
end
