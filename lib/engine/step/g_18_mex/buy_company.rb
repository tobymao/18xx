# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18Mex
      class BuyCompany < BuyCompany
        def can_buy_company?(entity)
          return false if entity.company?
          return super if @game.phase.current[:name] != '2' || !@game.optional_rules&.include?(:early_buy_of_kcmo)

          companies = @game.purchasable_companies

          entity == @game.current_entity &&
            companies.any? &&
            companies.map(&:min_price).min <= entity.cash
        end
      end
    end
  end
end
