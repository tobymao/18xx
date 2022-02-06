# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'token_tracker'

module Engine
  module Game
    module G1894
      module Step
        class Token < Engine::Step::Token
          include TokenTracker

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil)
            return super if city.hex.name != Engine::Game::G1894::Game::ENGLAND_HEX

            raise GameError, "#{city.hex.location_name} may not be tokened"
          end
        end
      end
    end
  end
end
