# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1894
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def setup
            super
            @exchanged = false
          end

          def buy_train_action(action, entity = nil)
            super
            @exchanged = true if action.exchange
          end

          def discountable_trains_allowed?(_entity)
            !@exchanged
          end
        end
      end
    end
  end
end
