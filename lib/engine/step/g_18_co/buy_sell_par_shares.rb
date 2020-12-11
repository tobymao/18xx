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

        def purchasable_companies(entity = nil)
          companies = super

          companies.select(&:owner)
        end

        def can_buy?(entity, bundle)
          if bundle&.owner&.corporation? && bundle.corporation != bundle.owner && @game.presidents_choice != :done
            return false unless bundle.owner.president?(entity)
          end

          super
        end
      end
    end
  end
end
