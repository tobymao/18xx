# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1849
      class BuyTrain < BuyTrain
        def setup
          super
          @game.old_operating_order = @game.corporations.sort
          @sold_any = false
        end

        def pass!
          super
          @game.reorder_corps if @sold_any
        end

        def process_sell_shares(action)
          super
          @sold_any = true
        end
      end
    end
  end
end
