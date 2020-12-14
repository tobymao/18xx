# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_train'
require_relative 'automatic_loan'

module Engine
  module Step
    module G1867
      class BuyTrain < BuyTrain
        include AutomaticLoan

        def actions(entity)
          return [] if entity != current_entity
          return %w[buy_train] if must_buy_train?(entity)
          return %w[buy_train pass] if can_buy_train?(entity)

          []
        end

        def available_cash(_player)
          current_entity.buying_power
        end

        def must_buy_train?(entity)
          # Can afford one by taking out max loans
          super && @game.buying_power(entity, true) >= needed_cash(entity)
        end

        def ebuy_president_can_contribute?(_corporation)
          false
        end

        def buy_train_action(action, entity = nil)
          @depot_train = action.train.from_depot?
          super
          @game.post_train_buy
        end

        def buying_power(entity)
          if must_buy_train?(entity)
            @game.buying_power(entity, true)
          else
            @game.buying_power(entity)
          end
        end

        def try_take_loan(entity, cost)
          if must_buy_train?(entity) && @depot_train
            super
          elsif cost > entity.cash
            reason =
              if must_buy_train?(entity)
                'as train is not from depot'
              elsif @game.buying_power(entity, true) <= needed_cash(entity)
                'cannot take enough loans to purchase'
              else
                'as do not need to buy'
              end
            @game.game_error("Not able to take loan to purchase at #{@game.format_currency(cost)}, " + reason)
          end
        end
      end
    end
  end
end
