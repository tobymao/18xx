# frozen_string_literal: true

require_relative '../../../step/special_buy_train'

module Engine
  module Game
    module G18VA
      module Step
        class SpecialBuyTrain < Engine::Step::SpecialBuyTrain
          def process_buy_train(action)
            # recording now because super will alter this
            from_depot = action.train.from_depot?
            super
            @round.bought_depot_trains << action.train.sym if from_depot
          end
        end
      end
    end
  end
end
