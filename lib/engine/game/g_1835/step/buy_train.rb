# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1835
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          # In 1835, minors are operators and may buy trains.
          # The base class returns !entity.minor? which would block them.
          def can_entity_buy_train?(entity)
            entity.operator?
          end

          # Minors are not required to own a train, so they never trigger
          # emergency buying or president contributions.
          def must_buy_train?(entity)
            return false if entity.minor?

            super
          end
        end
      end
    end
  end
end
