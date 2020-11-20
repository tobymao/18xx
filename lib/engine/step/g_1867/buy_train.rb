# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_train'

module Engine
  module Step
    module G1867
      class BuyTrain < BuyTrain
        def actions(entity)
          return [] if entity != current_entity
          return %w[buy_train] if must_buy_train?(entity)
          return %w[buy_train pass] if can_buy_train?(entity)

          []
        end

        def available_cash(_player)
          current_entity.buying_power
        end

        def must_buy_train?(entity)
          # Can afford one by taking out max loans
          super && @game.buying_power(entity) >= needed_cash(entity)
        end

        def ebuy_president_can_contribute?(_corporation)
          false
        end
      end
    end
  end
end
