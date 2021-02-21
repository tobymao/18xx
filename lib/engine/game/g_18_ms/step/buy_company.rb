# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18MS
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            return false if entity.company?

            companies = @game.purchasable_companies

            entity == @game.current_entity &&
              companies.any? &&
              companies.map(&:min_price).min <= entity.cash
          end

          def process_buy_company(action)
            super

            company = action.company
            return unless company.id == 'MC'

            entity = action.entity
            @game.add_free_train_and_close_company(entity, company)
          end
        end
      end
    end
  end
end
