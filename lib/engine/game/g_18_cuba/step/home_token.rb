# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18Cuba
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            hex = action.city.hex

            cheater = action.entity.type == :minor
            @log << "#{action.entity.name} places a token on #{hex.name}"
            action.city.place_token(action.entity, token, cheater: cheater)

            @round.pending_tokens.shift
          end
        end
      end
    end
  end
end
