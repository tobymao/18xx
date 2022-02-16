# frozen_string_literal: true

require_relative '../../../step/train'

module Engine
  module Game
    module G18Scan
      module Step
        class BuyTrain < Engine::Step::BuySingleTrainOfType
          def can_entity_buy_train?
            true
          end

          def must_buy_train?(entity)
            return super unless entity.minor?

            false
          end
        end
      end
    end
  end
end
