# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18FL
      class Token < Token
        def can_place_token?(entity)
          (super || !@game.token_company.closed?) && !@game.round.laid_token[entity]
        end

        def process_place_token(action)
          raise GameError, "#{action.entity.name} cannot lay token now" if @game.round.laid_token[action.entity]

          super
          @game.round.laid_token[action.entity] = true
        end
      end
    end
  end
end
