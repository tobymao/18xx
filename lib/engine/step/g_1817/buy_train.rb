# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_train'

module Engine
  module Step
    module G1817
      class BuyTrain < BuyTrain
        def should_buy_train?(entity)
          :liquidation if entity.trains.empty?
        end

        # @todo: this needs to remove trains from companies in liquidation.
      end
    end
  end
end
