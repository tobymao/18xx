# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1826
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            # Can't buy trains from other corporations until phase 6H
            return super if @game.can_buy_trains

            super.select(&:from_depot?)
          end
        end
      end
    end
  end
end
