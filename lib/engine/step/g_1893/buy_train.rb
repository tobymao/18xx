# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1893
      class BuyTrain < BuyTrain
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
