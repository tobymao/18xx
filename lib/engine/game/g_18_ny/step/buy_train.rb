# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G18NY
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include Engine::Step::AutomaticLoan

          def buying_power
            if must_buy_train?(entity)
              @game.buying_power(entity, full: true, prepay_interest: true)
            else
              @game.buying_power(entity)
            end
          end

          def try_take_loan(entity, cost)
            super if must_buy_train?(entity)
          end
        end
      end
    end
  end
end
