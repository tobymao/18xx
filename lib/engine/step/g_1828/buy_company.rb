# frozen_string_literal: true

require_relative '../../token'
require_relative '../buy_company'

module Engine
  module Step
    module G1828
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          entity = action.entity
          company = action.company
          super

          return unless (minor = @game.minor_by_id(company.id))

          cash = minor.cash
          @log << "#{entity.name} receives #{@game.format_currency(cash)} from #{minor.name}'s treasury"
          minor.spend(cash, entity) if cash.positive?

          company.add_ability(Engine::Ability::Token.new(type: 'token',
                                                         hexes: [minor.coordinates],
                                                         price: 0,
                                                         teleport_price: 0,
                                                         from_owner: true,
                                                         when: 'sold'))

          @game.remove_minor!(minor)
        end
      end
    end
  end
end
