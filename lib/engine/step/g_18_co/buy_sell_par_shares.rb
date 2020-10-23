# frozen_string_literal: true

require_relative '../buy_sell_par_shares.rb'

module Engine
  module Step
    module G18CO
      class BuySellParShares < BuySellParShares
        def get_par_prices(_entity, corp)
          @game.par_prices(corp)
        end

        def process_par(action)
          super(action)

          @game.par_change_float_percent(action.corporation)
        end
      end
    end
  end
end
