# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18VA
      module Step
        class Token < Engine::Step::Token
          def can_place_token?(entity)
            !@game.round.laid_token[entity] && (
              !@game.token_company.closed? ||
              (current_entity == entity &&
                !(tokens = available_tokens(entity)).empty? &&
                min_token_price(tokens) <= buying_power(entity))
            )
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
end
