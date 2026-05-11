# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G2038
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          # In 2038, independent companies (minors) can buy spaceships just like
          # corporations. The base engine blocks minors from buying trains by default.
          def can_entity_buy_train?(entity)
            entity.minor? || super
          end
        end
      end
    end
  end
end
