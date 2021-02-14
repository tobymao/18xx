# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1856
      class BuyTrain < BuyTrain
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
