# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Neb
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            super.select { |train| buyable_train?(entity, train) }
          end

          def other_trains(entity)
            super.select { |train| buyable_train?(entity, train) }
          end

          def buyable_train?(entity, train)
            entity.type == :local ? train.rusted : !train.rusted
          end
        end
      end
    end
  end
end
