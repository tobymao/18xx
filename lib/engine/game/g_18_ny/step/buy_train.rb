# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G18NY
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include Engine::Step::AutomaticLoan

          def buying_power(entity)
            if must_buy_train?(entity)
              @game.buying_power(entity, full: true, prepay_interest: true)
            else
              @game.buying_power(entity)
            end
          end

          def try_take_loan(entity, cost)
            super(entity, cost, prepay_interest: true) if must_buy_train?(entity)
          end

          def president_may_contribute?(entity, _shell = nil)
            super && buying_power(entity) < @depot.min_depot_price
          end

          def ebuy_president_can_contribute?(corporation)
            president_may_contribute?(corporation)
          end
        end
      end
    end
  end
end
