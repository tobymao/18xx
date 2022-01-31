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

          def process_buy_train(action)
            @round.bought_trains << action.entity
            super
          end

          # Need to keep track of bought trains to avoid special tile lay after train buy
          def round_state
            { bought_trains: [] }
          end
        end
      end
    end
  end
end
