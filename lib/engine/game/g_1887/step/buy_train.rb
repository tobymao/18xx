# frozen_string_literal: true

require_relative '../../g_1822/step/buy_train'

module Engine
  module Game
    module G1887
      module Step
        class BuyTrain < G1822::Step::BuyTrain
          def actions(entity)
            # Industries may hold trains (they never run them) from phase 3
            return [] if @game.industry?(entity) && !@game.phase.status.include?('can_buy_trains')

            super
          end
        end
      end
    end
  end
end
