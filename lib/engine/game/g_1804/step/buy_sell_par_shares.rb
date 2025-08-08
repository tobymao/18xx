# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1804
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def purchasable_companies(entity)
            return [] if bought? ||
              !available_cash(entity).positive? ||
              !@game.phase ||
              !@game.phase.status.include?('can_buy_companies_from_other_players') ||
              @game.turn == 1

            @game.purchasable_companies(entity)
          end
        end
      end
    end
  end
end
