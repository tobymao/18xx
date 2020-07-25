# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18AL
      class Token < Token
        def place_token(entity, city, token, teleport: false)
          super

          entity.abilities(:assign_hexes) do |ability|
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
