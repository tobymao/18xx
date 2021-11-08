# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18NY
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def process_buy_company(action)
            if !action.entity.loans.empty? && action.price > action.company.value
              raise GameError, 'Corporations with loans cannot pay more than face value for a private company'
            end

            super
          end
        end
      end
    end
  end
end
