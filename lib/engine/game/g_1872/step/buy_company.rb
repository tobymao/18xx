require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1872
      module Step
        class BuyCompany < Engine::Step::BuyCompany

          def process_token(entity, company)
            company.owner = nil
            entity.companies.delete(company)
            entity.tokens.insert(entity.tokens.index { |t| t.hex.nil? }, Engine::Token.new(entity))
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            owner = company.owner
    
            buy_company(entity, company, price, owner)
            process_token(entity, company) if company.id == "SS"
          end
        end
      end
    end
  end
end