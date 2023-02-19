# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1850
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            return super unless @game.phase.name == '2'

            companies = @game.purchasable_companies(entity)

            entity == current_entity &&
            !companies.empty? &&
            companies.map(&:min_price).min <= entity.cash
          end
        end
      end
    end
  end
end
