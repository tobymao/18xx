# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1848
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def can_buy_company?(entity)
            return false if entity == @game.boe

            super
          end
        end
      end
    end
  end
end
