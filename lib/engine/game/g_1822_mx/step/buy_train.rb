# frozen_string_literal: true

require_relative '../../g_1822/step/buy_train'

module Engine
  module Game
    module G1822MX
      module Step
        class BuyTrain < G1822::Step::BuyTrain
          def buyable_trains(entity)
            super.reject { |train| train.owner == @game.ndem }
          end
        end
      end
    end
  end
end
