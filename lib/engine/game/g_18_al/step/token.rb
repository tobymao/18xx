# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18AL
      module Step
        class Token < Engine::Step::Token
          def place_token(entity, city, token, connected: true, extra: false, special_ability: nil)
            super

            @game.abilities(entity, :assign_hexes) do |ability|
              next unless ability.hexes.one?

              if city.hex.name == ability.hexes.first
                @log << "#{entity.name} receives $100 - #{ability.description}"
                entity.cash += 100
                entity.remove_ability(ability)
              end
            end
          end
        end
      end
    end
  end
end
