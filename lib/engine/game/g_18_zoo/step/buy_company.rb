# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def pay(entity, owner, price, company)
            entity.spend(price, owner || @game.bank) if price.positive?
            @game.company_bought(company, entity)

            @log << "#{owner&.name} earns #{@game.format_currency(price)} (sells '#{company.name}' to #{entity.name})"
          end
        end
      end
    end
  end
end
