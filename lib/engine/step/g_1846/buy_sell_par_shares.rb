# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1846
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          if @game.bundle_is_presidents_share_alone_in_pool?(bundle)
            bundle = bundle.to_bundle
            return false unless entity.num_shares_of(bundle.corporation) == 1

            percent = 10
            bundle = ShareBundle.new(bundle.shares, percent)
          end

          super
        end
      end
    end
  end
end
