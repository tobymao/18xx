# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18JPT
      module Step
        class Token < Engine::Step::Token
          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true, spender: nil)
            super

            # Activate ability if token placed where needed
            return unless (dest_ability = @game.abilities(entity, :assign_hexes)) && dest_ability.hexes.include?(city.hex.name)

            ability = @game.class::DELAYED_ABILITIES[entity.name]

            entity.remove_ability(dest_ability)
            entity.add_ability(ability)
            city.hex.remove_assignment!(entity)

            @game.log << "-- #{entity.name} activates its ability: #{ability.description} --"
          end
        end
      end
    end
  end
end
