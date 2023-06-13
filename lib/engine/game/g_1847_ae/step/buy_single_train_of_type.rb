# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1847AE
      module Step
        class BuySingleTrainOfType < Engine::Step::BuySingleTrainOfType
          def buyable_trains(entity)
            # Can't buy trains from other corporations in phase 3
            return super if @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end
        end
      end
    end
  end
end
