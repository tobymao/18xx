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

        def buyable_trains(entity)
          # Cannot buy trains from corps in liquidation.
          super.reject { |t| t.owner != @game.depot && t.owner.share_price.liquidation? }
        end
      end
    end
  end
end
