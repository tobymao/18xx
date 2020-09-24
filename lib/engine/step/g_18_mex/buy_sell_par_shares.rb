# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18MEX
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          return unless super

          bundle.corporation.name != 'NdM' || @game.phase.status.include?('ndm_available')
        end

        def can_sell?(entity, bundle)
          return unless super

          bundle.corporation.name != 'NdM' || @game.phase.status.include?('ndm_available')
        end
      end
    end
  end
end
