# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18MEX
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          super && !attempt_ndm_action_on_unavailable?(bundle)
        end

        def can_sell?(entity, bundle)
          super && !attempt_ndm_action_on_unavailable?(bundle)
        end

        private

        def attempt_ndm_action_on_unavailable?(bundle)
          bundle.corporation.name == 'NdM' && @game.phase.status.include?('ndm_unavailable')
        end
      end
    end
  end
end
