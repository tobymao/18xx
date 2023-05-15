# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18JPT
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def cheapest_train_price(corporation)
            cheapest_train = @depot.min_depot_train
            price = cheapest_train.price
            # Handle a corporation having train discount ability
            @game.abilities(corporation, :train_discount, @ability_timing) do |ability|
              next if ability.count

              price = ability.discounted_price(cheapest_train, price) if ability.trains.include?(cheapest_train.name)
            end
            price
          end
        end
      end
    end
  end
end
