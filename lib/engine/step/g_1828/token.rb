# frozen_string_literal: true

require_relative '../token'
require_relative 'token_tracker'

module Engine
  module Step
    module G1828
      class Token < Token
        include TokenTracker

        def place_token(entity, city, token, teleport: false)
          if city.hex.name == Engine::Game::G1828::VA_COALFIELDS_HEX
            @game.game_error("#{city.hex.location_name} may not be tokened")
          else
            super
          end
        end
      end
    end
  end
end
