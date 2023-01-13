# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1880
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            (corporation.num_ipo_shares - corporation.num_ipo_reserved_shares).zero?
          end
        end
      end
    end
  end
end
