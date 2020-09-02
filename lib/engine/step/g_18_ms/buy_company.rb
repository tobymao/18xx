# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18MS
      class BuyCompany < BuyCompany
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
          @game.add_free_train(entity)
        end
      end
    end
  end
end
