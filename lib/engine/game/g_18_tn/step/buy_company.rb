# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18TN
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            return true if super
            return false if entity != current_entity ||
                            entity.companies.any? ||
                            !@game.allowed_to_buy_during_operation_round_one?

            companies = @game.purchasable_companies
            companies.any? && companies.map(&:value).min <= entity.cash
          end
        end
      end
    end
  end
end
