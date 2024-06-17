# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Uruguay
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy?(entity, bundle)
            return false if bundle&.corporation == @game.rptla && !@game.phase.status.include?('rptla_available')

            super(entity, bundle)
          end
        end
      end
    end
  end
end
