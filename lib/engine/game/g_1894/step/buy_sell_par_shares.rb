# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1894
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy_multiple?(entity, corporation, _owner)
            super && corporation.owner == entity && num_shares_bought(corporation) < 2
          end

          def num_shares_bought(corporation)
            @round.current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
          end
        end
      end
    end
  end
end
