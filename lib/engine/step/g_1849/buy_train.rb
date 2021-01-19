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
          @game.reorder_corps if @moved_any
          @moved_any = false
        end

        def process_sell_shares(action)
          price_before = action.bundle.shares.first.price
          super
          return unless price_before != action.bundle.shares.first.price

          @game.moved_this_turn << action.bundle.corporation
          @moved_any = true
        end
      end
    end
  end
end
