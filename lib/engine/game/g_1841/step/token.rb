# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1841
      module Step
        class Token < Engine::Step::Token
          def process_place_token(action)
            raise GameError, 'That location is reserved for SFMA' unless @game.check_token_hex(action.entity, action.city.hex)

            super

            # tokening a pass can remove the only legal route for a corp, so...
            # ...use the nuclear option
            @game.graph.clear_graph_for_all if action.city.pass?
          end

          def tokener_available_hex(entity, hex)
            super && @game.check_token_hex(entity, hex)
          end
        end
      end
    end
  end
end
