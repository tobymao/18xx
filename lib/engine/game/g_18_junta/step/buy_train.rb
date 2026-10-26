# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 4.3: a company may buy a train from another company only if both have the same
        # president, in normal and forced purchases alike.
        class BuyTrain < Engine::Step::BuyTrain
          def other_trains(entity)
            super.select { |train| train.owner.owner == entity.owner }
          end

          def process_buy_train(action)
            seller = action.train.owner
            if seller&.corporation? && seller != action.entity && seller.owner != action.entity.owner
              raise GameError, "#{action.entity.name} can only buy trains from companies with the same president"
            end

            super
          end
        end
      end
    end
  end
end
