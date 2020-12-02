# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1860
      class BuyTrain < BuyTrain
        def actions(entity)
          return [] if entity.receivership? && entity.trains.any?

          super
        end
      end
    end
  end
end
