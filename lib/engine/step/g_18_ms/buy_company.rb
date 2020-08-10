# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18MS
      class BuyCompany < BuyCompany
        def can_buy_company?(entity)
          companies = @game.purchasable_companies

          entity == current_entity &&
            companies.any? &&
            companies.map(&:min_price).min <= entity.cash
        end
      end
    end
  end
end
