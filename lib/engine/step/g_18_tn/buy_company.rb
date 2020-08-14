# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18TN
      class BuyCompany < BuyCompany
        def can_buy_company?(entity)
          return true if super

          companies = @game.purchasable_companies

          entity == current_entity &&
            @game.turn == 1 &&
            @game.phase.status.include?('can_buy_companies_operation_round_one') &&
            companies.any? &&
            companies.map(&:value).min <= entity.cash
        end
      end
    end
  end
end
