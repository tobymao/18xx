# frozen_string_literal: true

require_relative '../special_token'
require_relative 'only_one_token_per_round'

module Engine
  module Step
    module G18GA
      class SpecialToken < SpecialToken
        def actions(entity)
          return [] if already_tokened_this_round?(entity)
          return ACTIONS if ability(entity) &&
            remaining_token_ability?(entity) &&
            @game.round.active_step.respond_to?(:process_place_token)

          []
        end

        def ability(entity)
          ability = super

          ability if ability && entity_corporation(entity) == @game.round.current_entity
        end

        def process_place_token(action)
          target = action.city.hex.name
          allowed = ability(action.entity).hexes
          @game.game_error("#{target} not allowed for token. Only allowed: #{allowed}.") unless allowed.include?(target)
          super
        end

        include OnlyOneTokenPerRound
      end
    end
  end
end
