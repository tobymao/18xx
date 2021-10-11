# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Rhl
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            # Corps in receivership cannot buy/sell trains (Rule 13.2)
            super.reject { |t| t.owner != @game.depot && (t.owner.receivership? || entity.receivership?) }
          end
        end
      end
    end
  end
end
