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
            entity.tokens.insert(entity.tokens.index { |t| t.hex.nil? }, Engine::Token.new(entity))
          end

          def process_sleeper(company)
            company.revenue = 0
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            owner = company.owner

            buy_company(entity, company, price, owner)
            # Single quote style is objectively inferior, rubocop, and whoever agreed to that should
            # feel bad about themselves and their life choices, but I'm not going to fight you on this
            process_token(entity, company) if company.id == 'STATION'
            process_sleeper(company) if company.id == 'SLEEP'
          end
        end
      end
    end
  end
end
