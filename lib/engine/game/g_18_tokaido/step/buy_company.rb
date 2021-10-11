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
            entity.tokens.insert(entity.tokens.index { |t| !t.hex }, Engine::Token.new(entity))
          end

          def process_fish_market(company)
            company.revenue = 0
          end

          def process_buy_company(action)
            super
            entity = action.entity
            company = action.company
            process_token(entity, company) if company.id == 'SMT'
            process_fish_market(company) if company.id == 'FM'
          end
        end
      end
    end
  end
end
