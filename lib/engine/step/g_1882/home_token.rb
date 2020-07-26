# frozen_string_literal: true

require_relative '../home_token'

module Engine
  module Step
    module G1882
      class HomeToken < HomeToken
        def can_replace_token?(_entity, token)
          return true unless token

          token.corporation.name == 'CN'
        end

        def process_place_token(action)
          token = action.city.tokens[action.slot]
          if token
            raise GameError, "Cannot replace #{token.corporation.name} token" unless token.corporation.name == 'CN'

            @game.log << "#{action.entity.name} removes neutral token from #{action.city.hex.name}"
            # CN may no longer have a valid route.
            @game.graph.clear_graph_for(token.corporation)
            token.destroy!
          end

          super
        end
      end
    end
  end
end
