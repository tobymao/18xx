# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1868WY
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end
        end
      end
    end
  end
end
