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
            corporation = action.entity
            company = action.company
            price = action.price
            player = company.owner

            @log << "#{corporation.name} sells #{company.name} (owned by #{player.name})"

            @game.bank.spend(price, player) if price.positive?
            @log << "#{player.name} earns #{@game.format_currency(price)}" if price.positive?

            @game.bank.spend(company.value - price, corporation)
            @log << "#{corporation.name} earns #{@game.format_currency(company.value - price)}"

            company.close!
          else
            super
          end
        end

        def pay(entity, owner, price, company)
          entity.spend(price, owner || @game.bank) if price.positive?
          @game.company_bought(company, entity)

          @log << "#{owner&.name} earns #{@game.format_currency(price)}"
        end
      end
    end
  end
end
