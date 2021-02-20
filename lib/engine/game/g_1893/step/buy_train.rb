# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1893
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity
            # TODO: Not sure this is right
            return %w[sell_shares buy_train] if president_may_contribute?(entity)

            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end
        end
      end
    end
  end
end
