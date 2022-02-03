# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1848
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            # Cannot buy 2E if one is already owned
            owns_2e = entity.trains.any? { |t| t.name == '2E' }
            return super unless owns_2e

            super.reject { |t| t.name == '2E' }
          end

          def room?(entity)
            entity.trains.count { |t| t.name != '2E' } < @game.train_limit(entity)
          end
        end
      end
    end
  end
end
