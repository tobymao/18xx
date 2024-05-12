# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Ardennes
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def train_variant_helper(train, entity)
            return super if @game.can_buy_4d?(entity)

            super.reject { |v| v[:name] == '4D' }
          end
        end
      end
    end
  end
end
