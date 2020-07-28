# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18AL
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          super

          return unless action.company.sym == 'M&C'

          rob_bonus, pan_bonus = @game.route_bonuses
          action.entity.add_ability(create_hexes_bonus_ability(rob_bonus, 'Robert E. Lee', %w[G8 G4], 20))
          action.entity.add_ability(create_hexes_bonus_ability(pan_bonus, 'Pan American', %w[Q2 A4], 40))
        end

        private

        def create_hexes_bonus_ability(type, name, hex_names, amount)
          terminus1, terminus2 = hex_names.map { |n| @game.get_location_name(n) }
          description = "#{name}: #{terminus1}-#{terminus2} (#{@game.format_currency(amount)})"
          Engine::Ability::HexBonus.new(type: type, description: description, hexes: hex_names, amount: amount)
        end
      end
    end
  end
end
