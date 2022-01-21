# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1866
      module Step
        class FirstTurnHousekeeping < Engine::Step::BuyTrain
          def actions(entity)
            if entity.corporation? && @game.corporation?(entity) && !entity.operated? &&
              @game.local_train?(@game.depot.upcoming.first) && can_buy_train?(entity)
              return %w[buy_train pass]
            end

            []
          end

          def buyable_trains(_entity)
            # Clone the first available L train, this to remove the 2 train variant from it. Since a L train is the
            # only train you are allowed to buy during the housekeeping
            train = @game.depot.upcoming.first
            l_train = Engine::Train.new(name: train.name, distance: train.distance, price: train.price)
            l_train.owner = @game.depot
            [l_train]
          end

          def description
            'First Turn Housekeeping'
          end

          def process_buy_train(action)
            # Make sure the corp buy the correct train with a 2 variant
            new_action = Action::BuyTrain.new(
              action.entity,
              train: @game.depot.upcoming.first,
              price: action.price,
              variant: action.variant,
            )

            super(new_action)
            pass!
          end

          def must_buy_train?(_entity)
            false
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
