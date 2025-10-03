# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'tokened_city_must_be_connected'

module Engine
  module Game
    module G18MS
      module Step
        class Token < Engine::Step::Token
          BONUS_HEX = 'I1'

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil)
            super

            return unless city.hex.name == BONUS_HEX

            # Add a revenue bonus for the corporation
            # that will be removed in phase 6

            route_bonus = 10
            one_time_bonus = 100
            hex_name = @game.get_location_name(BONUS_HEX)
            description = "#{@game.format_currency(route_bonus)} route bonus for #{hex_name} (#{BONUS_HEX})"

            if @game.phase.name.to_i < 6
              route_bonus_given = true
              ability = Engine::Ability::HexBonus.new(
                type: :hexes_bonus,
                description: description,
                hexes: [BONUS_HEX],
                amount: route_bonus
              )
              entity.add_ability(ability)
            end

            @game.remove_icons(BONUS_HEX)
            bonus = @game.format_currency(one_time_bonus)
            @log << "#{entity.name} receives #{bonus} for a token in #{hex_name}"
            @log << "Until phase 6 #{entity.name} also receives: #{description}" if route_bonus_given
            @game.bank.spend(one_time_bonus, entity)
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            return [token, nil] if @game.active_step.current_entity.corporation?

            super
          end

          include TokenedCityMustBeConnected
        end
      end
    end
  end
end
