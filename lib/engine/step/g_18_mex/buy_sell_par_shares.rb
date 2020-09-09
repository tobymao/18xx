# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18MEX
      class BuySellParShares < BuySellParShares
        def process_buy_shares(action)
          ensure_ndm_not_traded_to_early(action)
          super
        end

        def process_sell_shares(action)
          ensure_ndm_not_traded_to_early(action)
          super
        end

        private

        def ensure_ndm_not_traded_to_early(action)
          return if action.bundle.corporation.name != 'NdM' || @game.phase.status.include?('ndm_available')

          @game.game_error('Cannot yet buy or sell NdM from stock market')
        end
      end
    end
  end
end
