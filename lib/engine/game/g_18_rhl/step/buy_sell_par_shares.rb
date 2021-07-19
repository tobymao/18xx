# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Rhl
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy?(entity, bundle)
            return false unless super

            # For KKK the 2 first non president certificates sold need to be 20% ones
            kkk = @game.kkk
            bundle.corporation != kkk || kkk.floated? || !kkk.ipoed || bundle.percent == 20
          end
        end
      end
    end
  end
end
