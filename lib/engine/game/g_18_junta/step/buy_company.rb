# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 2.2: a company may buy a private company only from its own president. The check
        # runs before the purchase, so a rejected purchase changes nothing.
        class BuyCompany < Engine::Step::BuyCompany
          def process_buy_company(action)
            entity = action.entity
            company = action.company
            raise GameError, "#{company.name} cannot be sold to a company" if @game.abilities(company, :no_buy)
            if entity.corporation? && company.owner != entity.owner
              raise GameError, "#{entity.name} can only buy Private Companies from its president (#{entity.owner&.name})"
            end

            super
          end
        end
      end
    end
  end
end
