# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'

module Engine
  module Game
    module G18FR
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          MIN_BID = 90

          def corporate_actions(entity)
            # In Stock Round corporations can only take loans
            return [] if @winning_bid

            return [] if @corporate_action && @corporate_action.entity != entity

            actions = []
            actions << 'take_loan' if @round.current_actions.empty? && @game.can_take_loan?(entity)

            actions
          end
        end
      end
    end
  end
end
