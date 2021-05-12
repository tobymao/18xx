# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Ireland
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
            !@exchanged && %w[D 10].include?(@game.phase.name)
          end
        end
      end
    end
  end
end
