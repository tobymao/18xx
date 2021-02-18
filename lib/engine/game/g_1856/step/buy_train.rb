# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1856
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)

            @game.national_bought_permanent if action.entity == @game.national && !action.train.rusts_on

            pass! unless can_buy_train?(action.entity)
          end
        end
      end
    end
  end
end
