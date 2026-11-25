# frozen_string_literal: true

require_relative '../../g_1846/step/buy_train'

module Engine
  module Game
    module G1833NE
      module Step
        class BuyTrain < G1846::Step::BuyTrain
          def buying_power(entity)
            @game.buying_power(entity)
          end
        end
      end
    end
  end
end
