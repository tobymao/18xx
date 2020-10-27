# frozen_string_literal: true

require_relative '../special_token'

module Engine
  module Step
    module G18LosAngeles
      class SpecialToken < SpecialToken
        def process_place_token(action)
          if (action.entity == @game.dch) && action.city.tokenable?(action.entity.owner)
            @game.game_error('Dewey, Cheatham, and Howe can only place a token in '\
                             'a city (other than Long Beach) with no open slots.')
          end

          super
        end
      end
    end
  end
end
