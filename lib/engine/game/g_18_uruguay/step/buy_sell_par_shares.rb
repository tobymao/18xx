# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Uruguay
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_gain?(entity, bundle, exchange: false)
            return false if bundle&.corporation == @game.rptla && !@game.phase.status.include?('rptla_available')
            return true if excess_loans?(entity, bundle)

            super
          end

          def excess_loans?(_entity, bundle)
            return false if bundle.nil?
            return false if bundle.owner.corporation?

            bundle.corporation.loans.size > @game.maximum_loans(bundle.corporation)
          end
        end
      end
    end
  end
end
