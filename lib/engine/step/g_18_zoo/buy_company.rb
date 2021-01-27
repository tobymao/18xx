# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18ZOO
      class BuyCompany < BuyCompany
        def description
          'Buy powers'
        end

        def pass_description
          @acted ? 'Done (Buy Powers)' : 'Skip (Buy Powers)'
        end

        def process_buy_company(action)
          if action.company.name.start_with?('ZOOTicket')
            entity = action.entity
            company = action.company
            price = action.price

            # Corporation get a loan to buy the ZOOTicket
            @game.bank.spend(price, entity)

            super

            # ZOOTicket must be sell when bought (and money for the loan given back)
            entity.companies.delete(company)
            @game.bank.spend(company.value - price, entity)
            @log << "#{entity.name} earns #{@game.format_currency(company.value - price)}"
          else
            super
          end
        end

        def pay(entity, owner, price, company)
          entity.spend(price, owner.nil? ? @game.bank : owner) if price.positive?
          @game.company_bought(company, entity)

          @log << "#{owner&.name} earns #{@game.format_currency(price)}"
        end
      end
    end
  end
end
