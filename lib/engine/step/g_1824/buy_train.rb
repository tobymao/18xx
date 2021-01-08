# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1824
      class BuyTrain < BuyTrain
        def process_buy_train(action)
          entity ||= action.entity
          train = action.train

          if entity&.corporation? && !@game.g_train?(train) && @game.coal_railways.include?(entity)
            raise GameError, 'Coal railways can only own g-trains'
          end

          super
        end
      end
    end
  end
end
