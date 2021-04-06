# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1817
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def pass_description
            text = 'Trains'
            text += ', Liquidate' if !current_entity.loans.empty? && !@game.can_pay_interest?(current_entity)
            @acted ? "Done (#{text})" : "Skip (#{text})"
          end

          def should_buy_train?(entity)
            :liquidation if entity.trains.empty?
          end

          def buyable_trains(entity)
            # Cannot buy trains from corps in liquidation.
            super.reject { |t| t.owner != @game.depot && t.owner.share_price.liquidation? }
          end
        end
      end
    end
  end
end
