# frozen_string_literal: true

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
