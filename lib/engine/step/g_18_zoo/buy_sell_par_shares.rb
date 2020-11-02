# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18ZOO
      class BuySellParShares < BuySellParShares
        #TODO: Player cannot buy more than 60% from IPO
      end
    end
  end
end
