# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module SellCompany
        def sell_price(entity)
          return 0 unless can_sell_company?(entity)

          entity.value
        end

        def can_sell_any_companies?(entity)
          !sellable_companies(entity).empty?
        end

        def sellable_companies(entity)
          return [] unless entity.player?

          entity.companies.select { |c| c.name.start_with?('ZOOTicket') }
        end

        def process_sell_company(action)
          player = action.entity
          company = action.company
          price = action.price
          raise GameError, "Cannot sell #{company.id}" unless can_sell_company?(company)

          player.companies.delete(company)
          @game.bank.spend(price, player) if price.positive?
          @log << "#{player.name} sells #{company.name} to bank for #{@game.format_currency(price)}"
        end

        def can_sell_company?(entity)
          return false unless entity.company?
          return false if entity.owner == @game.bank

          true
        end
      end
    end
  end
end
