# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1824
      class BuyTrain < BuyTrain
        def process_buy_train(action)
          entity = action.entity
          price = action.price
          train = action.train
          previous_owner = train.owner
          emergency = @game.emergency(entity)

          super

          return if !emergency || !previous_owner.player? || previous_owner == entity.player

          raise GameError, 'Emergency buy of train from other player cannot exceed face value' if price > train.price
        end
      end
    end
  end
end
