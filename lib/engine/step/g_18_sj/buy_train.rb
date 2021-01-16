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
          # If this entity has used Motala Verkstad to buy train(s) do not allow any normal train buys
          return [] if @round.respond_to?(:premature_trains_bought) && @round.premature_trains_bought.include?(entity)

          super
        end

        def do_after_buy_train_action(_action, _entity); end
      end
    end
  end
end
