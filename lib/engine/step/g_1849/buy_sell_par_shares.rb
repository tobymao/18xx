# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1849
      class BuySellParShares < BuySellParShares
        def can_buy_multiple?(entity, corp)
          super || (corp.owner == entity && just_parred(corp) && num_shares_bought(corp) < 2)
        end

        def just_parred(corporation)
          @current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation }
        end

        def num_shares_bought(corporation)
          @current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
        end
      end
    end
  end
end
