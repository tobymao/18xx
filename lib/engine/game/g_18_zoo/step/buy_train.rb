# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def round_state
            super.merge(
              {
                any_train_brought: false,
                new_train_brought: false,
              }
            )
          end

          def process_buy_train(action)
            entity ||= action.entity
            old_train = action.train.owned_by_corporation?

            super

            if !@round.any_train_brought && !old_train
              prev = entity.share_price.price
              @game.stock_market.move_right(entity)
              @game.log_share_price(entity, prev, '(new-train bonus)')
              @round.any_train_brought = true
            end

            return unless @round.new_train_brought

            prev = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, prev, '(new-phase bonus)')
            @round.new_train_brought = false
          end
        end
      end
    end
  end
end
