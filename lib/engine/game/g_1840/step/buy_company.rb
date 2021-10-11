# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1840
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def spender(entity)
            @game.owning_major_corporation(entity)
          end

          def process_buy_company(action)
            entity = @game.owning_major_corporation(action.entity)
            company = action.company
            price = action.price
            owner = company.owner

            min = company.min_price
            max = company.max_price
            unless price.between?(min, max)
              raise GameError, "Price must be between #{@game.format_currency(min)} and #{@game.format_currency(max)}"
            end

            log_later = []
            company.owner = entity
            owner&.companies&.delete(company)

            @round.just_sold_company = company
            @round.company_sellers[company] = owner

            entity.companies << company
            pay(entity, owner, price, company)

            log_later.each { |l| @log << l }
          end
        end
      end
    end
  end
end
