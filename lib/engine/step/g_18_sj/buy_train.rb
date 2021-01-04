# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_train'
require_relative 'buy_train_action'

module Engine
  module Step
    module G18SJ
      class BuyTrain < BuyTrain
        include BuyTrainAction

        def actions(entity)
          # If this entity has used Motala Verkstad to buy train(s) do not allow any more train buys
          return [] if @round.respond_to?(:premature_trains_bought) && @round.premature_trains_bought == entity

          super
        end
      end
    end
  end
end
