# frozen_string_literal: true

require_relative '../../step/buy_company'

module Engine
  module Game
    module G1893
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def actions(entity)
            return ['buy_company'] unless purchasable_companies(entity).empty?

            []
          end

          def process_buy_company(action)
            buyer = spender(action.entity)
            company = action.company
            company.min_price = 1
            company.max_price = buyer.cash

            buy_company(buyer, company, action.price, company.owner)
          end

          def purchasable_companies(entity = nil)
            entity ||= @game.current_entity
            @game.purchasable_companies(spender(entity))
          end

          # Who should pay for bought company? (Assuming company is EVA)
          def spender(entity)
            return unless entity

            entity.player? ? entity : entity.player
          end
        end
      end
    end
  end
end
