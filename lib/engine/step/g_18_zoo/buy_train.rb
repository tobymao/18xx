# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18ZOO
      class BuyTrain < Engine::Step::BuyTrain
        def setup
          super

          #@log << "setup called for #{entities} in #{@round}"
          @any_train_brought = false
        end

        def buy_train_action(action, entity = nil)
          entity ||= action.entity

          super

          unless @any_train_brought
            prev = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, prev)
            @any_train_brought = true
          end

          if @game.new_train_brought
            prev = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, prev)
            @game.new_train_brought = false
          end
        end
      end
    end
  end
end
