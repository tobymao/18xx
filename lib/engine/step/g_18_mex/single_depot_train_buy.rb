# frozen_string_literal: true

require_relative '../single_depot_train_buy'
require_relative 'swap_buy_sell'

module Engine
  module Step
    module G18Mex
      class SingleDepotTrainBuy < SingleDepotTrainBuy
        def process_buy_train(action)
          @game.buy_first_5_train(action.entity.player) if action.train.id == '5-0'

          super
        end

        include SwapBuySell
      end
    end
  end
end
