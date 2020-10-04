# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1817
      class Stock < Stock
        def sold_out?(corporation)
          corporation.total_shares > 2 && corporation.player_share_holders.values.sum >= 100
        end
      end
    end
  end
end
