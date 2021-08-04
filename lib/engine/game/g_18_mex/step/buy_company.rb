# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18MEX
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            return false if entity.company?
            return super if @game.phase.current[:name] != '2' || !(@game.early_buy_of_kcmo? || @game.baja_variant?)

            companies = @game.purchasable_companies

            entity == @game.current_entity &&
              companies.any? &&
              companies.map(&:min_price).min <= entity.cash
          end
        end
      end
    end
  end
end
