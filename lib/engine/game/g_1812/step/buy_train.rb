# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1867/step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G1812
      module Step
        class BuyTrain < G1867::Step::BuyTrain
          include Engine::Step::AutomaticLoan

          def pass!
            super

            @game.trainless_penalty(current_entity) if current_entity.trains.empty?
          end

          def discountable_trains_allowed?(_entity)
            @game.phase.name.to_i >= 5
          end
        end
      end
    end
  end
end
