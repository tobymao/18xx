# frozen_string_literal: true

module Engine
  module Game
    module G1828
      module TokenTracker
        def process_place_token(action)
          super
          @round.tokens_placed << corporation_for(action.entity)
        end

        def already_tokened_this_round?(entity)
          @round.tokens_placed.include?(corporation_for(entity))
        end

        def round_state
          super.merge(
            {
              tokens_placed: [],
            }
          )
        end

        def corporation_for(entity)
          entity.company? ? entity.owner : entity
        end
      end
    end
  end
end
