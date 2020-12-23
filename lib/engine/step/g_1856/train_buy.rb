# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1856
      class BuyTrain < BuyTrain
        def process_buy_train(action)
          @game.buy_first_6_train(action.entity.player) if action.train.id == '6-0'
          super
        end
      end
    end
  end
end
