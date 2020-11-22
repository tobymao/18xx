# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18TN
      class BuyCompany < BuyCompany
        def can_buy_company?(entity)
          return true if super
          return false if entity != current_entity || !@game.allowed_to_buy_during_operation_round_one?

          companies = @game.purchasable_companies
          companies.any? && companies.map(&:value).min <= entity.cash
        end
      end
    end
  end
end
