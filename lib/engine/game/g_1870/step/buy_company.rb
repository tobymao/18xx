# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1870
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            return super unless @game.phase.name == '1'

            entity == current_entity &&
              @game.purchasable_companies(entity).any? &&
              @game.river_company.min_price <= entity.cash
          end
        end
      end
    end
  end
end
