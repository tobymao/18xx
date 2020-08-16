# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18TN
      class BuyCompany < BuyCompany
        def can_buy_company?(entity)
          return false if @game.turn == 1 && @round.just_sold_company

          return true if super

          companies = @game.purchasable_companies

          # In OR 1 a corporation can buy a company
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
