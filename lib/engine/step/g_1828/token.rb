# frozen_string_literal: true

require_relative '../token'
require_relative 'token_tracker'

module Engine
  module Step
    module G1828
      class Token < Token
        include TokenTracker

        def place_token(entity, city, token, teleport: false)
          return super if city.hex.name != Engine::Game::G1828::VA_COALFIELDS_HEX

          raise GameError, "#{city.hex.location_name} may not be tokened"
        end
      end
    end
  end
end
