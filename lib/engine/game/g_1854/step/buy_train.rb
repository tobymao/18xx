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
        end
      end
    end
  end
end
