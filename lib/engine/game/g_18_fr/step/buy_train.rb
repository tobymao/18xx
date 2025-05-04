# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18FR
      module Step
        class BuyTrain < G1817::Step::BuyTrain
          def spend_minmax(entity, _train)
            [0, buying_power(entity)]
          end

          def buy_train_action(action, entity = nil, borrow_from: nil)
            return super if action.train.owner == @game.depot || action.price.positive?

            @game.buy_train(action.entity, action.train, :free)
            @log << "#{action.entity.name} buys a #{action.train.name} train for free from #{action.train.owner.name}"
          end
        end
      end
    end
  end
end
