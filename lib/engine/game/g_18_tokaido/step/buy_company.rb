# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18Tokaido
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def process_token(entity, company)
            company.owner = nil
            entity.companies.delete(company)
            index = entity.tokens.index { |t| !t.hex }
            if index
              entity.tokens.insert(index, Engine::Token.new(entity))
            else
              entity.tokens << Engine::Token.new(entity)
            end
          end

          def zero_out_revenue(company)
            company.revenue = 0
          end

          def process_buy_company(action)
            super
            entity = action.entity
            company = action.company
            process_token(entity, company) if company.id == 'SMT'
            zero_out_revenue(company) if company.id == 'FM' || company.id == 'ST'
          end
        end
      end
    end
  end
end
