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
            @game.bankrupt!(player, corporation)
            receivership_buy_train(corporation)
          end

          private

          def receivership_buy_train(corporation)
            return unless corporation.receivership?

            train = @game.depot.min_depot_train
            price = train.price
            shortfall = price - corporation.cash
            if shortfall.positive?
              @log << "The bank gives #{@game.format_currency(shortfall)} " \
                      "to #{corporation.name} to allow it to purchase a train."
              @game.bank.spend(shortfall, corporation)
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
