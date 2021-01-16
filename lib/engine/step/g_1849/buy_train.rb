# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1849
      class BuyTrain < BuyTrain
        def setup
          super
        end

        def pass!
          super
          @game.reorder_corps if @sold_any
          @sold_any = false
        end

        def process_sell_shares(action)
          super
          @sold_any = true
          @game.sold_this_turn << action.bundle.corporation
        end
      end
    end
  end
end
