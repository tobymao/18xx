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

          if corporation.receivership? && bundle.presidents_share
            return false if entity.num_shares_of(corporation).zero?

            bundle = ShareBundle.new(bundle.shares, 10)
          end

          super(entity, bundle)
        end

        def process_buy_shares(action)
          bundle = action.bundle

          if bundle&.corporation&.receivership? && bundle.presidents_share
            action = Action::BuyShares.new(action.entity,
                                           shares: bundle.shares,
                                           share_price: bundle.share_price,
                                           percent: 10)
          end

          super(action)
        end
      end
    end
  end
end
