# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18MS
      class Token < Token
        BONUS_HEX = 'I1'

        def place_token(entity, city, token, teleport: false)
          super

          return unless city.hex.name == BONUS_HEX

          # Add a revenue bonus for the corporation
          # that will be removed in phase 6

          route_bonus = 10
          one_time_bonus = 100
          hex_name = @game.get_location_name(BONUS_HEX)
          description = "#{@game.format_currency(route_bonus)} route bonus for #{hex_name} (#{BONUS_HEX})"

          ability = Engine::Ability::HexBonus.new(
            type: :hexes_bonus,
            description: description,
            hexes: [BONUS_HEX],
            amount: route_bonus
          )

          entity.add_ability(ability)
          @game.remove_icons(BONUS_HEX)
          bonus = @game.format_currency(one_time_bonus)
          @log << "#{entity.name} receives #{bonus} for a token in #{hex_name}"
          @log << "Until phase 6 #{entity.name} also receives: #{description}"
          entity.cash += one_time_bonus
        end
      end
    end
  end
end
