# frozen_string_literal: true

require_relative '../../g_1817/step/buy_train'
require_relative 'scrap_train_module'

module Engine
  module Game
    module G18USA
      module Step
        class BuyTrain < G1817::Step::BuyTrain
          include ScrapTrainModule
          def should_buy_train?(entity)
            :liquidation if entity.trains.reject { |t| @game.pullman_train?(t) }.empty?
          end

          def buyable_trains(entity)
            buyable_trains = super
            # Cannot buy pullmans from the bank/depot? # TODO: Confirm if this is true and if false, remove this line.
            # https://github.com/tobymao/18xx/issues/7097
            buyable_trains.reject! { |t| @game.pullman_train?(t) && t.from_depot? }
            # Cannot buy a pullman if you have a pullman
            buyable_trains.reject! { |t| @game.pullman_train?(t) } if entity.runnable_trains&.any? { |t| @game.pullman_train?(t) }
            buyable_trains
          end
        end
      end
    end
  end
end
