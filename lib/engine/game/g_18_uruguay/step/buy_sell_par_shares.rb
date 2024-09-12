# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Uruguay
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy?(entity, bundle)
            return false if bundle&.corporation == @game.rptla && !@game.phase.status.include?('rptla_available')
            return true if loan_limit(entity, bundle)

            super(entity, bundle)
          end

          def loan_limit(_entity, bundle)
            return false if bundle.nil?
            return false if bundle.owner.corporation?

            bundle.corporation.loans.size > @game.maximum_loans(bundle.corporation)
          end
        end
      end
    end
  end
end
