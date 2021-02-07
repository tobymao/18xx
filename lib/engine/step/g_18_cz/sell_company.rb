# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CZ
      class SellCompany < Base
        def actions(entity)
          return ['sell_company'] if entity.company? && entity.owner == current_entity || entity == current_entity

          []
        end

        def description
          'Sell Company'
        end

        def blocks?
          false
        end

        def process_sell_company(action)
          corporation = action.entity
          company = action.company
          price = action.price

          @game.bank.spend(price, corporation)

          @log << "#{corporation.name} sells #{company.name} for #{@game.format_currency(price)} to the bank"

          company.close!

          @log << "#{company.name} closes"
        end
      end
    end
  end
end
