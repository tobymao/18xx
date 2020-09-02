# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1846
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          return unless bundle

          bundle = bundle.to_bundle
          corporation = bundle.corporation

          return false if corporation.receivership? &&
                          bundle.presidents_share &&
                          ((bundle.num_shares > 1) ||
                           (entity.num_shares_of(corporation) != 1))

          super
        end
      end
    end
  end
end
