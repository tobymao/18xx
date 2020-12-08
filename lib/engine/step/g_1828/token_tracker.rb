# frozen_string_literal: true

module Engine
  module Step
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
          round_state = super || {}
          round_state[:tokens_placed] = []
          round_state
        end

        def corporation_for(entity)
          entity.company? ? entity.owner : entity
        end
      end
    end
  end
end
