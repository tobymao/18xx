# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1854
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            return true if entity.corporation? || entity.minor?

            super
          end

          def buyable_trains(entity)
            trains_to_buy = super
            # Can't buy trains from other corporations until train 3
            return trains_to_buy if @game.can_cross_buy?

            trains_to_buy.select(&:from_depot?)
          end
        end
      end
    end
  end
end
