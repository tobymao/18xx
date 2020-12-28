# frozen_string_literal: true

require_relative '../buy_sell_par_shares.rb'

module Engine
  module Step
    module G18CZ
      class BuySellParShares < BuySellParShares
        def get_par_prices(_entity, corp)
          @game.par_prices(corp)
        end
      end
    end
  end
end
