# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1856
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          # Overriding buying_power in Game has implications for emergency fund raising so it is implemented here
          def buying_power(entity)
            buying_power = entity.cash
            if @game.can_take_loan?(entity)
              buying_power += @round.paid_interest[entity] ? 90 : 100
            end
            buying_power
          end
        end
      end
    end
  end
end
