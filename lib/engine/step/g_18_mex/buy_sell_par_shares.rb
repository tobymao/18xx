# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative 'swap_buy_sell'

module Engine
  module Step
    module G18Mex
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          super && !attempt_ndm_action_on_unavailable?(bundle)
        end

        def can_sell?(entity, bundle)
          super && !attempt_ndm_action_on_unavailable?(bundle)
        end

        def can_gain?(entity, bundle)
          super && !attempt_ndm_action_on_unavailable?(bundle)
        end

        include SwapBuySell

        private

        def attempt_ndm_action_on_unavailable?(bundle)
          bundle.corporation == @game.ndm && @game.phase.status.include?('ndm_unavailable')
        end
      end
    end
  end
end
