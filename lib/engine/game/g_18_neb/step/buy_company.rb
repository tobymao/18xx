# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18Neb
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            companies = @game.purchasable_companies(entity)

            entity == current_entity &&
              !companies.empty? &&
              companies.map(&:min_price).min <= buying_power(entity)
          end
        end
      end
    end
  end
end
