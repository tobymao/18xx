# frozen_string_literal: true

require_relative '../../../step/bankrupt'
require_relative '../../../step/train'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          include Engine::Step::Train

          def process_bankrupt(action)
            corporation = action.entity
            player = corporation.player
            @game.declare_bankrupt(player, corporation)
            receivership_buy_train(corporation)
          end

          private

          def receivership_buy_train(corporation)
            return unless corporation.receivership?

            train = @game.depot.min_depot_train
            price = train.price
            if price > corporation.cash
              @log << 'The bank '
              @game.bank.spend(price - corporation.cash, corporation)
            end
            buy_train_action(Engine::Action::BuyTrain.new(corporation,
                                                          train: train,
                                                          price: price))
          end
        end
      end
    end
  end
end
